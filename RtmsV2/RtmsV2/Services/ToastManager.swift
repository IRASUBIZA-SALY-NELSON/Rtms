import Foundation
import Combine
import SwiftUI

enum ToastType {
    case success
    case error
    case info
}

struct Toast: Identifiable, Equatable {
    let id = UUID()
    let message: String
    let type: ToastType
    var duration: Double = 3.0
    
    static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.id == rhs.id
    }
}

class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var toasts: [Toast] = []
    
    private init() {}
    
    func show(message: String, type: ToastType = .info, duration: Double = 3.0) {
        let toast = Toast(message: message, type: type, duration: duration)
        
        DispatchQueue.main.async {
            // Add new toast to the top (or bottom of the stack)
            withAnimation(.spring()) {
                self.toasts.append(toast)
            }
            
            // Remove after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation(.spring()) {
                    self.toasts.removeAll(where: { $0.id == toast.id })
                }
            }
        }
    }
}
