import SwiftUI

@MainActor
struct AdminSettingsView: View {
    @State private var classes: [SchoolClass] = []
    @State private var directions: [Direction] = []
    @State private var newClassName = ""
    @State private var newDirectionName = ""
    @State private var newDirectionPrice = ""
    @State private var isLoading = false
    
    struct ClassRequest: Encodable {
        let name: String
    }
    
    struct DirectionRequest: Encodable {
        let name: String
        let price: Int
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Manage Directions")) {
                    ForEach(directions) { dir in
                        HStack {
                            Text(dir.name)
                            Spacer()
                            Text("\(dir.price) RWF")
                        }
                    }
                    .onDelete(perform: deleteDirection)
                    
                    VStack {
                        TextField("Direction Name", text: $newDirectionName)
                        TextField("Price", text: $newDirectionPrice)
                            .keyboardType(.numberPad)
                        Button("Add Direction") {
                            addDirection()
                        }
                        .foregroundColor(.green)
                        .disabled(newDirectionName.isEmpty || newDirectionPrice.isEmpty)
                    }
                }
                
                Section(header: Text("Manage Classes")) {
                    ForEach(classes) { cls in
                        Text(cls.name)
                    }
                    .onDelete(perform: deleteClass)
                    
                    VStack {
                        TextField("Class Name (e.g. Year 1A)", text: $newClassName)
                        Button("Add Class") {
                            addClass()
                        }
                        .foregroundColor(.green)
                        .disabled(newClassName.isEmpty)
                    }
                }
                
                Section {
                    Button("Logout") {
                        NetworkManager.shared.logout()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .onAppear(perform: fetchData)
        }
    }
    
    func fetchData() {
        Task {
            await fetchClasses()
            await fetchDirections()
        }
    }
    
    func fetchClasses() async {
        do {
            let data: [SchoolClass] = try await NetworkManager.shared.getRequest(path: "/classes")
            self.classes = data
        } catch { print(error) }
    }
    
    func fetchDirections() async {
        do {
            let data: [Direction] = try await NetworkManager.shared.getRequest(path: "/directions")
            self.directions = data
        } catch { print(error) }
    }
    
    func addClass() {
        Task {
            do {
                let request = ClassRequest(name: newClassName)
                let _: SchoolClass = try await NetworkManager.shared.postRequest(path: "/classes", body: request)
                newClassName = ""
                await fetchClasses()
            } catch { print(error) }
        }
    }
    
    func addDirection() {
        guard let price = Int(newDirectionPrice) else { return }
        Task {
            do {
                let request = DirectionRequest(name: newDirectionName, price: price)
                let _: Direction = try await NetworkManager.shared.postRequest(path: "/directions", body: request)
                newDirectionName = ""
                newDirectionPrice = ""
                await fetchDirections()
            } catch { print(error) }
        }
    }
    
    func deleteClass(at offsets: IndexSet) {
        // Implement delete API call if needed
    }
    
    func deleteDirection(at offsets: IndexSet) {
        // Implement delete API call if needed
    }
}
