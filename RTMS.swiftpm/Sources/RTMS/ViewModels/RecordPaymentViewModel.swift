import Foundation
import Combine

@MainActor
class RecordPaymentViewModel: ObservableObject {
    @Published var students: [Student] = []
    @Published var directions: [Direction] = []
    @Published var selectedStudent: Student?
    @Published var selectedDirection: Direction?
    @Published var amount = ""
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var showingSuccess = false
    @Published var errorMessage: String?
    
    struct PaymentRequest: Encodable {
        let studentId: String
        let direction: String
        let amount: Int
    }
    
    var filteredStudents: [Student] {
        if searchText.isEmpty {
            return students
        } else {
            return students.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) || 
                $0.studentCard.localizedCaseInsensitiveContains(searchText) 
            }
        }
    }
    
    func fetchData() {
        Task {
            await fetchStudents()
            await fetchDirections()
        }
    }
    
    private func fetchStudents() async {
        do {
            let data: [Student] = try await NetworkManager.shared.getRequest(path: "/students")
            self.students = data
        } catch {
            self.errorMessage = "Failed to load students"
        }
    }
    
    private func fetchDirections() async {
        do {
            let data: [Direction] = try await NetworkManager.shared.getRequest(path: "/directions")
            self.directions = data
        } catch {
            self.errorMessage = "Failed to load directions"
        }
    }
    
    func resetForm() {
        selectedStudent = nil
        selectedDirection = nil
        amount = ""
        errorMessage = nil
    }
    
    func recordPayment() {
        guard let student = selectedStudent, let direction = selectedDirection, let amt = Int(amount) else { return }
        isLoading = true
        
        Task {
            do {
                let request = PaymentRequest(
                    studentId: student.id,
                    direction: direction.name,
                    amount: amt
                )
                let _: Payment = try await NetworkManager.shared.postRequest(
                    path: "/payments",
                    body: request
                )
                self.isLoading = false
                self.showingSuccess = true
                self.fetchData() // Refresh student payment status
            } catch {
                self.isLoading = false
                self.errorMessage = "Failed to record payment"
            }
        }
    }
}
