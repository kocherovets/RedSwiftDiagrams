import Foundation

struct List: Equatable, Codable {
    struct Item: Equatable, Codable {
        var uuid: UUID
        var typeName: String
        var tags: String
        var title: String { typeName + (tags.count > 0 ? " (\(tags))" : "") }
    }

    var items = [Item]()
    var header: Item { items[0] }
    var uuids: [UUID] { items.map { $0.uuid }}
    var uuid: UUID { header.uuid }

    init(items: [Item]) {
        self.items = items
    }
}
