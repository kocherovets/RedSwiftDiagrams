import Foundation
import UIKit
struct Diagram: Equatable {
    struct AddRect: Equatable {
        var prevItem: UUID?
        var rect: CGRect
    }

    struct ListWithPosition {
        var list: List
        var origin: CGPoint
    }

    var lists = [List]()
    var listRects = [UUID: CGRect]()
    var itemRects = [UUID: CGRect]()
    var titleRects = [UUID: CGRect]()
    var addRects = [UUID: AddRect]()

    init(lists: [ListWithPosition] = []) {
        set(lists: lists)
    }

    mutating func addNewList(origin: CGPoint) {
        let uuid = UUID()
        let list = List(header: List.Item(uuid: uuid,
                                          typeName: "New",
                                          tags: ""),
                        items: [List.Item(uuid: UUID(),
                                          typeName: "New item",
                                          tags: "")])
        lists.append(list)
        listRects[uuid] = CGRect(origin: origin, size: .zero)
        updateGeometry(list: list)
    }

    mutating func setTags(listUUID: UUID?, tags: String) {
        if let (listIndex, itemIndex) = indexies(uuid: listUUID) {
            if let itemIndex = itemIndex {
                lists[listIndex].items[itemIndex].tags = tags
            } else {
                lists[listIndex].header.tags = tags
            }
            updateGeometry(list: lists[listIndex])
        }
    }

    mutating func setTypeName(listUUID: UUID?, typeName: String) {
        if let (listIndex, itemIndex) = indexies(uuid: listUUID) {
            if let itemIndex = itemIndex {
                lists[listIndex].items[itemIndex].typeName = typeName
            } else {
                lists[listIndex].header.typeName = typeName
            }
            updateGeometry(list: lists[listIndex])
        }
    }

    mutating func addItem(listUUID: UUID, prevUUID: UUID?) {
        for i in 0 ..< lists.count {
            if lists[i].header.uuid == listUUID {
                for ii in 0 ..< lists[i].items.count {
                    if prevUUID == nil || lists[i].items[ii].uuid == prevUUID {
                        lists[i].items.insert(List.Item(uuid: UUID(),
                                                        typeName: "New",
                                                        tags: ""),
                                              at: prevUUID == nil ? 0 : ii + 1)
                        updateGeometry(list: lists[i])
                        return
                    }
                }
            }
        }
    }

    mutating func delete(uuid: UUID?) {
        if let (listIndex, itemIndex) = indexies(uuid: uuid) {
            if let itemIndex = itemIndex {
                lists[listIndex].items.remove(at: itemIndex)
                eraseRects(uuid: uuid)
                updateGeometry(list: lists[listIndex])
            } else {
                lists[listIndex].uuids.forEach { eraseRects(uuid: $0) }
                lists.remove(at: listIndex)
            }
        }
    }

    mutating func set(lists: [ListWithPosition]) {
        self.lists = [List]()
        listRects = [UUID: CGRect]()
        itemRects = [UUID: CGRect]()
        titleRects = [UUID: CGRect]()
        addRects = [UUID: AddRect]()

        self.lists = lists.map { $0.list }
        lists.forEach {
            listRects[$0.list.uuid] = CGRect(origin: $0.origin, size: .zero)
            updateGeometry(list: $0.list)
        }
    }

    mutating func eraseRects(uuid: UUID?) {
        if let uuid = uuid {
            listRects[uuid] = nil
            itemRects[uuid] = nil
            titleRects[uuid] = nil
            addRects[uuid] = nil
        }
    }
}

extension Diagram {
    func indexies(uuid: UUID?) -> (listIndex: Int, itemIndex: Int?)? {
        if let uuid = uuid {
            for i in 0 ..< lists.count {
                if lists[i].header.uuid == uuid {
                    return (i, nil)
                }
                for ii in 0 ..< lists[i].items.count {
                    if lists[i].items[ii].uuid == uuid {
                        return (i, ii)
                    }
                }
            }
        }
        return nil
    }

    func item(uuid: UUID?) -> List.Item? {
        if let (listIndex, itemIndex) = indexies(uuid: uuid) {
            if let itemIndex = itemIndex {
                return lists[listIndex].items[itemIndex]
            } else {
                return lists[listIndex].header
            }
        }
        return nil
    }

    func listOrigin(listUUID: UUID) -> CGPoint {
        listRects[listUUID]?.origin ?? .zero
    }
}
