import SwiftUI

struct ClassManagementView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("Manage", selection: $selectedTab) {
                Text("Classes").tag(0)
                Text("Directions").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            .background(Color.white)
            
            if selectedTab == 0 {
                ClassesListView()
            } else {
                DirectionsListView()
            }
        }
        .background(Color.rcaBackground.ignoresSafeArea())
        .navigationTitle("Class Management")
    }
}

// MARK: - Classes List
struct ClassesListView: View {
    @State private var classes: [SchoolClass] = []
    @State private var isLoading = true
    @State private var showingAddEditSheet = false
    @State private var selectedClass: SchoolClass?
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
            } else {
                List {
                    ForEach(classes) { cls in
                        HStack {
                            Text(cls.name)
                                .font(.headline)
                                .foregroundColor(.rcaNavy)
                            
                            Spacer()
                            
                            Button(action: {
                                selectedClass = cls
                                showingAddEditSheet = true
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.rcaNavy)
                                    .font(.title2)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    .onDelete(perform: deleteClass)
                }
                .listStyle(.insetGrouped)
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        selectedClass = nil
                        showingAddEditSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title.weight(.bold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.rcaNavy)
                            .cornerRadius(28)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 4)
                    }
                    .padding()
                }
            }
        }
        .onAppear(perform: fetchClasses)
        .sheet(isPresented: $showingAddEditSheet) {
            AddEditClassView(cls: selectedClass, onSave: fetchClasses)
        }
    }
    
    func fetchClasses() {
        Task {
            do {
                let data: [SchoolClass] = try await NetworkManager.shared.getRequest(path: "/classes")
                DispatchQueue.main.async {
                    self.classes = data
                    self.isLoading = false
                }
            } catch { print(error) }
        }
    }
    
    func deleteClass(at offsets: IndexSet) {
        for index in offsets {
            let cls = classes[index]
            Task {
                try? await NetworkManager.shared.deleteRequest(path: "/classes/\(cls.id)")
                DispatchQueue.main.async { fetchClasses() }
            }
        }
    }
}

// MARK: - Directions List
struct DirectionsListView: View {
    @State private var directions: [Direction] = []
    @State private var isLoading = true
    @State private var showingAddEditSheet = false
    @State private var selectedDirection: Direction?
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
            } else {
                List {
                    ForEach(directions) { dir in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(dir.name)
                                    .font(.headline)
                                    .foregroundColor(.rcaNavy)
                                Text("\(dir.price) RWF")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                selectedDirection = dir
                                showingAddEditSheet = true
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.rcaNavy)
                                    .font(.title2)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    .onDelete(perform: deleteDirection)
                }
                .listStyle(.insetGrouped)
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        selectedDirection = nil
                        showingAddEditSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title.weight(.bold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.rcaNavy)
                            .cornerRadius(28)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 4)
                    }
                    .padding()
                }
            }
        }
        .onAppear(perform: fetchDirections)
        .sheet(isPresented: $showingAddEditSheet) {
            AddEditDirectionView(direction: selectedDirection, onSave: fetchDirections)
        }
    }
    
    func fetchDirections() {
        Task {
            do {
                let data: [Direction] = try await NetworkManager.shared.getRequest(path: "/directions")
                DispatchQueue.main.async {
                    self.directions = data
                    self.isLoading = false
                }
            } catch { print(error) }
        }
    }
    
    func deleteDirection(at offsets: IndexSet) {
        for index in offsets {
            let dir = directions[index]
            Task {
                try? await NetworkManager.shared.deleteRequest(path: "/directions/\(dir.id)")
                DispatchQueue.main.async { fetchDirections() }
            }
        }
    }
}

// MARK: - Add/Edit Sheets
struct AddEditClassView: View {
    let cls: SchoolClass?
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Class Name (e.g. Y1A)", text: $name)
            }
            .navigationTitle(cls == nil ? "Add Class" : "Edit Class")
            .toolbar {
                Button("Save") {
                    Task {
                        if let cls = cls {
                            struct Req: Encodable { let name: String }
                            let _: SchoolClass = try await NetworkManager.shared.putRequest(path: "/classes/\(cls.id)", body: Req(name: name))
                        } else {
                            struct Req: Encodable { let name: String }
                            let _: SchoolClass = try await NetworkManager.shared.postRequest(path: "/classes", body: Req(name: name))
                        }
                        DispatchQueue.main.async {
                            onSave()
                            dismiss()
                        }
                    }
                }
                .disabled(name.isEmpty)
            }
            .onAppear { if let cls = cls { name = cls.name } }
        }
    }
}

struct AddEditDirectionView: View {
    let direction: Direction?
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var price = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Direction Name", text: $name)
                TextField("Price", text: $price)
                    .keyboardType(.numberPad)
            }
            .navigationTitle(direction == nil ? "Add Direction" : "Edit Direction")
            .toolbar {
                Button("Save") {
                    Task {
                        guard let p = Int(price) else { return }
                        if let dir = direction {
                            struct Req: Encodable { let name: String; let price: Int }
                            let _: Direction = try await NetworkManager.shared.putRequest(path: "/directions/\(dir.id)", body: Req(name: name, price: p))
                        } else {
                            struct Req: Encodable { let name: String; let price: Int }
                            let _: Direction = try await NetworkManager.shared.postRequest(path: "/directions", body: Req(name: name, price: p))
                        }
                        DispatchQueue.main.async {
                            onSave()
                            dismiss()
                        }
                    }
                }
                .disabled(name.isEmpty || price.isEmpty)
            }
            .onAppear { 
                if let dir = direction { 
                    name = dir.name
                    price = String(dir.price)
                } 
            }
        }
    }
}
