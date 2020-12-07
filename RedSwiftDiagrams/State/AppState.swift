import DITranquillity
import Foundation
import RedSwift

struct AppState: RootStateType, Equatable {
    var lists = [List]()
    var selectedUUID: UUID?
    var newListOrigin = CGPoint.zero

    enum Routing: Equatable {
        case none
        case showsArticle(uuid: UUID)
    }

    var lastRouting = Routing.none

    var error = StateError.none
}

enum StateError: Error, Equatable {
    case none
    case error(String)
    case unknownDBError
}

extension AppState {
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

    func selectedItem() -> List.Item? {
        if let (listIndex, itemIndex) = indexies(uuid: selectedUUID) {
            if let itemIndex = itemIndex {
                return lists[listIndex].items[itemIndex].item
            } else {
                return lists[listIndex].header.item
            }
        }
        return nil
    }
}

extension AppState {
    struct ErrorAction: Action {
        let error: StateError

        func updateState(_ state: inout AppState) {
            state.error = error
        }
    }

    struct SetListsAction: Action {
        let lists: [List]

        func updateState(_ state: inout AppState) {
            state.lists = lists
        }
    }

    struct SetSelectedAction: Action, UIToolbar {
        let uuid: UUID?

        func updateState(_ state: inout AppState) {
            state.selectedUUID = uuid
        }
    }

    struct DeleteSelectedAction: Action {
        func updateState(_ state: inout AppState) {
            if let (listIndex, itemIndex) = state.indexies(uuid: state.selectedUUID) {
                if let itemIndex = itemIndex {
                    state.lists[listIndex].items.remove(at: itemIndex)
                    state.lists[listIndex].updateGeometry(origin: state.lists[listIndex].header.rect.origin)
                } else {
                    state.lists.remove(at: listIndex)
                }
            }
            state.selectedUUID = nil
        }
    }

    struct AddItemAction: Action {
        let listUUID: UUID
        let prevUUID: UUID?

        func updateState(_ state: inout AppState) {
            for i in 0 ..< state.lists.count {
                if state.lists[i].header.uuid == listUUID {
                    for ii in 0 ..< state.lists[i].items.count {
                        if prevUUID == nil || state.lists[i].items[ii].uuid == prevUUID {
                            state.lists[i].items.insert(List.ItemRect(item: List.Item(uuid: UUID(),
                                                                                      typeName: "New",
                                                                                      tags: "")),
                            at: prevUUID == nil ? 0 : ii + 1)
                            state.lists[i].updateGeometry(origin: state.lists[i].header.rect.origin)
                            return
                        }
                    }
                }
            }
        }
    }

    struct SetTypeNameAction: Action, UIToolbar {
        let typeName: String

        func updateState(_ state: inout AppState) {
            if let (listIndex, itemIndex) = state.indexies(uuid: state.selectedUUID) {
                if let itemIndex = itemIndex {
                    state.lists[listIndex].items[itemIndex].item.typeName = typeName
                } else {
                    state.lists[listIndex].header.item.typeName = typeName
                }
                state.lists[listIndex].updateGeometry(origin: state.lists[listIndex].header.rect.origin)
            }
        }
    }

    struct SetTagsAction: Action, UIToolbar {
        let tags: String

        func updateState(_ state: inout AppState) {
            if let (listIndex, itemIndex) = state.indexies(uuid: state.selectedUUID) {
                if let itemIndex = itemIndex {
                    state.lists[listIndex].items[itemIndex].item.tags = tags
                } else {
                    state.lists[listIndex].header.item.tags = tags
                }
                state.lists[listIndex].updateGeometry(origin: state.lists[listIndex].header.rect.origin)
            }
        }
    }

    struct SetListOriginAction: Action {
        let listUUID: UUID
        let origin: CGPoint

        func updateState(_ state: inout AppState) {
            for i in 0 ..< state.lists.count {
                if state.lists[i].header.uuid == listUUID {
                    state.lists[i].updateGeometry(origin: origin)
                    return
                }
            }
        }
    }
    
    struct AddNewListAction: Action {
        func updateState(_ state: inout AppState) {
            state.lists.append(List(origin: state.newListOrigin,
                                    header: List.Item(uuid: UUID(),
                                                      typeName: "New",
                                                      tags: ""),
                                    items: [List.Item(uuid: UUID(),
                                                      typeName: "New item",
                                                      tags: "")]))
        }
    }

    struct SetNewListOriginAction: Action {
        let point: CGPoint

        func updateState(_ state: inout AppState) {
            state.newListOrigin = point
        }
    }

}

extension Action {
    func updateState(_ state: inout AppState) { }
}

protocol UIToolbar {}

struct List: Equatable {
    struct Item: Equatable {
        var uuid: UUID
        var typeName: String
        var tags: String
        var title: String { typeName + (tags.count > 0 ? " (\(tags))" : "") }
    }

    struct AddRect: Equatable {
        var prevItem: UUID?
        var rect: CGRect
    }

    struct ItemRect: Equatable {
        var item: Item
        var rect = CGRect.zero
        var titleRect = CGRect.zero
        var selected: Bool = false

        var uuid: UUID { item.uuid }
        var title: String { item.title }
    }

    var rect = CGRect.zero
    var header: ItemRect
    var items = [ItemRect]()
    var addRects = [AddRect]()

    init(origin: CGPoint, header: Item, items: [Item]) {
        self.header = ItemRect(item: header,
                               rect: .zero,
                               titleRect: .zero)

        for index in 0 ..< items.count {
            self.items.append(
                ItemRect(item: items[index],
                         rect: .zero,
                         titleRect: .zero)
            )
        }

        updateGeometry(origin: origin)
    }
}
