import SwiftUI

struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let date: Date
    let isRead: Bool
}

struct NotificationsView: View {
    @State private var notifications: [AppNotification] = [
        AppNotification(title: "New Student Registered", message: "Emma Reponse has joined Year 1A.", date: Date().addingTimeInterval(-3600), isRead: false),
        AppNotification(title: "Payment Received", message: "Regine Uwimana paid for Kigali direction.", date: Date().addingTimeInterval(-7200), isRead: true),
        AppNotification(title: "Route Update", message: "Rubavu direction price updated to 5500 RWF.", date: Date().addingTimeInterval(-86400), isRead: true)
    ]
    
    var body: some View {
        NavigationView {
            List(notifications) { notification in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(notification.title)
                            .font(.headline)
                        Spacer()
                        if !notification.isRead {
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundColor(.rcaGreen)
                        }
                    }
                    
                    Text(notification.message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(notification.date, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Notifications")
            .toolbar {
                Button("Mark all read") {
                    // Action
                }
            }
        }
    }
}
