import SwiftUI

struct StudentDetailView: View {
    let student: Student
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 12) {
                    Circle()
                        .fill(Color.rcaSoftBlue)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.rcaNavy)
                        )
                    
                    VStack(spacing: 4) {
                        Text(student.name)
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundColor(.rcaNavy)
                        
                        Text(student.className)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.rcaSlate)
                            .textCase(.uppercase)
                            .tracking(1)
                    }
                }
                .padding(.top, 30)
                
                // Status Badge
                HStack {
                    Text(student.paymentStatus ? "PAYMENT COMPLETED" : "PAYMENT PENDING")
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(0.5)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(student.paymentStatus ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        .foregroundColor(student.paymentStatus ? .green : .red)
                        .cornerRadius(8)
                }
                
                // Info Section
                RCACard {
                    VStack(alignment: .leading, spacing: 20) {
                        InfoRow(icon: "creditcard.fill", label: "STUDENT CARD ID", value: student.studentCard)
                        Divider()
                        InfoRow(icon: "mappin.circle.fill", label: "CURRENT LOCATION", value: student.location)
                        Divider()
                        InfoRow(icon: "phone.fill", label: "PHONE NUMBER", value: student.phoneNumber)
                        Divider()
                        InfoRow(icon: "envelope.fill", label: "OFFICIAL EMAIL", value: student.email)
                        Divider()
                        InfoRow(icon: "person.fill", label: "GENDER", value: student.gender)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationTitle("Student Profile")
        .background(Color.rcaBackground.ignoresSafeArea())
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.rcaNavy.opacity(0.05))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(.rcaNavy)
                        .font(.system(size: 12, weight: .bold))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundColor(.rcaSlate)
                    .tracking(0.5)
                Text(value)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.rcaNavy)
            }
        }
    }
}
