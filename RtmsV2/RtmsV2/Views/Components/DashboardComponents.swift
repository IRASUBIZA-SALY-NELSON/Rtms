import SwiftUI

struct StarryBackground: View {
    @State private var animate = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark Navy Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.rcaNavy, Color(hex: "#0F172A")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Subtle Stars
                ForEach(0..<40) { _ in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.1...0.3)))
                        .frame(width: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .opacity(animate ? 0.2 : 0.8)
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 2...4))
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 0...2)),
                            value: animate
                        )
                }
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct PremiumStatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let color: Color
    var progress: Double? = nil
    
    @State private var showProgress = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    if let progress = progress {
                        Circle()
                            .trim(from: 0, to: showProgress ? progress / 100 : 0)
                            .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 36, height: 36)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeOut(duration: 1.2), value: showProgress)
                    }
                    
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 16, weight: .bold))
                }
                
                Spacer()
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 10, weight: .heavy))
                        .textCase(.uppercase)
                        .tracking(1)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color.opacity(0.1))
                        .foregroundColor(color)
                        .cornerRadius(6)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .heavy, design: .default))
                    .foregroundColor(.rcaNavy)
                
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.rcaSlate)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.rcaNavy.opacity(0.04), radius: 15, x: 0, y: 10)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showProgress = true
            }
        }
    }
}

struct ClassDrillDownView: View {
    let className: String
    @State private var students: [Student] = []
    @State private var isLoading = true
    @State private var selectedStatus: String = "All"
    @Environment(\.dismiss) var dismiss
    
    var filteredStudents: [Student] {
        switch selectedStatus {
        case "Paid":
            return students.filter { $0.paymentStatus }
        case "Unpaid":
            return students.filter { !$0.paymentStatus }
        default:
            return students
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.rcaBackground.ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                } else {
                    VStack(spacing: 0) {
                        // Filter Picker
                        Picker("Status", selection: $selectedStatus) {
                            Text("All").tag("All")
                            Text("Paid").tag("Paid")
                            Text("Unpaid").tag("Unpaid")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .background(Color.white)
                        
                        if filteredStudents.isEmpty {
                            Spacer()
                            ContentUnavailableView("No Students Found", systemImage: "person.slash")
                            Spacer()
                        } else {
                            ScrollView {
                                VStack(spacing: 20) {
                                    // Table Header
                                    HStack {
                                        Text("Student Name").bold()
                                        Spacer()
                                        Text("Status").bold()
                                    }
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                    
                                    VStack(spacing: 1) {
                                        ForEach(filteredStudents) { student in
                                            NavigationLink(destination: StudentDetailView(student: student)) {
                                                HStack {
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text(student.name)
                                                            .fontWeight(.semibold)
                                                            .foregroundColor(.rcaNavy)
                                                        Text(student.studentCard)
                                                            .font(.caption2)
                                                            .foregroundColor(.rcaSlate)
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    Text(student.paymentStatus ? "PAID" : "UNPAID")
                                                        .font(.system(.caption2, design: .rounded))
                                                        .fontWeight(.bold)
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 4)
                                                        .background(student.paymentStatus ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                                        .foregroundColor(student.paymentStatus ? .green : .red)
                                                        .cornerRadius(5)
                                                }
                                                .padding()
                                                .background(Color.white)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            Divider()
                                        }
                                    }
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                }
                                .padding(.vertical)
                            }
                        }
                    }
                }
            }
            .navigationTitle("\(className) Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                fetchDetails()
            }
        }
    }
    
    func fetchDetails() {
        Task {
            do {
                let data: [Student] = try await NetworkManager.shared.getRequest(path: "/analytics/class/\(className)")
                self.students = data
                self.isLoading = false
            } catch {
                print("Error: \(error)")
                self.isLoading = false
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
