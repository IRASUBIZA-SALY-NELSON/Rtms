import SwiftUI

struct ChangePasswordView: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.rcaBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("UPDATE SECURITY")
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(1)
                            .foregroundColor(.rcaSlate)
                        Text("Ensure your account stays secure with a strong password.")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.rcaNavy)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    RCACard {
                        VStack(spacing: 20) {
                            SecureInputField(title: "CURRENT PASSWORD", text: $currentPassword)
                            
                            Divider()
                            
                            SecureInputField(title: "NEW PASSWORD", text: $newPassword)
                            SecureInputField(title: "CONFIRM NEW PASSWORD", text: $confirmPassword)
                            
                            RCAButton(title: "Update Password", isLoading: isLoading) {
                                changePassword()
                            }
                            .padding(.top, 10)
                            .disabled(currentPassword.isEmpty || newPassword.isEmpty || newPassword != confirmPassword)
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PASSWORD REQUIREMENTS")
                            .font(.system(size: 10, weight: .heavy))
                            .tracking(0.5)
                            .foregroundColor(.rcaSlate)
                        
                        RequirementItem(text: "At least 8 characters", isMet: newPassword.count >= 8)
                        RequirementItem(text: "Passwords must match", isMet: !newPassword.isEmpty && newPassword == confirmPassword)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func changePassword() {
        guard newPassword == confirmPassword else { return }
        
        isLoading = true
        Task {
            do {
                let body = ["currentPassword": currentPassword, "newPassword": newPassword]
                let _: [String: String] = try await NetworkManager.shared.postRequest(path: "/change-password", body: body)
                
                DispatchQueue.main.async {
                    isLoading = false
                    ToastManager.shared.show(message: "Password updated successfully!", type: .success)
                    dismiss()
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    ToastManager.shared.show(message: error.localizedDescription, type: .error)
                }
            }
        }
    }
}

struct SecureInputField: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 10, weight: .heavy))
                .tracking(0.5)
                .foregroundColor(.rcaSlate)
            
            SecureField("••••••••", text: $text)
                .font(.system(size: 14, weight: .bold))
                .padding()
                .background(Color.rcaInputBackground)
                .cornerRadius(12)
        }
    }
}

struct RequirementItem: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMet ? .green : .rcaSlate.opacity(0.3))
                .font(.system(size: 14))
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isMet ? .rcaNavy : .rcaSlate)
        }
    }
}
