import SwiftUI

@main
struct RTMSApp: App {
    @StateObject private var networkManager = NetworkManager.shared
    
    var body: some Scene {
        WindowGroup {
            if networkManager.token == nil {
                LoginView()
            } else {
                MainTabView()
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Stats", systemImage: "chart.pie.fill")
                }
            
            RecordPaymentView()
                .tabItem {
                    Label("Pay", systemImage: "creditcard.fill")
                }
            
            LogsView()
                .tabItem {
                    Label("Logs", systemImage: "list.bullet.rectangle.portrait.fill")
                }
            
            NotificationsView()
                .tabItem {
                    Label("Alerts", systemImage: "bell.fill")
                }
            
            AdminSettingsView()
                .tabItem {
                    Label("Config", systemImage: "slider.horizontal.3")
                }
            
            UserProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(.rcaGreen)
    }
}
