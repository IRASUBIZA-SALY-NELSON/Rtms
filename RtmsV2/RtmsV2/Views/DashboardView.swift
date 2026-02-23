import SwiftUI
import Charts

@MainActor
struct DashboardView: View {
    @State private var analytics: Analytics?
    @State private var isLoading = true
    @State private var selectedClassName: String?
    @State private var showingUnpaidList = false
    @State private var animate = false
    @State private var chartViewSelection: ChartViewType = .gender
    
    enum ChartViewType: String, CaseIterable {
        case gender = "Gender"
        case classes = "Classes"
    }
    
    var body: some View {
        ZStack {
            // 1. Clean Background
            Color.rcaBackground.ignoresSafeArea()
            
            ScrollView {
                if isLoading {
                    ProgressView()
                        .padding(.top, 50)
                } else if let stats = analytics {
                    VStack(spacing: 24) {
                        // 2. Student-Focused Statistics
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                PremiumStatCard(
                                    title: "Total Students",
                                    value: "\(stats.totalStudentsCount ?? 0)",
                                    subtitle: "Registered",
                                    icon: "person.3.fill",
                                    color: .rcaNavy
                                )
                                PremiumStatCard(
                                    title: "Total Collected",
                                    value: String(format: "%.0f RWF", stats.totalFunded),
                                    subtitle: String(format: "%.1f%%", stats.progressPercentage),
                                    icon: "banknote.fill",
                                    color: .blue,
                                    progress: stats.progressPercentage
                                )
                            }
                            
                            HStack(spacing: 16) {
                                PremiumStatCard(
                                    title: "Students Paid",
                                    value: "\(stats.paidStudents)",
                                    subtitle: "Completed",
                                    icon: "checkmark.circle.fill",
                                    color: .green,
                                    progress: (Double(stats.paidStudents) / Double(max(stats.totalStudentsCount ?? 1, 1))) * 100
                                )
                                
                                Button(action: { showingUnpaidList = true }) {
                                    PremiumStatCard(
                                        title: "Remaining Students",
                                        value: "\(stats.unpaidStudents)",
                                        subtitle: "Pending",
                                        icon: "person.badge.clock",
                                        color: .orange
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        
                        // 3. Combined Distribution & Performance Card
                        RCACard {
                            VStack(spacing: 24) {
                                // Header & Toggle
                                VStack(spacing: 16) {
                                    HStack {
                                        Text(chartViewSelection == .gender ? "Gender Distribution" : "Class Performance")
                                            .font(.system(size: 16, weight: .heavy))
                                            .foregroundColor(.rcaNavy)
                                        Spacer()
                                    }
                                    
                                    Picker("View", selection: $chartViewSelection) {
                                        Text("Gender").tag(ChartViewType.gender)
                                        Text("Classes").tag(ChartViewType.classes)
                                    }
                                    .pickerStyle(.segmented)
                                    .labelsHidden()
                                }
                                
                                if chartViewSelection == .gender {
                                    // Gender Chart View
                                    VStack(alignment: .center, spacing: 24) {
                                        // Large Pie Chart
                                        Chart(stats.genderDistribution, id: \.gender) { item in
                                            // _ = Double(item.count) / Double(max(total, 1)) * 100
                                            
                                            SectorMark(
                                                angle: .value("Count", animate ? item.count : 0),
                                                innerRadius: .ratio(0),
                                                angularInset: 0
                                            )
                                            .cornerRadius(0)
                                            .foregroundStyle(by: .value("Gender", item.gender))
                                            .annotation(position: .overlay) {
                                                 if animate {
                                                     VStack(spacing: 2) {
                                                         Text(item.gender.prefix(1)) // M or F
                                                             .font(.system(size: 14, weight: .bold))
                                                             .foregroundColor(.white)
                                                     }
                                                 }
                                             }
                                        }
                                        .frame(height: 280)
                                        .chartLegend(.hidden)
                                        .chartForegroundStyleScale([
                                            "Male": Color.rcaNavy,
                                            "Female": Color.rcaSoftBlue
                                        ])
                                        
                                        // Statistics Labels
                                        VStack(spacing: 12) {
                                            ForEach(stats.genderDistribution.sorted(by: { $0.count > $1.count }), id: \.gender) { item in
                                                let total = stats.genderDistribution.reduce(0) { $0 + $1.count }
                                                let percentage = Double(item.count) / Double(max(total, 1)) * 100
                                                let genderColor = item.gender == "Male" ? Color.rcaNavy : Color.rcaSoftBlue
                                                
                                                HStack(spacing: 12) {
                                                    Circle()
                                                        .fill(genderColor)
                                                        .frame(width: 12, height: 12)
                                                    
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(item.gender)
                                                            .font(.system(size: 14, weight: .bold))
                                                            .foregroundColor(.rcaNavy)
                                                        
                                                        Text("\(String(format: "%.0f%%", percentage)) • \(item.count) students")
                                                            .font(.system(size: 12, weight: .medium))
                                                            .foregroundColor(.rcaSlate)
                                                    }
                                                    
                                                    Spacer()
                                                }
                                                .padding(12)
                                                .background(Color.rcaBackground)
                                                .cornerRadius(8)
                                            }
                                        }
                                    }
                                } else {
                                    // Class Performance View
                                    VStack(alignment: .center, spacing: 24) {
                                        // Large Centered Donut Chart
                                        Chart(stats.classStats.sorted(by: { $0.totalAmount > $1.totalAmount })) { item in
                                            let total = stats.classStats.reduce(0.0) { $0 + $1.totalAmount }
                                            let percentage = (item.totalAmount / max(total, 1)) * 100
                                            
                                            SectorMark(
                                                angle: .value("Funded", animate ? item.totalAmount : 0),
                                                innerRadius: .ratio(0.618),
                                                angularInset: 0
                                            )
                                            .cornerRadius(0)
                                            .foregroundStyle(by: .value("Class", item.name))
                                            .annotation(position: .overlay) {
                                                if animate && percentage > 5 {
                                                    Text(String(format: "%.0f%%", percentage))
                                                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        }
                                        .frame(height: 280)
                                        .chartLegend(.hidden)
                                        .chartForegroundStyleScale([
                                            "Y1A": Color.rcaNavy,
                                            "Y1B": Color.rcaSoftBlue,
                                            "Y1C": Color.rcaLavender,
                                            "Y2A": Color.rcaSoftGray,
                                            "Y2B": Color.rcaNavy.opacity(0.7),
                                            "Y2C": Color.rcaSoftBlue.opacity(0.5),
                                            "Y3A": Color.rcaSoftBlue.opacity(0.7),
                                            "Y3B": Color.rcaLavender.opacity(0.7),
                                            "Y3C": Color.rcaSlate.opacity(0.6),
                                            "Y3D": Color.rcaNavy.opacity(0.5)
                                        ])
                                        
                                        // Custom Legend Grid
                                        LazyVGrid(columns: [
                                            GridItem(.flexible()),
                                            GridItem(.flexible())
                                        ], spacing: 12) {
                                            ForEach(stats.classStats.sorted(by: { $0.totalAmount > $1.totalAmount })) { item in
                                                let total = stats.classStats.reduce(0.0) { $0 + $1.totalAmount }
                                                let percentage = (item.totalAmount / max(total, 1)) * 100
                                                
                                                Button(action: { selectedClassName = item.name }) {
                                                    HStack(spacing: 8) {
                                                        Circle()
                                                            .fill(getClassColor(item.name))
                                                            .frame(width: 12, height: 12)
                                                        
                                                        VStack(alignment: .leading, spacing: 2) {
                                                            Text(item.name)
                                                                .font(.system(size: 12, weight: .bold))
                                                                .foregroundColor(.rcaNavy)
                                                            
                                                            Text("\(item.count) students • \(String(format: "%.0f%%", percentage))")
                                                                .font(.system(size: 10, weight: .medium))
                                                                .foregroundColor(.rcaSlate)
                                                        }
                                                        
                                                        Spacer()
                                                    }
                                                    .padding(8)
                                                    .background(Color.rcaBackground)
                                                    .cornerRadius(8)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal)


                        // 5. Direction Performance (Horizontal Percentage Chart)
                        RCACard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Direction Breakdown")
                                    .font(.system(size: 14, weight: .heavy))
                                    .foregroundColor(.rcaNavy)
                                
                                Chart(stats.directionStats) { item in
                                    let total = stats.directionStats.reduce(0) { $0 + $1.count }
                                    let percentage = Double(item.count) / Double(max(total, 1)) * 100
                                    
                                    BarMark(
                                        x: .value("Percentage", animate ? percentage : 0),
                                        y: .value("Direction", item.name)
                                    )
                                    .foregroundStyle(Color.rcaLavender.gradient)
                                    .cornerRadius(4)
                                    .annotation(position: .trailing) {
                                        if animate {
                                            Text(String(format: "%.0f%%", percentage))
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.rcaSlate)
                                                .padding(.leading, 4)
                                        }
                                    }
                                }
                                .frame(height: 220)
                                .chartXScale(domain: 0...120)
                            }
                        }
                        .padding(.horizontal)

                        // 6. Promotion Performance (Y1, Y2, Y3)
                        RCACard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Promotion Participation")
                                    .font(.system(size: 14, weight: .heavy))
                                    .foregroundColor(.rcaNavy)
                                
                                Chart(stats.promotionStats.sorted(by: { $0.promotion < $1.promotion }), id: \.promotion) { item in
                                    BarMark(
                                        x: .value("Promotion", item.promotion),
                                        y: .value("Percentage", animate ? item.percentage : 0)
                                    )
                                    .foregroundStyle(Color.rcaNavy.gradient)
                                    .cornerRadius(6)
                                    .annotation(position: .top) {
                                        if animate {
                                            VStack(spacing: 2) {
                                                Text(String(format: "%.0f%%", item.percentage))
                                                    .font(.system(size: 10, weight: .bold))
                                                Text("\(item.paidCount)/\(item.totalCount)")
                                                    .font(.system(size: 8, weight: .medium))
                                                    .foregroundColor(.rcaSlate)
                                            }
                                            .padding(.bottom, 4)
                                        }
                                    }
                                }
                                .frame(height: 240)
                                .chartYScale(domain: 0...130)
                                .chartYAxis {
                                    AxisMarks(values: [0, 50, 100]) { value in
                                        AxisGridLine()
                                        AxisValueLabel {
                                            if let pct = value.as(Double.self) {
                                                Text("\(Int(pct))%")
                                                    .font(.system(size: 10, weight: .bold))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Dashboard")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let user = NetworkManager.shared.currentUser {
                    Text(user.role.portalName)
                        .font(.system(.caption, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.rcaNavy.opacity(0.1))
                        .foregroundColor(.rcaNavy)
                        .cornerRadius(20)
                }
            }
        }
        .refreshable {
            await fetchAnalytics()
        }
        .onAppear {
            Task { await fetchAnalytics() }
        }
        .sheet(item: Binding(
            get: { selectedClassName.map { IdentifiableString(id: $0) } },
            set: { selectedClassName = $0?.id }
        )) { item in
            ClassDrillDownView(className: item.id)
        }
        .sheet(isPresented: $showingUnpaidList) {
            NavigationView {
                UnpaidStudentsView()
            }
        }
        .onChange(of: chartViewSelection) {
            animate = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    animate = true
                }
            }
        }
    }
    
    func fetchAnalytics() async {
        do {
            let data: Analytics = try await NetworkManager.shared.getRequest(path: "/analytics")
            
            // Reset animation state
            self.animate = false
            self.analytics = data
            self.isLoading = false
            
            // Trigger animation with a slight delay to ensure view is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0)) {
                    self.animate = true
                }
            }
        } catch {
            print("Fetch error: \(error)")
        }
    }
    
    func getClassColor(_ name: String) -> Color {
        switch name {
        case "Y1A": return .rcaNavy
        case "Y1B": return .rcaSoftBlue
        case "Y1C": return .rcaLavender
        case "Y2A": return .rcaSoftGray
        case "Y2B": return .rcaNavy.opacity(0.7)
        case "Y2C": return .rcaSoftBlue.opacity(0.5)
        case "Y3A": return .rcaSoftBlue.opacity(0.7)
        case "Y3B": return .rcaLavender.opacity(0.7)
        case "Y3C": return .rcaSlate.opacity(0.6)
        case "Y3D": return .rcaNavy.opacity(0.5)
        default: return .rcaSoftBlue
        }
    }
}

// Helper for sheet selection
struct IdentifiableString: Identifiable {
    let id: String
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(RCAStyle.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
