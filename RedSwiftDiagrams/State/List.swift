import Foundation

struct List: Equatable {
    struct Item: Equatable {
        var uuid: UUID
        var typeName: String
        var tags: String
        var title: String { typeName + (tags.count > 0 ? " (\(tags))" : "") }
    }

    var header: Item
    var items = [Item]()
    var uuids: [UUID] { [header.uuid] + items.map { $0.uuid }}
    var uuid: UUID { header.uuid }

    init(header: Item, items: [Item]) {
        self.header = header
        self.items = items
    }
}
