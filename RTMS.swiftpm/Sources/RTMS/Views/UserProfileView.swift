import SwiftUI

struct UserProfileView: View {
    @StateObject private var networkManager = NetworkManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack(spacing: 15) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.rcaGreen)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Discipline Master")
                                .font(.headline)
                            Text(UserDefaults.standard.string(forKey: "email") ?? "user@gmail.com")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Account Settings")) {
                    NavigationLink(destination: Text("Change Password")) {
                        Label("Change Password", systemImage: "lock.fill")
                    }
                    NavigationLink(destination: Text("Privacy Settings")) {
                        Label("Privacy", systemImage: "shield.fill")
                    }
                }
                
                Section(header: Text("Support")) {
                    Label("Help Center", systemImage: "questionmark.circle.fill")
                    Label("Contact Us", systemImage: "envelope.fill")
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
}
