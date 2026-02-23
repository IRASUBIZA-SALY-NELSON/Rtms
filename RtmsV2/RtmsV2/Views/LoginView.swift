import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var rememberMe = false
    
    var body: some View {
        ZStack {
            Color.rcaBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Header - RCA Logo
                VStack(spacing: 24) {
                    Image("PrimaryLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    VStack(spacing: 8) {
                        Text("School Account Login")
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundColor(.rcaNavy)
                        
                        Text("LOG IN TO YOUR ACCOUNT")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.rcaSlate)
                            .tracking(1)
                    }
                }
                .padding(.bottom, 40)
                
                // Login Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.rcaInputBackground)
                            .cornerRadius(10)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.rcaInputBackground)
                            .cornerRadius(10)
                    }
                    
                    HStack {
                        Toggle(isOn: $rememberMe) {
                            Text("REMEMBER ME")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.rcaSlate)
                                .tracking(0.5)
                        }
                        .toggleStyle(CheckboxToggleStyle())
                        
                        Spacer()
                        
                        Button("FORGOT PASSWORD?") {
                            // Forgot password action
                        }
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.rcaNavy)
                        .tracking(0.5)
                    }
                    

                    
                    RCAButton(title: "Login", isLoading: isLoading) {
                        login()
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                Spacer()
            }
        }
    }
    
    func login() {
        guard !email.isEmpty && !password.isEmpty else {
            ToastManager.shared.show(message: "Please enter your email and password.", type: .error)
            return
        }
        
        isLoading = true
        Task {
            do {
                let request = LoginRequest(email: email, password: password)
                let response: AuthResponse = try await NetworkManager.shared.postRequest(path: "/login", body: request)
                
                DispatchQueue.main.async {
                    NetworkManager.shared.setToken(response.token, user: response.user)
                    ToastManager.shared.show(message: "Welcome back! Logged in as \(response.user.role.portalName).", type: .success)
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    ToastManager.shared.show(message: "We couldn't log you in. Please check your details and try again.", type: .error)
                    isLoading = false
                }
            }
        }
    }
}

// Custom Checkbox Toggle Style
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? .rcaNavy : .gray)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
    }
}
