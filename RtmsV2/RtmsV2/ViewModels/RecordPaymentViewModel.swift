import Foundation
import Combine

@MainActor
class RecordPaymentViewModel: ObservableObject {
    @Published var students: [Student] = []
    @Published var directions: [Direction] = []
    @Published var classes: [SchoolClass] = []
    @Published var selectedStudent: Student?
    @Published var selectedClass: SchoolClass?
    @Published var selectedDirection: Direction?
    @Published var amount = ""
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var showingSuccess = false
    @Published var recentPayments: [Payment] = []
    
    struct PaymentRequest: Encodable {
        let studentId: String
        let direction: String
        let amount: Int
    }
    
    var filteredStudents: [Student] {
        var baseList = students
        
        if let selectedClass = selectedClass {
            // Robust matching: "Y1A" matches "Y1 A" or "y1a"
            let targetClass = selectedClass.name.replacingOccurrences(of: " ", with: "").lowercased()
            baseList = baseList.filter { 
                $0.className.replacingOccurrences(of: " ", with: "").lowercased() == targetClass && !$0.paymentStatus
            }
        }
        
        if searchText.isEmpty {
            return baseList
        } else {
            return baseList.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) || 
                $0.studentCard.localizedCaseInsensitiveContains(searchText) 
            }
        }
    }
    
    func fetchInitialData() {
        Task {
            await fetchClasses()
            await fetchStudents()
            await fetchDirections()
            await fetchRecentPayments()
        }
    }
    
    private func fetchClasses() async {
        do {
            let data: [SchoolClass] = try await NetworkManager.shared.getRequest(path: "/classes")
            self.classes = data
            if selectedClass == nil {
                self.selectedClass = data.first
            }
        } catch {
            print("Failed to load classes")
        }
    }
    
    private func fetchRecentPayments() async {
        do {
            let data: [Payment] = try await NetworkManager.shared.getRequest(path: "/payments/recent")
            self.recentPayments = data
        } catch {
            print("Error fetching recent payments: \(error)")
        }
    }
    
    private func fetchStudents() async {
        do {
            let data: [Student] = try await NetworkManager.shared.getRequest(path: "/students")
            self.students = data
        } catch {
            ToastManager.shared.show(message: "We couldn't load the student list. Please check your connection.", type: .error)
        }
    }
    
    private func fetchDirections() async {
        do {
            let data: [Direction] = try await NetworkManager.shared.getRequest(path: "/directions")
            self.directions = data
            
            // Set default direction to KIGALI if exists
            if let kigali = data.first(where: { $0.name.localizedCaseInsensitiveContains("Kigali") }) {
                self.selectedDirection = kigali
            }
        } catch {
            ToastManager.shared.show(message: "We couldn't load directions. Please try again.", type: .error)
        }
    }
    
    func resetForm() {
        selectedStudent = nil
        searchText = ""
        amount = ""
        
        // Reset to default direction (Kigali) if available
        if let kigali = directions.first(where: { $0.name.localizedCaseInsensitiveContains("Kigali") }) {
            self.selectedDirection = kigali
        }
    }
    
    func recordPayment() {
        guard let student = selectedStudent else {
            ToastManager.shared.show(message: "Wait! You haven't selected a student yet.", type: .error)
            return
        }
        
        guard let direction = selectedDirection else {
            ToastManager.shared.show(message: "Please choose where the student is going.", type: .error)
            return
        }
        
        guard let amt = Int(amount), amt > 0 else {
            ToastManager.shared.show(message: "The amount must be a number greater than zero.", type: .error)
            return
        }
        
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
                ToastManager.shared.show(message: "Great! Payment for \(student.name) has been recorded.", type: .success)
                self.resetForm()
                self.fetchInitialData() // Refresh student payment status
            } catch {
                self.isLoading = false
                ToastManager.shared.show(message: "Oops! We couldn't save that. Please check your connection and try again.", type: .error)
            }
        }
    }
}
