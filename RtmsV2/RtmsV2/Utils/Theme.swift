import SwiftUI

extension Color {
    static let rcaNavy = Color(hex: "#1D2B53")
    static let rcaBackground = Color(hex: "#F8FAFC")
    static let rcaInputBackground = Color(hex: "#F1F5F9")
    
    // Pastel Palette from reference image
    static let rcaLavender = Color(hex: "#DEE2F2")
    static let rcaSoftBlue = Color(hex: "#E0E7FF")
    static let rcaSoftGray = Color(hex: "#F3F4F6")
    static let rcaSlate = Color(hex: "#64748B")
    
    // Legacy Colors (Restored for compatibility)
    static let rcaGray = Color(hex: "#F1F5F9")
    static let rcaGreen = Color(hex: "#1D2B53") // Navy fallback to match new theme
    
    static let statusPaid = Color.green
    static let statusUnpaid = Color.red
}

struct RCAStyle {
    static let cornerRadius: CGFloat = 12
    static let padding: CGFloat = 16
    static let shadowRadius: CGFloat = 8
}
