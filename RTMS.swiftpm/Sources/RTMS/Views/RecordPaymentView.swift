import SwiftUI

struct RecordPaymentView: View {
    @StateObject private var viewModel = RecordPaymentViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.selectedStudent == nil {
                    // Student selection list
                    List(viewModel.filteredStudents) { student in
                        NavigationLink(destination: StudentDetailView(student: student)) {
                            StudentRow(student: student)
                        }
                        .swipeActions {
                            if !student.paymentStatus {
                                Button {
                                    viewModel.selectedStudent = student
                                } label: {
                                    Label("Pay", systemImage: "creditcard.fill")
                                }
                                .tint(.rcaGreen)
                            }
                        }
                    }
                    .searchable(text: $viewModel.searchText, prompt: "Search student or card...")
                } else {
                    // Payment form
                    Form {
                        Section(header: Text("Student Details")) {
                            RCACard {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(viewModel.selectedStudent?.name ?? "").font(.headline)
                                    Text(viewModel.selectedStudent?.className ?? "").font(.subheadline).foregroundColor(.secondary)
                                    Text(viewModel.selectedStudent?.studentCard ?? "").font(.caption).foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .listRowInsets(EdgeInsets())
                            .padding(.vertical, 8)
                        }
                        
                        Section(header: Text("Transport Details")) {
                            Picker("Direction", selection: $viewModel.selectedDirection) {
                                Text("Select Direction").tag(nil as Direction?)
                                ForEach(viewModel.directions) { dir in
                                    Text("\(dir.name) (\(dir.price) RWF)").tag(dir as Direction?)
                                }
                            }
                            .onChange(of: viewModel.selectedDirection) { oldValue, newValue in
                                if let price = newValue?.price {
                                    viewModel.amount = "\(price)"
                                }
                            }
                            
                            TextField("Amount", text: $viewModel.amount)
                                .keyboardType(.numberPad)
                        }
                        
                        RCAButton(
                            title: "Record Payment",
                            icon: "checkmark.circle.fill",
                            isLoading: viewModel.isLoading,
                            action: viewModel.recordPayment
                        )
                        .padding(.vertical)
                        .listRowBackground(Color.clear)
                        
                        Button("Cancel") {
                            viewModel.resetForm()
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .navigationTitle(viewModel.selectedStudent == nil ? "Select Student" : "Record Payment")
            .onAppear(perform: viewModel.fetchData)
            .alert("Success", isPresented: $viewModel.showingSuccess) {
                Button("OK") { viewModel.resetForm() }
            } message: {
                Text("Payment has been recorded and an email notification has been sent.")
            }
        }
    }
}

struct StudentRow: View {
    let student: Student
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(student.name).font(.headline)
                Text("\(student.className) - \(student.studentCard)").font(.subheadline).foregroundColor(.secondary)
            }
            Spacer()
            if student.paymentStatus {
                Image(systemName: "checkmark.circle.fill").foregroundColor(.rcaGreen)
            } else {
                Text("Unpaid")
                    .font(.caption)
                    .padding(5)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(5)
            }
        }
    }
}
