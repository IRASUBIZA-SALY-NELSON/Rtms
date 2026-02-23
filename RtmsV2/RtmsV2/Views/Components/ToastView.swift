import SwiftUI

struct ToastView: View {
    let toast: Toast
    @State private var progress: CGFloat = 1.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(backgroundColor.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: iconName)
                        .foregroundColor(backgroundColor)
                        .font(.system(size: 14, weight: .bold))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(toast.type == .success ? "SUCCESS" : (toast.type == .error ? "ERROR" : "INFO"))
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(backgroundColor)
                        .tracking(1)
                    
                    Text(toast.message)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.rcaNavy)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            
            // Progress Bar
            GeometryReader { geo in
                Rectangle()
                    .fill(backgroundColor.opacity(0.3))
                    .frame(width: geo.size.width * progress)
            }
            .frame(height: 3)
        }
        .frame(width: 280)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(backgroundColor.opacity(0.1), lineWidth: 1)
        )
        .onAppear {
            withAnimation(.linear(duration: toast.duration)) {
                progress = 0
            }
        }
    }
    
    private var iconName: String {
        switch toast.type {
        case .success: return "checkmark"
        case .error: return "xmark"
        case .info: return "info"
        }
    }
    
    private var backgroundColor: Color {
        switch toast.type {
        case .success: return Color.green
        case .error: return Color.red
        case .info: return Color.blue
        }
    }
}
