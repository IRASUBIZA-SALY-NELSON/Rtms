//
//  RtmsV2App.swift
//  RtmsV2
//
//  Created by Alain.K on 1/20/26.
//

import SwiftUI

@main
struct RtmsV2App: App {
    @StateObject private var networkManager = NetworkManager.shared
    @StateObject private var toastManager = ToastManager.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if networkManager.token == nil {
                    LoginView()
                } else {
                    AdaptiveMainView()
                }
                
                // Premium Toast Overlay
                VStack(alignment: .trailing, spacing: 12) {
                    ForEach(toastManager.toasts) { toast in
                        ToastView(toast: toast)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                    }
                    Spacer()
                }
                .padding(.top, 50)
                .padding(.trailing, 16)
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: toastManager.toasts)
                .zIndex(999)
            }
        }
    }
}

enum NavigationItem: String, CaseIterable, Identifiable {
    case stats, pay, logs, alerts, config, profile
    
    // Sub-items for granular sidebar navigation
    case paymentHistory, unpaidList, users, classConfig, reports
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .stats: return "Stats"
        case .pay: return "Pay"
        case .logs: return "Logs"
        case .alerts: return "Alerts"
        case .config: return "Config"
        case .profile: return "Profile"
        case .paymentHistory: return "Payment History"
        case .unpaidList: return "Unpaid List"
        case .users: return "Users"
        case .classConfig: return "Classes"
        case .reports: return "Reports"
        }
    }
    
    var sidebarTitle: String {
        switch self {
        case .stats: return "Dashboard"
        case .pay: return "Record Payment"
        case .logs: return "System Logs"
        case .alerts: return "Notifications"
        case .config: return "Configuration"
        case .profile: return "My Profile"
        case .paymentHistory: return "Payment History"
        case .unpaidList: return "Unpaid Students"
        case .users: return "User Management"
        case .classConfig: return "Class Management"
        case .reports: return "Financial Reports"
        }
    }
    
    var icon: String {
        switch self {
        case .stats: return "chart.pie.fill"
        case .pay: return "creditcard.fill"
        case .logs: return "list.bullet.rectangle.portrait.fill"
        case .alerts: return "bell.fill"
        case .config: return "gearshape.fill"
        case .profile: return "person.crop.circle.fill"
        case .paymentHistory: return "clock.arrow.circlepath"
        case .unpaidList: return "exclamationmark.triangle.fill"
        case .users: return "person.3.fill"
        case .classConfig: return "books.vertical.fill"
        case .reports: return "doc.text.below.ecg.fill"
        }
    }
}

struct AdaptiveMainView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        if sizeClass == .compact {
            MainTabView()
        } else {
            MainSidebarView()
        }
    }
}

struct MainSidebarView: View {
    @State private var selection: NavigationItem? = .stats
    @ObservedObject var networkManager = NetworkManager.shared
    
    // Expandable section states
    @State private var isFinanceExpanded = true
    @State private var isOperationsExpanded = true
    @State private var isSystemExpanded = true
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                // MARK: - Overview
                Section(header: Text("OVERVIEW").font(.caption).fontWeight(.bold).foregroundStyle(.secondary)) {
                    NavigationLink(value: NavigationItem.stats) {
                        Label(NavigationItem.stats.sidebarTitle, systemImage: NavigationItem.stats.icon)
                    }
                }
                
                // MARK: - Finance
                if let role = networkManager.currentUser?.role, [.admin, .cfo, .monitor].contains(role) {
                    Section(header: Text("FINANCE & PAYMENTS").font(.caption).fontWeight(.bold).foregroundStyle(.secondary)) {
                        NavigationLink(value: NavigationItem.pay) {
                            Label(NavigationItem.pay.sidebarTitle, systemImage: NavigationItem.pay.icon)
                        }
                        
                        // Placeholder for future expanded views or alternative views
                        NavigationLink(value: NavigationItem.paymentHistory) {
                            Label(NavigationItem.paymentHistory.sidebarTitle, systemImage: NavigationItem.paymentHistory.icon)
                        }
                        
                        NavigationLink(value: NavigationItem.unpaidList) {
                            Label(NavigationItem.unpaidList.sidebarTitle, systemImage: NavigationItem.unpaidList.icon)
                        }
                    }
                }
                
                // MARK: - Reporting
                if let role = networkManager.currentUser?.role, [.admin, .cfo].contains(role) {
                    Section(header: Text("REPORTING").font(.caption).fontWeight(.bold).foregroundStyle(.secondary)) {
                        NavigationLink(value: NavigationItem.reports) {
                            Label(NavigationItem.reports.sidebarTitle, systemImage: NavigationItem.reports.icon)
                        }
                    }
                }
                
                // MARK: - Operations
                if let role = networkManager.currentUser?.role, [.admin, .cfo, .president].contains(role) {
                    Section(header: Text("OPERATIONS").font(.caption).fontWeight(.bold).foregroundStyle(.secondary)) {
                        NavigationLink(value: NavigationItem.logs) {
                            Label(NavigationItem.logs.sidebarTitle, systemImage: NavigationItem.logs.icon)
                        }
                        
                        NavigationLink(value: NavigationItem.alerts) {
                            Label(NavigationItem.alerts.sidebarTitle, systemImage: NavigationItem.alerts.icon)
                        }
                    }
                }
                
                // MARK: - System Administration
                Section(header: Text("ADMINISTRATION").font(.caption).fontWeight(.bold).foregroundStyle(.secondary)) {
                    if let role = networkManager.currentUser?.role, [.admin, .cfo].contains(role) {
                        NavigationLink(value: NavigationItem.config) {
                            Label(NavigationItem.config.sidebarTitle, systemImage: NavigationItem.config.icon)
                        }
                        NavigationLink(value: NavigationItem.users) {
                            Label(NavigationItem.users.sidebarTitle, systemImage: NavigationItem.users.icon)
                        }
                        NavigationLink(value: NavigationItem.classConfig) {
                            Label(NavigationItem.classConfig.sidebarTitle, systemImage: NavigationItem.classConfig.icon)
                        }
                    }
                    
                    NavigationLink(value: NavigationItem.profile) {
                        Label(NavigationItem.profile.sidebarTitle, systemImage: NavigationItem.profile.icon)
                    }
                }
                
                // MARK: - Logout
                Section {
                    Button(action: {
                        NetworkManager.shared.logout()
                    }) {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(.red)
                            .fontWeight(.medium)
                    }
                }
                .padding(.top, 8)
            }
            .listStyle(.sidebar)
            .navigationTitle("RTMS Pro")
            .accentColor(.rcaNavy)
        } detail: {
            if let selection = selection {
                switch selection {
                case .stats: DashboardView()
                case .pay: RecordPaymentView()
                case .logs: LogsView()
                case .alerts: NotificationsView()
                case .config: AdminSettingsView()
                case .profile: UserProfileView()
                    
                // For now, map sub-items to existing views or placeholders
                // Ideally, these would go to specific filtered views or new views
                case .paymentHistory: LogsView() // Placeholder
                case .unpaidList: UnpaidStudentsView()
                case .users: UserManagementView()
                case .classConfig: ClassManagementView()
                case .reports: ReportsView()
                }
            } else {
                ContentUnavailableView("Select an Option", systemImage: "macwindow.on.rectangle", description: Text("Choose an item from the sidebar to view details."))
            }
        }
    }
}

struct MainTabView: View {
    @ObservedObject var networkManager = NetworkManager.shared
    
    var body: some View {
        NavigationView {
            TabView {
                DashboardView()
                    .tabItem {
                        Label("Stats", systemImage: "chart.pie.fill")
                    }
                
                if let role = networkManager.currentUser?.role, [.admin, .cfo, .monitor].contains(role) {
                    RecordPaymentView()
                        .tabItem {
                            Label("Pay", systemImage: "creditcard.fill")
                        }
                }
                
                if let role = networkManager.currentUser?.role, [.admin, .cfo, .president].contains(role) {
                    LogsView()
                        .tabItem {
                            Label("Logs", systemImage: "list.bullet.rectangle.portrait.fill")
                        }
                }
                
                NotificationsView()
                    .tabItem {
                        Label("Alerts", systemImage: "bell.fill")
                    }
                
                if let role = networkManager.currentUser?.role, [.admin, .cfo].contains(role) {
                    AdminSettingsView()
                        .tabItem {
                            Label("Config", systemImage: "slider.horizontal.3")
                        }
                }
                
                UserProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
            }
            .accentColor(.rcaNavy)
        }
    }
}
