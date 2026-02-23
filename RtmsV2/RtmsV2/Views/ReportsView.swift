import SwiftUI
import Charts

struct ReportsView: View {
    @State private var directions: [Direction] = []
    @State private var payments: [Payment] = []
    @State private var isLoading = true
    @State private var selectedDirection: Direction?
    @State private var showingReportDetail = false
    
    var body: some View {
        ZStack {
            Color.rcaBackground.ignoresSafeArea()
            
            if isLoading {
                ProgressView("Loading Financial Data...")
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Summary
                        HStack(spacing: 16) {
                            ReportStatCard(title: "Directions", value: "\(directions.count)", icon: "map.fill", color: .rcaNavy)
                            ReportStatCard(title: "Transactions", value: "\(payments.count)", icon: "clock.arrow.circlepath", color: .blue)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("FINANCIAL REPORTS BY DIRECTION")
                                .font(.system(size: 11, weight: .heavy))
                                .tracking(1)
                                .foregroundColor(.rcaSlate)
                                .padding(.horizontal)
                            
                            ForEach(directions) { direction in
                                DirectionReportCard(
                                    direction: direction,
                                    studentCount: payments.filter { $0.direction == direction.name }.count,
                                    totalAmount: payments.filter { $0.direction == direction.name }.reduce(0) { $0 + $1.amount }
                                ) {
                                    selectedDirection = direction
                                    showingReportDetail = true
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Reports")
        .task {
            await fetchData()
        }
        .sheet(isPresented: $showingReportDetail) {
            if let direction = selectedDirection {
                ReportDetailView(direction: direction, payments: payments.filter { $0.direction == direction.name })
            }
        }
    }
    
    func fetchData() async {
        do {
            async let fetchedDirections: [Direction] = NetworkManager.shared.getRequest(path: "/directions")
            async let fetchedPayments: [Payment] = NetworkManager.shared.getRequest(path: "/payments/logs")
            
            let (dirs, pays) = try await (fetchedDirections, fetchedPayments)
            
            await MainActor.run {
                self.directions = dirs
                self.payments = pays
                self.isLoading = false
            }
        } catch {
            print("Error: \(error)")
            await MainActor.run { self.isLoading = false }
        }
    }
}

struct DirectionReportCard: View {
    let direction: Direction
    let studentCount: Int
    let totalAmount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(direction.name)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.rcaNavy)
                    Text("\(studentCount) Students Paid")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.rcaSlate)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    Text("\(totalAmount) RWF")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.rcaNavy)
                    Text("Total Collected")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(.rcaSoftBlue)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.rcaNavy.opacity(0.3))
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}

struct ReportStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20, weight: .bold))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.rcaNavy)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.rcaSlate)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}

struct ReportDetailView: View {
    let direction: Direction
    @State var payments: [Payment]
    @Environment(\.dismiss) var dismiss
    @State private var isGeneratingPDF = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.rcaBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Document Preview Area
                    ScrollView {
                        VStack(spacing: 0) {
                            ReportDocumentView(direction: direction, payments: payments)
                                .padding()
                                .background(Color.white)
                                .shadow(radius: 5)
                                .padding()
                        }
                    }
                    
                    // Action Footer
                    VStack(spacing: 16) {
                        Button(action: exportPDF) {
                            HStack {
                                if isGeneratingPDF {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "doc.plaintext.fill")
                                    Text("DOWNLOAD PDF REPORT")
                                }
                            }
                            .font(.system(size: 14, weight: .heavy))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.rcaNavy)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isGeneratingPDF)
                        
                        Text("This report contains verified payment records for students assigned to \(direction.name).")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.rcaSlate)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .background(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
                }
            }
            .navigationTitle("\(direction.name) Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    @MainActor
    func exportPDF() {
        guard !payments.isEmpty else {
            ToastManager.shared.show(message: "No payment data to export.", type: .error)
            return
        }
        
        isGeneratingPDF = true
        
        let reportView = ReportDocumentView(direction: direction, payments: payments)
            .environment(\.displayScale, 2.0) // Ensure high resolution
        
        // Target A4 size in points (72 DPI)
        let pageSize = CGSize(width: 595.28, height: 841.89)
        let renderer = ImageRenderer(content: reportView)
        renderer.proposedSize = .init(pageSize)
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(direction.name)_Report.pdf")
        
        renderer.render { size, context in
            var box = CGRect(origin: .zero, size: pageSize)
            guard let pdfContext = CGContext(url as CFURL, mediaBox: &box, nil) else { 
                isGeneratingPDF = false
                return 
            }
            
            pdfContext.beginPDFPage(nil)
            // Center if needed, but the view has a fixed frame
            context(pdfContext)
            pdfContext.endPDFPage()
            pdfContext.closePDF()
            
            self.isGeneratingPDF = false
            
            // Share the PDF
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                
                if let popover = activityVC.popoverPresentationController {
                    popover.sourceView = rootVC.view
                    popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                
                rootVC.present(activityVC, animated: true)
            }
        }
    }
}

struct ReportDocumentView: View {
    let direction: Direction
    let payments: [Payment]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("RWANDA CODING ACADEMY")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.rcaNavy)
                    Text("TRANSPORT MANAGEMENT SYSTEM")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.rcaSlate)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("DATE GENERATED")
                        .font(.system(size: 8, weight: .heavy))
                    Text(Date().formatted(date: .long, time: .shortened))
                        .font(.system(size: 10, weight: .medium))
                }
            }
            .padding(.bottom, 10)
            
            Divider()
            
            // Report Title
            VStack(spacing: 8) {
                Text("STUDENT PAYMENT REPORT")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.rcaNavy)
                
                Text(direction.name.uppercased())
                    .font(.system(size: 12, weight: .heavy))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.rcaNavy)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            .padding(.vertical, 10)
            
            // Summary Table
            HStack {
                ReportSummaryItem(label: "TOTAL STUDENTS", value: "\(payments.count)")
                Divider().frame(height: 30)
                ReportSummaryItem(label: "TOTAL COLLECTED", value: "\(payments.reduce(0) { $0 + $1.amount }) RWF")
                Divider().frame(height: 30)
                ReportSummaryItem(label: "UNIT PRICE", value: "\(direction.price) RWF")
            }
            .padding()
            .background(Color.rcaBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.rcaNavy.opacity(0.1), lineWidth: 1)
            )
            
            // Student Table
            VStack(spacing: 0) {
                // Table Header
                HStack {
                    Text("STUDENT NAME").frame(maxWidth: .infinity, alignment: .leading)
                    Text("CLASS").frame(width: 60, alignment: .leading)
                    Text("AMOUNT").frame(width: 80, alignment: .trailing)
                }
                .font(.system(size: 9, weight: .black))
                .foregroundColor(.rcaSlate)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.rcaNavy.opacity(0.05))
                
                Divider()
                
                ForEach(Array(payments.enumerated()), id: \.element.id) { index, payment in
                    HStack {
                        Text(payment.student.name)
                            .font(.system(size: 10, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(payment.student.className)
                            .font(.system(size: 10, weight: .medium))
                            .frame(width: 60, alignment: .leading)
                            
                        Text("\(payment.amount) RWF")
                            .font(.system(size: 10, weight: .bold))
                            .frame(width: 80, alignment: .trailing)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    
                    if index < payments.count - 1 {
                        Divider().opacity(0.5)
                    }
                }
            }
            .border(Color.rcaNavy.opacity(0.1), width: 1)
            
            Spacer(minLength: 40)
            
            // Footer
            VStack(spacing: 4) {
                Divider()
                HStack {
                    Text("Official RTMS Report")
                        .font(.system(size: 8, weight: .bold))
                    Spacer()
                    Text("Generated by \(NetworkManager.shared.currentUser?.name ?? "Admin")")
                        .font(.system(size: 8, weight: .medium))
                }
                .foregroundColor(.rcaSlate)
                .padding(.top, 4)
            }
        }
        .padding(40)
        .frame(width: 595, height: 842) // A4 Size at 72 DPI
        .background(Color.white)
    }
}


struct ReportSummaryItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .black))
                .foregroundColor(.rcaSlate)
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.rcaNavy)
        }
        .frame(maxWidth: .infinity)
    }
}
