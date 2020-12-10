import Foundation

struct List: Equatable {
    struct Item: Equatable {
        var uuid: UUID
        var typeName: String
        var tags: String
        var title: String { typeName + (tags.count > 0 ? " (\(tags))" : "") }
    }

    var header: Item { items[0] }
    var items = [Item]()
    var uuids: [UUID] { items.map { $0.uuid }}
    var uuid: UUID { header.uuid }

    init(items: [Item]) {
        self.items = items
    }
}
