import CoreGraphics
import DITranquillity
import Foundation
import RedSwift

struct AppState: RootStateType, Equatable {
    var diagram = Diagram()
    var newListOrigin = CGPoint.zero

    struct NewLink: Equatable {
        var from: UUID?
    }

    var newLink: NewLink?

    var error = StateError.none
}

enum StateError: Error, Equatable {
    case none
    case error(String)
    case unknownDBError
}

extension AppState {
    func selectedItem() -> List.Item? {
        if case let .item(uuid) = diagram.selected {
            return diagram.item(uuid: uuid)
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

    struct SetDiagramAction: Action {
        let diagram: Diagram

        func updateState(_ state: inout AppState) {
            state.diagram = diagram
        }
    }

    struct SetListsAction: Action {
        let lists: [Diagram.ListWithPosition]

        func updateState(_ state: inout AppState) {
            state.diagram.set(lists: lists)
        }
    }

    struct SetLinksAction: Action {
        let links: [Diagram.Link]

        func updateState(_ state: inout AppState) {
            state.diagram.set(links: links)
        }
    }

    struct SetSelectedAction: Action, UIToolbar {
        let selected: Diagram.Selected?

        func updateState(_ state: inout AppState) {
            state.diagram.selected = selected
            if case let .item(uuid) = selected {
                if let _ = state.newLink {
                    if let from = state.newLink?.from {
                        state.diagram.addLink(link: Diagram.Link(from: from, to: uuid))
                        state.newLink = nil
                    } else {
                        state.newLink?.from = uuid
                    }
                }
                return
            }
            state.newLink = nil
        }
    }

    struct DeleteSelectedAction: Action {
        func updateState(_ state: inout AppState) {
            switch state.diagram.selected {
            case let .item(uuid):
                state.diagram.deleteItem(uuid: uuid)
            case let .from(uuid):
                state.diagram.deleteLink(from: uuid)
            case let .to(uuid):
                state.diagram.deleteLink(to: uuid)
            default:
                break
            }
            state.diagram.selected = nil
        }
    }

    struct AddItemAction: Action {
        let prevUUID: UUID

        func updateState(_ state: inout AppState) {
            state.diagram.addItem(prevUUID: prevUUID)
        }
    }

    struct SetTypeNameAction: Action, UIToolbar {
        let typeName: String

        func updateState(_ state: inout AppState) {
            if case let .item(uuid) = state.diagram.selected {
                state.diagram.setTypeName(uuid: uuid, typeName: typeName)
            }
        }
    }

    struct SetTagsAction: Action, UIToolbar {
        let tags: String

        func updateState(_ state: inout AppState) {
            if case let .item(uuid) = state.diagram.selected {
                state.diagram.setTags(uuid: uuid, tags: tags)
            }
        }
    }

    struct AddNewListAction: Action {
        func updateState(_ state: inout AppState) {
            state.diagram.addNewList(origin: state.newListOrigin)
        }
    }

    struct SetNewListOriginAction: Action {
        let point: CGPoint

        func updateState(_ state: inout AppState) {
            state.newListOrigin = point
        }
    }

    struct StartNewLinkAction: Action {
        func updateState(_ state: inout AppState) {
            state.newLink = NewLink()
        }
    }
}

extension Action {
    func updateState(_ state: inout AppState) { }
}

protocol UIToolbar {}
