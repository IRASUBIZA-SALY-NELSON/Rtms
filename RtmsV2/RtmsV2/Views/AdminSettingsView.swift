import SwiftUI

@MainActor
struct AdminSettingsView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var classes: [SchoolClass] = []
    @State private var directions: [Direction] = []
    @State private var newClassName = ""
    @State private var newDirectionName = ""
    @State private var newDirectionPrice = ""
    @State private var isLoading = false
    @State private var showingAddStudent = false
    
    struct ClassRequest: Encodable {
        let name: String
    }
    
    struct DirectionRequest: Encodable {
        let name: String
        let price: Int
    }
    
    var body: some View {
        Form {
            // Student Management - Only for Regular Size Class (iPad/Web-style)
            if sizeClass == .regular {
                Section(header: Text("Student Management")) {
                    Button(action: { showingAddStudent = true }) {
                        HStack {
                            Image(systemName: "person.badge.plus.fill")
                            Text("Register New Student")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.rcaNavy)
                    }
                }
            }
            
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
        .sheet(isPresented: $showingAddStudent) {
            AddStudentView(classes: classes)
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
                ToastManager.shared.show(message: "Class added successfully!", type: .success)
                await fetchClasses()
            } catch { 
                ToastManager.shared.show(message: "Failed to add class", type: .error)
                print(error) 
            }
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
                ToastManager.shared.show(message: "Direction added successfully!", type: .success)
                await fetchDirections()
            } catch { 
                ToastManager.shared.show(message: "Failed to add direction", type: .error)
                print(error) 
            }
        }
    }
    
    func deleteClass(at offsets: IndexSet) {
        for index in offsets {
            let cls = classes[index]
            Task {
                do {
                    try await NetworkManager.shared.deleteRequest(path: "/classes/\(cls.id)")
                    DispatchQueue.main.async {
                        classes.remove(at: index)
                        ToastManager.shared.show(message: "Class deleted", type: .success)
                    }
                } catch {
                    ToastManager.shared.show(message: "Failed to delete class", type: .error)
                }
            }
        }
    }
    
    func deleteDirection(at offsets: IndexSet) {
        for index in offsets {
            let dir = directions[index]
            Task {
                do {
                    try await NetworkManager.shared.deleteRequest(path: "/directions/\(dir.id)")
                    DispatchQueue.main.async {
                        directions.remove(at: index)
                        ToastManager.shared.show(message: "Direction deleted", type: .success)
                    }
                } catch {
                    ToastManager.shared.show(message: "Failed to delete direction", type: .error)
                }
            }
        }
    }
}
