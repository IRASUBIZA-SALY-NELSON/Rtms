import SwiftUI

struct UserProfileView: View {
    @StateObject private var networkManager = NetworkManager.shared
    
    var body: some View {
        List {
            Section {
                HStack(spacing: 15) {
                    Circle()
                        .fill(Color.rcaSoftBlue)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.rcaNavy)
                                .font(.system(size: 24, weight: .bold))
                        )
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(networkManager.currentUser?.name ?? networkManager.currentUser?.role.portalName ?? "User Portal")
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundColor(.rcaNavy)
                        Text(networkManager.currentUser?.email ?? "user@gmail.com")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.rcaSlate)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section(header: Text("Account Settings").font(.system(size: 11, weight: .bold)).tracking(1)) {
                NavigationLink(destination: ChangePasswordView()) {
                    Label("CHANGE PASSWORD", systemImage: "lock.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.rcaNavy)
                }
                NavigationLink(destination: PrivacySecurityView()) {
                    Label("PRIVACY & SECURITY", systemImage: "shield.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.rcaNavy)
                }
            }
            
            Section(header: Text("Support").font(.system(size: 11, weight: .bold)).tracking(1)) {
                NavigationLink(destination: HelpCenterView()) {
                    Label("HELP CENTER", systemImage: "questionmark.circle.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.rcaNavy)
                }
                NavigationLink(destination: ContactUsView()) {
                    Label("CONTACT US", systemImage: "envelope.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.rcaNavy)
                }
            }
            
            Section {
                Button(action: {
                    networkManager.logout()
                }) {
                    Label("Log Out", systemImage: "arrow.right.square")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Profile")
    }
}
