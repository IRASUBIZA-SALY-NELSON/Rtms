import Foundation

struct User: Codable {
    let email: String
}

struct AuthResponse: Codable {
    let token: String
    let user: User
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
    let paymentStatus: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id", name, className = "class", email, studentCard, location, phoneNumber, gender, paymentStatus
    }
}

struct Payment: Codable, Identifiable, Hashable {
    let id: String
    let student: Student
    let direction: String
    let amount: Int
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id", student, direction, amount, timestamp
    }
}

struct Analytics: Codable {
    struct Stat: Codable {
        let _id: String
        let count: Int
    }
    struct ClassStat: Codable {
        let name: String
        let count: Int
    }
    struct Summary: Codable {
        let paidCount: Int
        let unpaidCount: Int
    }
    
    let directionStats: [Stat]
    let classStats: [ClassStat]
    let summary: Summary
}
