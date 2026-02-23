import SwiftUI

@MainActor
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    struct LoginRequest: Encodable {
        let email: String
        let password: String
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "bus.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
            
            Text("RCA Transport")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.green)
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: login) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Login")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(isLoading)
            
            Spacer()
        }
        .padding(.top, 50)
    }
    
    func login() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let body = LoginRequest(email: email, password: password)
                let response: AuthResponse = try await NetworkManager.shared.postRequest(
                    path: "/login",
                    body: body
                )
                UserDefaults.standard.set(email, forKey: "email")
                NetworkManager.shared.setToken(response.token)
                isLoading = false
            } catch {
                errorMessage = "Login failed. Please check your credentials."
                isLoading = false
            }
        }
    }
}
