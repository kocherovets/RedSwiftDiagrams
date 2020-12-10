import Foundation
import UIKit
struct Diagram: Equatable {
    struct ListWithPosition {
        var list: List
        var origin: CGPoint
    }

    struct Link: Equatable {
        var from: UUID
        var to: UUID
    }

    var lists = [List]()
    var listRects = [UUID: CGRect]()
    var itemRects = [UUID: CGRect]()
    var titleRects = [UUID: CGRect]()
    var addRects = [UUID: CGRect]()

    var links = [Link]()
    var linkLables = [UUID: String]()

    enum Selected: Equatable {
        case item(uuid: UUID)
        case from(uuid: UUID)
        case to(uuid: UUID)
    }

    var selected: Selected?

    init(lists: [ListWithPosition] = [],
         links: [Link] = []) {
        set(lists: lists)
    }

    mutating func addNewList(origin: CGPoint) {
        let uuid = UUID()
        let list = List(items: [
            List.Item(uuid: uuid,
                      typeName: "New",
                      tags: ""),
            List.Item(uuid: UUID(),
                      typeName: "New item",
                      tags: ""),
        ])
        lists.append(list)
        listRects[uuid] = CGRect(origin: origin, size: .zero)
        updateGeometry(list: list)
    }

    mutating func setTags(uuid: UUID, tags: String) {
        if let (listIndex, itemIndex) = indexies(uuid: uuid) {
            lists[listIndex].items[itemIndex].tags = tags
            updateGeometry(list: lists[listIndex])
        }
    }

    mutating func setTypeName(uuid: UUID, typeName: String) {
        if let (listIndex, itemIndex) = indexies(uuid: uuid) {
            lists[listIndex].items[itemIndex].typeName = typeName
            updateGeometry(list: lists[listIndex])
        }
    }

    mutating func addItem(prevUUID: UUID) {
        for i in 0 ..< lists.count {
            for ii in 0 ..< lists[i].items.count {
                if lists[i].items[ii].uuid == prevUUID {
                    lists[i].items.insert(List.Item(uuid: UUID(),
                                                    typeName: "New",
                                                    tags: ""),
                                          at: ii + 1)
                    updateGeometry(list: lists[i])
                    return
                }
            }
        }
    }

    mutating func deleteItem(uuid: UUID) {
        if let (listIndex, itemIndex) = indexies(uuid: uuid) {
            if itemIndex > 0 {
                lists[listIndex].items.remove(at: itemIndex)
                eraseRects(uuid: uuid)
                updateGeometry(list: lists[listIndex])
                deleteLink(uuid: uuid)
            } else {
                lists[listIndex].uuids.forEach {
                    deleteLink(uuid: $0)
                    eraseRects(uuid: $0)
                }
                lists.remove(at: listIndex)
            }
        }
    }

    mutating func deleteLink(from uuid: UUID) {
        if let link = links.filter({ $0.from == uuid }).first {
            if links.filter({ $0.to == link.to }).count == 1 {
                linkLables[link.to] = nil
            }
        }
        links.removeAll(where: { $0.from == uuid })
    }

    mutating func deleteLink(to uuid: UUID) {
        linkLables[uuid] = nil
        links.removeAll(where: { $0.to == uuid })
    }

    mutating func set(lists: [ListWithPosition]) {
        self.lists = [List]()
        listRects = [UUID: CGRect]()
        itemRects = [UUID: CGRect]()
        titleRects = [UUID: CGRect]()
        addRects = [UUID: CGRect]()

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

    mutating func deleteLink(uuid: UUID) {
        linkLables[uuid] = nil
        links.removeAll(where: { $0.from == uuid })
        links.removeAll(where: { $0.to == uuid })
    }

    mutating func set(links: [Link]) {
        self.links = links
        linkLables = [:]
        var lables = Set<String>()
        for link in links {
            if let _ = linkLables[link.to] {
                continue
            }
            let lable = nextLinkLabel(lables: lables)
            linkLables[link.to] = lable
            lables.insert(lable)
        }
    }

    mutating func addLink(link: Link) {
        let lable = nextLinkLabel(lables: Set<String>(linkLables.values))
        linkLables[link.to] = lable
        links.append(link)
    }

    func nextLinkLabel(lables: Set<String>) -> String {
        var i = 1
        while true {
            let lable = String(i)
            if !lables.contains(lable) {
                return lable
            }
            i += 1
        }
    }
}

extension Diagram {
    func indexies(uuid: UUID?) -> (listIndex: Int, itemIndex: Int)? {
        if let uuid = uuid {
            for i in 0 ..< lists.count {
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
            return lists[listIndex].items[itemIndex]
        }
        return nil
    }

    func listOrigin(listUUID: UUID) -> CGPoint {
        listRects[listUUID]?.origin ?? .zero
    }
}
