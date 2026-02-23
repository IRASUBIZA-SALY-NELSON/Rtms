import SwiftUI

struct RCAButton: View {
    var title: String
    var icon: String? = nil
    var color: Color = .rcaGreen
    var isLoading: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                    }
                    Text(title)
                        .bold()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(RCAStyle.cornerRadius)
            .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
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
