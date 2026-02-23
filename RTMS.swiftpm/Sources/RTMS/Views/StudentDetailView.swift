import SwiftUI

struct StudentDetailView: View {
    let student: Student
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.rcaGreen)
                    
                    Text(student.name)
                        .font(.title)
                        .bold()
                    
                    Text(student.className)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Status Badge
                HStack {
                    Text(student.paymentStatus ? "PAID" : "UNPAID")
                        .font(.caption)
                        .bold()
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(student.paymentStatus ? Color.rcaGreen : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
                
                // Info Section
                RCACard {
                    VStack(alignment: .leading, spacing: 15) {
                        InfoRow(icon: "creditcard", label: "Student Card", value: student.studentCard)
                        Divider()
                        InfoRow(icon: "mappin.and.ellipse", label: "Location", value: student.location)
                        Divider()
                        InfoRow(icon: "phone", label: "Phone", value: student.phoneNumber)
                        Divider()
                        InfoRow(icon: "envelope", label: "Email", value: student.email)
                        Divider()
                        InfoRow(icon: "person.text.rectangle", label: "Gender", value: student.gender)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationTitle("Student Profile")
        .background(Color.rcaGray.ignoresSafeArea())
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.rcaGreen)
                .frame(width: 25)
            
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
        }
    }
}
