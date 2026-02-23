import SwiftUI

struct RecordPaymentView: View {
    @StateObject private var viewModel = RecordPaymentViewModel()
    @State private var showSuccessToast = false
    
    var body: some View {
        ZStack {
            Color.rcaBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Section Header (Refined)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("FINANCIAL CONTRIBUTION")
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(1)
                            .foregroundColor(.rcaSlate)
                        Text("Select a class and student to record a payment.")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.rcaNavy)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Class Selection Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.classes) { schoolClass in
                                Button(action: {
                                    viewModel.selectedClass = schoolClass
                                }) {
                                    Text(schoolClass.name)
                                        .font(.system(size: 13, weight: .bold))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(viewModel.selectedClass?.id == schoolClass.id ? Color.rcaNavy : Color.white)
                                        .foregroundColor(viewModel.selectedClass?.id == schoolClass.id ? .white : .rcaSlate)
                                        .cornerRadius(20)
                                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Main Entry Form
                    RCACard {
                        VStack(spacing: 24) {
                            // Student Selection
                            VStack(alignment: .leading, spacing: 10) {
                                Text("STUDENT SELECTION")
                                    .font(.system(size: 10, weight: .heavy))
                                    .tracking(0.5)
                                    .foregroundColor(.rcaSlate)
                                
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.rcaNavy)
                                        .font(.system(size: 14, weight: .bold))
                                    TextField("SEARCH BY NAME OR ID", text: $viewModel.searchText)
                                        .font(.system(size: 13, weight: .bold))
                                    
                                    if !viewModel.searchText.isEmpty {
                                        Button(action: {
                                            withAnimation {
                                                viewModel.searchText = ""
                                                viewModel.selectedStudent = nil
                                            }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.rcaSlate.opacity(0.5))
                                                .font(.system(size: 16))
                                        }
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .padding()
                                .background(Color.rcaInputBackground)
                                .cornerRadius(12)
                            }
                            
                            if !viewModel.filteredStudents.isEmpty {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(viewModel.filteredStudents) { student in
                                        Button(action: {
                                            withAnimation(.spring()) {
                                                viewModel.selectedStudent = student
                                                viewModel.searchText = student.name
                                            }
                                        }) {
                                            VStack(alignment: .leading, spacing: 0) {
                                                HStack {
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        HighlightedText(text: student.name, highlight: viewModel.searchText)
                                                            .font(.system(size: 14, weight: .bold))
                                                        Text("\(student.className) • \(student.studentCard)")
                                                            .font(.system(size: 11, weight: .medium))
                                                            .foregroundColor(.rcaSlate)
                                                    }
                                                    Spacer()
                                                    if viewModel.selectedStudent?.id == student.id {
                                                        Image(systemName: "checkmark.seal.fill")
                                                            .foregroundColor(.rcaNavy)
                                                    }
                                                }
                                                .padding(.vertical, 12)
                                                
                                                if student.id != viewModel.filteredStudents.last?.id {
                                                    Divider()
                                                }
                                            }
                                        }
                                        .foregroundColor(.primary)
                                    }
                                }
                                .padding(.top, -10)
                            }
                            
                            // Direction & Amount
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("DIRECTION")
                                        .font(.system(size: 10, weight: .heavy))
                                        .tracking(0.5)
                                        .foregroundColor(.rcaSlate)
                                    
                                    Menu {
                                        Button("None", action: { viewModel.selectedDirection = nil })
                                        ForEach(viewModel.directions) { dir in
                                            Button {
                                                viewModel.selectedDirection = dir
                                            } label: {
                                                HStack {
                                                    Text(dir.name)
                                                    Spacer()
                                                    Text("\(dir.price) RWF")
                                                        .font(.caption)
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(viewModel.selectedDirection?.name.uppercased() ?? "CHOOSE")
                                                .font(.system(size: 13, weight: .heavy))
                                                .foregroundColor(viewModel.selectedDirection == nil ? .rcaSlate : .rcaNavy)
                                            Spacer()
                                            Image(systemName: "chevron.up.down")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.rcaNavy)
                                        }
                                        .padding()
                                        .background(Color.rcaInputBackground)
                                        .cornerRadius(12)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("AMOUNT (RWF)")
                                        .font(.system(size: 10, weight: .heavy))
                                        .tracking(0.5)
                                        .foregroundColor(.rcaSlate)
                                    
                                    TextField("0", text: $viewModel.amount)
                                        .font(.system(size: 15, weight: .heavy))
                                        .keyboardType(.numberPad)
                                        .padding()
                                        .background(Color.rcaInputBackground)
                                        .cornerRadius(12)
                                }
                            }
                            
                            RCAButton(title: "Record Contribution", isLoading: viewModel.isLoading) {
                                Task {
                                    viewModel.recordPayment()
                                }
                            }
                            .padding(.top, 10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Recent Submissions (Monitor Mini-Log)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("YOUR RECENT SUBMISSIONS")
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(1)
                            .foregroundColor(.rcaSlate)
                            .padding(.horizontal)
                        
                        if viewModel.recentPayments.isEmpty {
                            Text("New contributions will appear here once submitted.")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(viewModel.recentPayments) { payment in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(payment.student.name)
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.rcaNavy)
                                            Text(payment.timestamp, style: .time)
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundColor(.rcaSlate)
                                        }
                                        Spacer()
                                        Text("\(payment.amount) RWF")
                                            .font(.system(size: 14, weight: .heavy))
                                            .foregroundColor(.rcaNavy)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.04), radius: 5)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Record Payment")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let user = NetworkManager.shared.currentUser {
                    Text(user.role.portalName)
                        .font(.system(size: 9, weight: .heavy))
                        .tracking(0.5)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.rcaNavy)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
            }
        }
        .onAppear {
            Task {
                viewModel.fetchInitialData()
            }
        }
    }
}

struct HighlightedText: View {
    let text: String
    let highlight: String

    var body: some View {
        if highlight.isEmpty {
            Text(text)
        } else {
            // Regex-based approach for highlighting
            // Note: Simple split doesn't handle casing well or multi-char matches perfectly in SwiftUI Text composition
            // but for a smooth UI we can use a more robust regex-based approach or split/join.
            
            if let range = text.range(of: highlight, options: .caseInsensitive) {
                let prefix = String(text[..<range.lowerBound])
                let match = String(text[range])
                let suffix = String(text[range.upperBound...])
                
                Text("\(Text(prefix))\(Text(match).foregroundColor(.rcaSoftBlue).underline())\(Text(suffix))")
            } else {
                Text(text)
            }
        }
    }
}
