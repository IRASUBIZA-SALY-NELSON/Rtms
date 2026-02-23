import Foundation

enum UserRole: String, Codable, CaseIterable {
    case admin = "admin"
    case cfo = "cfo"
    case president = "president"
    case monitor = "monitor"
    
    var portalName: String {
        switch self {
        case .admin: return "Admin Portal"
        case .cfo: return "CFO Portal"
        case .president: return "President's Portal"
        case .monitor: return "Monitor Portal"
        }
    }
}

struct User: Codable, Identifiable, Hashable {
    var id: String { email }
    let email: String
    let role: UserRole
    var name: String?
    
    init(email: String, role: UserRole = .admin, name: String? = nil) {
        self.email = email
        self.role = role
        self.name = name
    }
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct SchoolClass: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id", name
    }
}

struct Direction: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let price: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id", name, price
    }
}

struct Student: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let className: String
    let email: String
    let studentCard: String
    let location: String
    let phoneNumber: String
    let gender: String
    var paymentStatus: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id", name, className = "class", email, studentCard, location, phoneNumber, gender, paymentStatus
    }
}

struct Payment: Codable, Identifiable, Hashable {
    let id: String
    let student: Student
    let direction: String
    let amount: Int
    let recordedBy: User?
    let activity: String?
    let ipAddress: String?
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id", student, direction, amount, recordedBy, activity, ipAddress, timestamp
    }
}

struct GenderCount: Codable, Hashable {
    let gender: String
    let count: Int
}

struct PromotionStats: Codable, Hashable {
    let promotion: String // Year 1, Year 2, Year 3
    let paidCount: Int
    let totalCount: Int
    let percentage: Double
}

struct Analytics: Codable {
    let totalFunded: Double
    let targetAmount: Double
    let paidStudents: Int
    let unpaidStudents: Int
    let totalStudentsCount: Int?
    let directionStats: [DirectionStat]
    let classStats: [ClassStat]
    let genderDistribution: [GenderCount]
    let promotionStats: [PromotionStats]
    
    var remainingBalance: Double { targetAmount - totalFunded }
    var progressPercentage: Double { (totalFunded / targetAmount) * 100 }
}

struct DirectionStat: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let count: Int
}

struct ClassStat: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let count: Int
    let totalAmount: Double
    let targetAmount: Double 
}

struct Notification: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let message: String
    let timestamp: Date
    let isRead: Bool
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id", title, message, timestamp, isRead, type
    }
}
