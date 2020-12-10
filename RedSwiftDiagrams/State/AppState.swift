import CoreGraphics
import DITranquillity
import Foundation
import RedSwift

struct AppState: RootStateType, Equatable {
    var diagram = Diagram()
    var selectedUUID: UUID?
    var newListOrigin = CGPoint.zero

    var error = StateError.none
}

enum StateError: Error, Equatable {
    case none
    case error(String)
    case unknownDBError
}

extension AppState {
    func selectedItem() -> List.Item? {
        diagram.item(uuid: selectedUUID)
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
        let uuid: UUID?

        func updateState(_ state: inout AppState) {
            state.selectedUUID = uuid
        }
    }

    struct DeleteSelectedAction: Action {
        func updateState(_ state: inout AppState) {
            if let selectedUUID = state.selectedUUID {
                state.diagram.delete(uuid: selectedUUID)
            }
            state.selectedUUID = nil
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
            if let selectedUUID = state.selectedUUID {
                state.diagram.setTypeName(uuid: selectedUUID, typeName: typeName)
            }
        }
    }

    struct SetTagsAction: Action, UIToolbar {
        let tags: String

        func updateState(_ state: inout AppState) {
            if let selectedUUID = state.selectedUUID {
                state.diagram.setTags(uuid: selectedUUID, tags: tags)
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
}

extension Action {
    func updateState(_ state: inout AppState) { }
}

protocol UIToolbar {}
