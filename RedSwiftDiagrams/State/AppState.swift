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

    var undo = [Diagram]()
    var redo = [Diagram]()

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

    mutating func resetUndoRedo() {
        undo = [Diagram]()
        redo = [Diagram]()
        newLink = nil
    }

    mutating func addUndo() {
        undo.append(diagram)
        redo = [Diagram]()
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
            state.addUndo()
            state.diagram = diagram
        }
    }

    struct SetFSDiagramAction: Action {
        let diagram: FSDiagram

        func updateState(_ state: inout AppState) {
            state.resetUndoRedo()
            state.diagram.set(lists: diagram.lists)
            state.diagram.set(links: diagram.links)
        }
    }

    struct SetListsAction: Action {
        let lists: [FSList]

        func updateState(_ state: inout AppState) {
            state.resetUndoRedo()
            state.diagram.set(lists: lists)
        }
    }

    struct SetLinksAction: Action {
        let links: [Link]

        func updateState(_ state: inout AppState) {
            state.resetUndoRedo()
            state.diagram.set(links: links)
        }
    }

    struct SetSelectedAction: Action {
        let selected: Diagram.Selected?

        func updateState(_ state: inout AppState) {
            state.diagram.selected = selected
            if case let .item(uuid) = selected {
                if let _ = state.newLink {
                    if let from = state.newLink?.from {
                        state.addUndo()
                        state.diagram.addLink(link: Link(from: from, to: uuid))
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
            state.addUndo()
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
            state.addUndo()
            state.diagram.addItem(prevUUID: prevUUID)
        }
    }

    struct SetTypeNameAction: Action {
        let typeName: String

        func updateState(_ state: inout AppState) {
            if case let .item(uuid) = state.diagram.selected {
                state.addUndo()
                state.diagram.setTypeName(uuid: uuid, typeName: typeName)
            }
        }
    }

    struct SetTagsAction: Action {
        let tags: String

        func updateState(_ state: inout AppState) {
            if case let .item(uuid) = state.diagram.selected {
                state.addUndo()
                state.diagram.setTags(uuid: uuid, tags: tags)
            }
        }
    }

    struct AddNewListAction: Action {
        func updateState(_ state: inout AppState) {
            state.addUndo()
            state.diagram.addNewList(origin: state.newListOrigin)
        }
    }

    struct SetNewListOriginAction: Action {
        let point: CGPoint

        func updateState(_ state: inout AppState) {
            state.addUndo()
            state.newListOrigin = point
        }
    }

    struct StartNewLinkAction: Action {
        func updateState(_ state: inout AppState) {
            state.newLink = NewLink()
        }
    }

    struct LoadAction: Action {
        func updateState(_ state: inout AppState) {
        }
    }

    struct SaveAction: Action {
        func updateState(_ state: inout AppState) {
        }
    }

    struct UndoAction: Action {
        func updateState(_ state: inout AppState) {
            if let diagram = state.undo.last {
                state.redo.append(state.diagram)
                state.diagram = diagram
                state.undo.removeLast()
//                state.redo.append(state.undo.removeLast())
            }
        }
    }

    struct RedoAction: Action {
        func updateState(_ state: inout AppState) {
            if let diagram = state.redo.last {
                state.undo.append(state.diagram)
                state.diagram = diagram
                state.redo.removeLast()
//                state.undo.append(state.redo.removeLast())
            }
        }
    }
}

extension Action {
    func updateState(_ state: inout AppState) { }
}
