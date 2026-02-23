import SwiftUI

struct AddStudentView: View {
    let classes: [SchoolClass]
    @Environment(\.dismiss) var dismiss
    @State private var isLoading = false
    
    // Form Fields
    @State private var name = ""
    @State private var selectedClass = ""
    @State private var email = ""
    @State private var studentCard = ""
    @State private var location = ""
    @State private var phoneNumber = ""
    @State private var selectedGender = "Male"
    
    let genders = ["Male", "Female", "Other"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.rcaBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("STUDENT REGISTRATION")
                                .font(.system(size: 11, weight: .heavy))
                                .tracking(1)
                                .foregroundColor(.rcaSlate)
                            Text("Enter all required details to register a new student in the system.")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.rcaNavy)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        RCACard {
                            VStack(spacing: 20) {
                                AdminInputField(title: "FULL NAME", placeholder: "e.g. John Doe", text: $name)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("ASSIGNED CLASS")
                                        .font(.system(size: 10, weight: .heavy))
                                        .tracking(0.5)
                                        .foregroundColor(.rcaSlate)
                                    
                                    Picker("Select Class", selection: $selectedClass) {
                                        Text("Select Class").tag("")
                                        ForEach(classes) { cls in
                                            Text(cls.name).tag(cls.name)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.rcaInputBackground)
                                    .cornerRadius(12)
                                }
                                
                                AdminInputField(title: "OFFICIAL EMAIL", placeholder: "e.g. john@rca.ac.rw", text: $email, keyboardType: .emailAddress)
                                AdminInputField(title: "STUDENT CARD ID", placeholder: "e.g. RCA-2026-001", text: $studentCard)
                                
                                HStack(spacing: 15) {
                                    AdminInputField(title: "TELEPHONE", placeholder: "e.g. 078...", text: $phoneNumber, keyboardType: .phonePad)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("GENDER")
                                            .font(.system(size: 10, weight: .heavy))
                                            .tracking(0.5)
                                            .foregroundColor(.rcaSlate)
                                        
                                        Picker("Gender", selection: $selectedGender) {
                                            ForEach(genders, id: \.self) { gender in
                                                Text(gender).tag(gender)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.rcaInputBackground)
                                        .cornerRadius(12)
                                    }
                                }
                                
                                AdminInputField(title: "HOME LOCATION", placeholder: "e.g. Kigali, Kicukiro", text: $location)
                                
                                RCAButton(title: "Register Student", isLoading: isLoading) {
                                    registerStudent()
                                }
                                .padding(.top, 10)
                                .disabled(!isFormValid)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("New Student")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.rcaNavy)
                }
            }
        }
    }
    
    var isFormValid: Bool {
        !name.isEmpty && !selectedClass.isEmpty && !email.isEmpty && !studentCard.isEmpty && !location.isEmpty && !phoneNumber.isEmpty
    }
    
    struct StudentRequest: Encodable {
        let name: String
        let `class`: String
        let email: String
        let studentCard: String
        let location: String
        let phoneNumber: String
        let gender: String
    }
    
    func registerStudent() {
        isLoading = true
        Task {
            do {
                let request = StudentRequest(
                    name: name,
                    class: selectedClass,
                    email: email,
                    studentCard: studentCard,
                    location: location,
                    phoneNumber: phoneNumber,
                    gender: selectedGender
                )
                
                let _: Student = try await NetworkManager.shared.postRequest(path: "/students", body: request)
                
                DispatchQueue.main.async {
                    isLoading = false
                    ToastManager.shared.show(message: "Student registered successfully!", type: .success)
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

struct AdminInputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 10, weight: .heavy))
                .tracking(0.5)
                .foregroundColor(.rcaSlate)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 14, weight: .bold))
                .keyboardType(keyboardType)
                .padding()
                .background(Color.rcaInputBackground)
                .cornerRadius(12)
                .autocapitalization(.none)
        }
    }
}
