import SwiftUI

extension Color {
    static let rcaGreen = Color(red: 0.1, green: 0.6, blue: 0.3)
    static let rcaLightGreen = Color(red: 0.9, green: 0.98, blue: 0.94)
    static let rcaWhite = Color.white
    static let rcaGray = Color(white: 0.95)
    
    static let statusPaid = Color.green
    static let statusUnpaid = Color.red
}

struct RCAStyle {
    static let cornerRadius: CGFloat = 12
    static let padding: CGFloat = 16
    static let shadowRadius: CGFloat = 4
}
