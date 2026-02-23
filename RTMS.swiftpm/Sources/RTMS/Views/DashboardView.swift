import SwiftUI
import Charts

@MainActor
struct DashboardView: View {
    @State private var analytics: Analytics?
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                if isLoading {
                    ProgressView()
                        .padding()
                } else if let data = analytics {
                    VStack(spacing: 20) {
                        // Summary Cards
                        HStack {
                            SummaryCard(title: "Paid", count: data.summary.paidCount, color: .green)
                            SummaryCard(title: "Unpaid", count: data.summary.unpaidCount, color: .red)
                        }
                        .padding(.horizontal)
                        
                        // Pie Chart: Paid vs Unpaid
                        RCACard {
                            VStack(alignment: .leading) {
                                Text("Payment Distribution")
                                    .font(.headline)
                                Chart {
                                    SectorMark(angle: .value("Paid", data.summary.paidCount), innerRadius: .ratio(0.6))
                                        .foregroundStyle(Color.rcaGreen)
                                        .annotation(position: .overlay) { Text("\(data.summary.paidCount)") }
                                    
                                    SectorMark(angle: .value("Unpaid", data.summary.unpaidCount), innerRadius: .ratio(0.6))
                                        .foregroundStyle(Color.statusUnpaid)
                                        .annotation(position: .overlay) { Text("\(data.summary.unpaidCount)") }
                                }
                                .frame(height: 200)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Bar Chart: Directions
                        RCACard {
                            VStack(alignment: .leading) {
                                Text("Students by Direction")
                                    .font(.headline)
                                Chart {
                                    ForEach(data.directionStats, id: \._id) { stat in
                                        BarMark(
                                            x: .value("Direction", stat._id),
                                            y: .value("Count", stat.count)
                                        )
                                        .foregroundStyle(Color.rcaGreen.opacity(0.8))
                                    }
                                }
                                .frame(height: 200)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Bar Chart: Classes
                        RCACard {
                            VStack(alignment: .leading) {
                                Text("Payments by Class")
                                    .font(.headline)
                                Chart {
                                    ForEach(data.classStats, id: \.name) { stat in
                                        BarMark(
                                            x: .value("Class", stat.name),
                                            y: .value("Count", stat.count)
                                        )
                                        .foregroundStyle(Color.blue.opacity(0.7))
                                    }
                                }
                                .frame(height: 250)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Analytics")
            .refreshable {
                await fetchAnalytics()
            }
            .onAppear {
                Task { await fetchAnalytics() }
            }
        }
    }
    
    func fetchAnalytics() async {
        do {
            let data: Analytics = try await NetworkManager.shared.getRequest(path: "/analytics")
            self.analytics = data
            self.isLoading = false
        } catch {
            print("Fetch error: \(error)")
        }
    }
}

struct SummaryCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        RCACard {
            VStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("\(count)")
                    .font(.title)
                    .bold()
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
