import Foundation

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    private let baseURL = "http://localhost:5000/api" // Use your IP when testing on a device
    
    @Published var token: String? = UserDefaults.standard.string(forKey: "token")
    
    private init() {}
    
    func setToken(_ token: String) {
        self.token = token
        UserDefaults.standard.set(token, forKey: "token")
    }
    
    func logout() {
        self.token = nil
        UserDefaults.standard.removeObject(forKey: "token")
    }
    
    func getRequest<T: Decodable>(path: String) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func postRequest<T: Decodable, U: Encodable>(path: String, body: U) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
