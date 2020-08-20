import Foundation
import Combine

struct Item: Identifiable, Codable {
    let id: UUID
    var title: String
    var isLater: Bool
    var isCompleted: Bool

    init(title: String, isLater: Bool) {
        id = UUID()
        self.title = title
        self.isLater = isLater
        isCompleted = false
    }
}

final class TodoStore: ObservableObject {
    @Published private(set) var items: [Item] = [] {
        didSet { save() }
    }

    private let storageKey = "todo.items"

    init() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let savedItems = try? JSONDecoder().decode([Item].self, from: data) else {
            return
        }
        items = savedItems
    }

    func add(_ title: String, isLater: Bool) {
        items.insert(Item(title: title, isLater: isLater), at: 0)
    }

    func toggle(_ item: Item) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isCompleted.toggle()
    }

    func move(_ item: Item) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isLater.toggle()
    }

    func delete(_ item: Item) {
        items.removeAll { $0.id == item.id }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
