import SwiftUI

struct ContactUsView: View {
    @State private var subject = "Payment Issue"
    @State private var message = ""
    @State private var isLoading = false
    @Environment(\.dismiss) var dismiss
    
    let subjects = ["Payment Issue", "Account Access", "Technical Bug", "Feature Request", "Other"]
    
    var body: some View {
        ZStack {
            Color.rcaBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("GET IN TOUCH")
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(1)
                            .foregroundColor(.rcaSlate)
                        Text("Have a question or feedback? We'd love to hear from you.")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.rcaNavy)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Contact Form
                    RCACard {
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("SUBJECT")
                                    .font(.system(size: 10, weight: .heavy))
                                    .tracking(0.5)
                                    .foregroundColor(.rcaSlate)
                                
                                Picker("Select Subject", selection: $subject) {
                                    ForEach(subjects, id: \.self) { sub in
                                        Text(sub).tag(sub)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.rcaInputBackground)
                                .cornerRadius(12)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("YOUR MESSAGE")
                                    .font(.system(size: 10, weight: .heavy))
                                    .tracking(0.5)
                                    .foregroundColor(.rcaSlate)
                                
                                TextEditor(text: $message)
                                    .font(.system(size: 14, weight: .medium))
                                    .frame(minHeight: 120)
                                    .padding(8)
                                    .background(Color.rcaInputBackground)
                                    .cornerRadius(12)
                            }
                            
                            RCAButton(title: "Send Message", isLoading: isLoading) {
                                sendMessage()
                            }
                            .padding(.top, 10)
                            .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Direct Contact Info
                    VStack(spacing: 20) {
                        ContactInfoCard(title: "Email Support", value: "nelson.irasubiza@rca.ac.rw", icon: "envelope.fill")
                        ContactInfoCard(title: "Call Us", value: "+250 798 963 223", icon: "phone.fill")
                        ContactInfoCard(title: "Office", value: "RCA Campus, Nyabihu", icon: "mappin.and.ellipse")
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Contact Us")
    }
    
    func sendMessage() {
        isLoading = true
        // Simulate sending a message
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            ToastManager.shared.show(message: "Your message has been sent successfully!", type: .success)
            dismiss()
        }
    }
}

struct ContactInfoCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.rcaNavy)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(0.5)
                    .foregroundColor(.rcaSlate)
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.rcaNavy)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 5)
    }
}
