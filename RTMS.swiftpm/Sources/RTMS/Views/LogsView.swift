import SwiftUI

struct LogsView: View {
    @State private var payments: [Payment] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            List(payments) { payment in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(payment.student.name)
                            .font(.headline)
                        Spacer()
                        Text("\(payment.amount) RWF")
                            .bold()
                            .foregroundColor(.rcaGreen)
                    }
                    
                    HStack {
                        Label(payment.student.className, systemImage: "graduationcap.fill")
                        Text("•")
                        Label(payment.direction, systemImage: "arrow.up.right.circle.fill")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    HStack {
                        Spacer()
                        Text(payment.timestamp, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("System Logs")
            .refreshable {
                await fetchLogs()
            }
            .onAppear {
                Task { await fetchLogs() }
            }
            .overlay {
                if payments.isEmpty && !isLoading {
                    ContentUnavailableView("No Payments Recorded", systemImage: "tray.fill")
                }
            }
        }
    }
    
    func fetchLogs() async {
        do {
            let data: [Payment] = try await NetworkManager.shared.getRequest(path: "/logs")
            DispatchQueue.main.async {
                self.payments = data
                self.isLoading = false
            }
        } catch {
            print(error)
            DispatchQueue.main.async { self.isLoading = false }
        }
    }
}
