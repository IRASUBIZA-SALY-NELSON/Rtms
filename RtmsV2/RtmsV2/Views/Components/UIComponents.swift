import SwiftUI

struct RCAButton: View {
    var title: String
    var icon: String? = nil
    var color: Color = .rcaNavy
    var isLoading: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                    }
                    Text(title)
                        .font(.system(size: 14, weight: .heavy))
                        .textCase(.uppercase)
                        .tracking(1.2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: color.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .disabled(isLoading)
    }
}

struct RCACard<Content: View>: View {
    var content: Content
    var backgroundColor: Color = .white
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(backgroundColor)
            .cornerRadius(RCAStyle.cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
