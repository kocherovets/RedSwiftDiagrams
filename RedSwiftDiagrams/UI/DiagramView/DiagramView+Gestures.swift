import UIKit

extension DiagramView: UIGestureRecognizerDelegate {
    func createGestures() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(diagramTap(_:)))

        dragGesture = UIPanGestureRecognizer(target: self, action: #selector(drag(_:)))
        dragGesture.delegate = self
        dragGesture.delaysTouchesBegan = true
        dragGesture.cancelsTouchesInView = false

        hoverGestureRecognizer = UIHoverGestureRecognizer(target: self, action: #selector(hovering(_:)))
        addGestureRecognizer(hoverGestureRecognizer)

        addGestureRecognizer(tapGesture)
        addGestureRecognizer(dragGesture)
    }

    @objc fileprivate func diagramTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        let t = transformFromRealToScreen()

        if case let .plus(prevItemUUID) = diagram.cursor(to: point, with: t) {
            props?.addItemCommand.perform(with: prevItemUUID)
            return
        }

        selectedUUID = nil
        switch diagram.selectedUUID(to: point, with: t) {
        case let .listItem(uuid):
            selectedUUID = uuid
        case let .arrow(uuid):
            if selectedUUID == nil {
                selectedUUID = uuid
            }
        default:
            break
        }
        props?.selectCommand.perform(with: selectedUUID)

        setNeedsDisplay()
    }

    @objc fileprivate func drag(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            let point = gesture.location(in: self)
            let t = transformFromRealToScreen()
            dragTransform = t.inverted()
            beginDragRealPoint = point.applying(dragTransform)

            if let uuid = diagram.draggedList(to: point, with: t),
               let index = diagram.lists.firstIndex(where: { $0.uuid == uuid }) {
                draggedListIndex = index
                beginDragRealListOrigin = diagram.listRects[uuid]?.origin
            } else {
                beginDragRealLeftBottom = realLeftBottom
            }
        case .changed:
            if
                let beginDragRealPoint = beginDragRealPoint {
                let point = gesture.location(in: self).applying(dragTransform)
                let delta = beginDragRealPoint - point

                if let beginDragRealListOrigin = beginDragRealListOrigin,
                   let draggedListIndex = draggedListIndex {
                    if var rect = diagram.listRects[diagram.lists[draggedListIndex].uuid] {
                        rect.origin = beginDragRealListOrigin - delta
                        diagram.listRects[diagram.lists[draggedListIndex].uuid] = rect
                        diagram.updateGeometry(list: diagram.lists[draggedListIndex])
                    }
                } else if let beginDragRealLeftBottom = beginDragRealLeftBottom {
                    let point = gesture.location(in: self).applying(dragTransform)
                    let delta = point - beginDragRealPoint

                    realLeftBottom = beginDragRealLeftBottom - delta
                }
                setNeedsDisplay()
            }
        case .ended, .cancelled:
            if let _ = draggedListIndex {
                props?.updateDiagramCommand.perform(with: diagram)
            } else {
                props?.setNewListOriginCommand.perform(with: realNewListOrigin)
            }
            beginDragRealLeftBottom = nil
            beginDragRealListOrigin = nil
            beginDragRealPoint = nil
            draggedListIndex = nil
        default:
            break
        }
    }

    @objc
    func hovering(_ gesture: UIHoverGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            let point = gesture.location(in: self)
            let t = transformFromRealToScreen()
            switch diagram.cursor(to: point, with: t) {
            case .plus:
                NSCursor.crosshair.set()
                return
            default:
                break
            }
            NSCursor.arrow.set()
        case .ended:
            currentPoint = nil
        default:
            break
        }
    }
}
