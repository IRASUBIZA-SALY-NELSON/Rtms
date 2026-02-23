import SwiftUI

struct UnpaidStudentsView: View {
    @State private var students: [Student] = []
    @State private var classes: [SchoolClass] = []
    @State private var isLoading = true
    @State private var selectedClass: String = "All Classes"
    @State private var showingFilters = false
    @Environment(\.dismiss) var dismiss
    
    var filteredStudents: [Student] {
        if selectedClass == "All Classes" {
            return students
        } else {
            return students.filter { $0.className == selectedClass }
        }
    }
    
    var unpaidStats: (count: Int, total: Int, percentage: Double) {
        let count = filteredStudents.count
        let total = students.count
        let percentage = total > 0 ? (Double(count) / Double(total)) * 100 : 0
        return (count, total, percentage)
    }
    
    var body: some View {
        ZStack {
            Color.rcaBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Statistics Header
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("UNPAID STUDENTS")
                                .font(.system(size: 11, weight: .heavy))
                                .tracking(1)
                                .foregroundColor(.rcaSlate)
                            Text(selectedClass)
                                .font(.system(size: 20, weight: .heavy))
                                .foregroundColor(.rcaNavy)
                        }
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .stroke(Color.orange.opacity(0.1), lineWidth: 4)
                                .frame(width: 50, height: 50)
                            Circle()
                                .trim(from: 0, to: unpaidStats.percentage / 100)
                                .stroke(Color.orange, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 50, height: 50)
                                .rotationEffect(.degrees(-90))
                            
                            Text("\(Int(unpaidStats.percentage))%")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundColor(.orange)
                        }
                    }
                    
                    HStack(spacing: 20) {
                        HStack(spacing: 6) {
                            Circle().fill(Color.orange).frame(width: 8, height: 8)
                            Text("\(unpaidStats.count) Pending")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.rcaNavy)
                        }
                        
                        Text("\(unpaidStats.total) Total Unpaid")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.rcaSlate)
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 10, y: 5)
                
                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if filteredStudents.isEmpty {
                    Spacer()
                    ContentUnavailableView(
                        "All Caught Up!",
                        systemImage: "checkmark.seal.fill",
                        description: Text("No unpaid students found for \(selectedClass).")
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(filteredStudents) { student in
                            NavigationLink(destination: StudentDetailView(student: student)) {
                                HStack(spacing: 15) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.rcaInputBackground)
                                            .frame(width: 44, height: 44)
                                        Text(String(student.name.prefix(1)))
                                            .font(.system(size: 16, weight: .heavy))
                                            .foregroundColor(.rcaNavy)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(student.name)
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(.rcaNavy)
                                        Text("\(student.className) • \(student.location)")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.rcaSlate)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.rcaSoftGray)
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .navigationTitle("Unpaid List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if !filteredStudents.isEmpty {
                        ShareLink(item: generateCSV(), preview: SharePreview("Unpaid Students List")) {
                            Label("Export", systemImage: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    
                    Menu {
                        Button("All Classes") { selectedClass = "All Classes" }
                        Divider()
                        ForEach(classes) { cls in
                            Button(cls.name) { selectedClass = cls.name }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.rcaNavy)
                            .font(.system(size: 18))
                    }
                }
            }
        }
        .onAppear {
            fetchData()
        }
    }
    
    func generateCSV() -> String {
        var csv = "Student Name,Class,Direction,Student Card\n"
        for student in filteredStudents {
            let line = "\(student.name),\(student.className),\(student.location),\(student.studentCard)\n"
            csv.append(line)
        }
        return csv
    }
    
    func fetchData() {
        Task {
            do {
                // Fetch all students with paid=false
                let students: [Student] = try await NetworkManager.shared.getRequest(path: "/students?paid=false")
                let classes: [SchoolClass] = try await NetworkManager.shared.getRequest(path: "/classes")
                
                DispatchQueue.main.async {
                    self.students = students
                    self.classes = classes
                    self.isLoading = false
                }
            } catch {
                print("Error: \(error)")
                self.isLoading = false
            }
        }
    }
}
