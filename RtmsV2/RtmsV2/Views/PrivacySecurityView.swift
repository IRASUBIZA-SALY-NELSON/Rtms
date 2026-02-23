import SwiftUI

struct PrivacySecurityView: View {
    @State private var enable2FA = false
    @State private var shareUsageData = true
    @State private var biometricsEnabled = true
    @State private var showDeleteAccountAlert = false
    
    var body: some View {
        ZStack {
            Color.rcaBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PRIVACY & PROTECTION")
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(1)
                            .foregroundColor(.rcaSlate)
                        Text("Manage how your data is handled and secure your account.")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.rcaNavy)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Security Toggle Group
                    RCACard {
                        VStack(spacing: 0) {
                            ToggleRow(title: "Two-Factor Authentication", subtitle: "Requires code from email to login", isOn: $enable2FA, icon: "shield.lefthalf.filled")
                            Divider().padding(.vertical, 12)
                            ToggleRow(title: "Biometric Login", subtitle: "Use FaceID or TouchID", isOn: $biometricsEnabled, icon: "faceid")
                            Divider().padding(.vertical, 12)
                            ToggleRow(title: "Share Usage Data", subtitle: "Help us improve RTMS", isOn: $shareUsageData, icon: "chart.bar.fill")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Information Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("TRUST & TRANSPARENCY")
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(1)
                            .foregroundColor(.rcaSlate)
                        
                        RCACard {
                            VStack(alignment: .leading, spacing: 15) {
                                SecurityInfoRow(title: "Data Encryption", description: "All your financial data is encrypted using AES-256 standards.", icon: "lock.shield.fill")
                                SecurityInfoRow(title: "Session Control", description: "You are automatically logged out after 24 hours of inactivity.", icon: "timer")
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Danger Zone
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DANGER ZONE")
                            .font(.system(size: 10, weight: .heavy))
                            .tracking(0.5)
                            .foregroundColor(.red)
                        
                        Button(action: { showDeleteAccountAlert = true }) {
                            HStack {
                                Text("Delete Account")
                                    .font(.system(size: 14, weight: .bold))
                                Spacer()
                                Image(systemName: "trash.fill")
                            }
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Privacy & Security")
        .alert("Delete Account?", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // Delete logic
            }
        } message: {
            Text("This action is permanent and cannot be undone. All your data will be wiped from our servers.")
        }
    }
}

struct ToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.rcaNavy)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.rcaNavy)
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.rcaSlate)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.rcaNavy)
        }
    }
}

struct SecurityInfoRow: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.rcaNavy)
                .font(.system(size: 16))
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.rcaNavy)
                Text(description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.rcaSlate)
                    .lineSpacing(2)
            }
        }
    }
}
