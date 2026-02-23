import SwiftUI

struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let date: Date
    let isRead: Bool
}

struct NotificationsView: View {
    @State private var notifications: [Notification] = []
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Color.rcaBackground.ignoresSafeArea()
            
            if isLoading {
                ProgressView()
            } else if notifications.isEmpty {
                ContentUnavailableView("No Notifications", systemImage: "bell.slash", description: Text("You're all caught up!"))
            } else {
                List(notifications) { notification in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(notification.title)
                                .font(.system(size: 13, weight: .heavy))
                                .tracking(0.5)
                                .foregroundColor(.rcaNavy)
                            Spacer()
                            if !notification.isRead {
                                Circle()
                                    .frame(width: 8, height: 8)
                                    .foregroundColor(.rcaSoftBlue)
                            }
                        }
                        
                        Text(notification.message)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.rcaSlate)
                        
                        Text(notification.timestamp, style: .time)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.visible)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Notifications")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: markAllAsRead) {
                    Text("MARK ALL READ")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(.rcaNavy)
                }
            }
        }
        .refreshable {
            await fetchNotifications()
        }
        .onAppear {
            Task { await fetchNotifications() }
        }
    }
    
    func fetchNotifications() async {
        do {
            let data: [Notification] = try await NetworkManager.shared.getRequest(path: "/notifications")
            self.notifications = data
            self.isLoading = false
        } catch {
            print("Error fetching notifications: \(error)")
            self.isLoading = false
        }
    }
    
    func markAllAsRead() {
        Task {
            do {
                let _: [String: String] = try await NetworkManager.shared.postRequest(path: "/notifications/read-all", body: ["": ""])
                await fetchNotifications()
            } catch {
                print("Error marking read: \(error)")
            }
        }
    }
}
