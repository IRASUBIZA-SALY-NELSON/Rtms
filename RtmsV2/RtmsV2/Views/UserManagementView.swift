import SwiftUI

struct UserManagementView: View {
    @State private var users: [User] = []
    @State private var isLoading = true
    @State private var showingAddEditSheet = false
    @State private var selectedUser: User?
    
    var body: some View {
        ZStack {
            Color.rcaBackground.ignoresSafeArea()
            
            if isLoading {
                ProgressView()
            } else {
                List {
                    ForEach(users, id: \.id) { user in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.name ?? "Unknown Name")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.rcaNavy)
                                Text(user.email)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text(user.role.portalName)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.rcaSoftBlue)
                                .foregroundColor(.rcaNavy)
                                .cornerRadius(8)
                            
                            Button(action: {
                                selectedUser = user
                                showingAddEditSheet = true
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.rcaNavy)
                                    .font(.title2)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteUser)
                }
                .listStyle(.insetGrouped)
            }
            
            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        selectedUser = nil
                        showingAddEditSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title.weight(.bold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.rcaNavy)
                            .cornerRadius(28)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 4)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("User Management")
        .onAppear(perform: fetchUsers)
        .sheet(isPresented: $showingAddEditSheet) {
            AddEditUserView(user: selectedUser, onSave: fetchUsers)
        }
    }
    
    func fetchUsers() {
        Task {
            do {
                let fetchedUsers: [User] = try await NetworkManager.shared.getRequest(path: "/users")
                DispatchQueue.main.async {
                    self.users = fetchedUsers
                    self.isLoading = false
                }
            } catch {
                print("Error loading users: \(error)")
                self.isLoading = false
            }
        }
    }
    
    func deleteUser(at offsets: IndexSet) {
        for index in offsets {
            let user = users[index]
            Task {
                do {
                    try await NetworkManager.shared.deleteRequest(path: "/users/\(user.id)")
                    DispatchQueue.main.async {
                        // Optimistically remove or re-fetch
                        fetchUsers()
                    }
                } catch {
                    print("Error deleting user: \(error)")
                }
            }
        }
    }
}

struct AddEditUserView: View {
    let user: User?
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var role: UserRole = .admin
    @State private var isSaving = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Details")) {
                    TextField("Full Name", text: $name)
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    
                    if user == nil {
                        SecureField("Password", text: $password)
                    } else {
                        SecureField("New Password (Leave empty to keep)", text: $password)
                    }
                    
                    Picker("Role", selection: $role) {
                        ForEach(UserRole.allCases, id: \.self) { role in
                            Text(role.portalName).tag(role)
                        }
                    }
                }
            }
            .navigationTitle(user == nil ? "Add User" : "Edit User")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveUser() }
                        .disabled(name.isEmpty || email.isEmpty || (user == nil && password.isEmpty) || isSaving)
                }
            }
            .onAppear {
                if let user = user {
                    name = user.name ?? ""
                    email = user.email
                    role = user.role
                }
            }
        }
    }
    
    func saveUser() {
        isSaving = true
        Task {
            do {
                if let user = user {
                    // Update
                    struct UpdateUserRequest: Encodable {
                        let name: String
                        let email: String
                        let role: String
                        let password: String?
                    }
                    
                    let body = UpdateUserRequest(name: name, email: email, role: role.rawValue, password: password.isEmpty ? nil : password)
                    let _: User = try await NetworkManager.shared.putRequest(path: "/users/\(user.id)", body: body)
                } else {
                    // Create
                    struct CreateUserRequest: Encodable {
                        let name: String
                        let email: String
                        let password: String
                        let role: String
                    }
                    let body = CreateUserRequest(name: name, email: email, password: password, role: role.rawValue)
                    let _: User = try await NetworkManager.shared.postRequest(path: "/users", body: body)
                }
                
                DispatchQueue.main.async {
                    onSave()
                    dismiss()
                }
            } catch {
                print("Error saving user: \(error)")
                isSaving = false
            }
        }
    }
}
