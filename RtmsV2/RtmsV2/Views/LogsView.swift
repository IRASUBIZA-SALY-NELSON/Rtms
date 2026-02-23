import SwiftUI

struct LogsView: View {
    @State private var payments: [Payment] = []
    @State private var isLoading = true
    @ObservedObject var networkManager = NetworkManager.shared
    
    var body: some View {
        ZStack {
            Color.rcaBackground.ignoresSafeArea()
            
            if isLoading {
                ProgressView()
            } else if payments.isEmpty {
                ContentUnavailableView("No Logs Found", systemImage: "shield.slash", description: Text("No audit trail records are currently available."))
            } else {
                List(payments) { payment in
                    AuditLogCard(payment: payment)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Audit Trail")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let user = networkManager.currentUser {
                    Text(user.role.portalName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.rcaNavy.opacity(0.1))
                        .foregroundColor(.rcaNavy)
                        .cornerRadius(12)
                }
            }
        }
        .refreshable {
            await fetchLogs()
        }
        .onAppear {
            Task { await fetchLogs() }
        }
    }
    
    func fetchLogs() async {
        do {
            let data: [Payment] = try await NetworkManager.shared.getRequest(path: "/payments/logs")
            DispatchQueue.main.async {
                self.payments = data
                self.isLoading = false
            }
        } catch {
            print("Error fetching logs: \(error)")
            DispatchQueue.main.async { self.isLoading = false }
        }
    }
}

struct AuditLogCard: View {
    let payment: Payment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(payment.student.name)
                        .font(.headline)
                        .foregroundColor(.rcaNavy)
                    
                    Text(payment.activity ?? "Payment Recorded")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(payment.amount) RWF")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.rcaNavy)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label(payment.recordedBy?.email ?? "System", systemImage: "person.circle.fill")
                    Spacer()
                    Text(payment.timestamp, style: .date)
                }
                
                HStack {
                    Label(payment.ipAddress ?? "Local", systemImage: "network")
                    Spacer()
                    Text(payment.timestamp, style: .time)
                }
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(RCAStyle.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
