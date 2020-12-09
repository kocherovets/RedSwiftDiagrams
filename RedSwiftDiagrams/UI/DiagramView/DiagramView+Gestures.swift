import UIKit

extension DiagramView: UIGestureRecognizerDelegate {
    func createGestures() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(diagramTap(_:)))

        dragShapeGesture = UIPanGestureRecognizer(target: self, action: #selector(dragList(_:)))
        dragShapeGesture.delegate = self
        dragShapeGesture.delaysTouchesBegan = true
        dragShapeGesture.cancelsTouchesInView = false

        dragDiagramGesture = UIPanGestureRecognizer(target: self, action: #selector(dragDiagram(_:)))
        dragDiagramGesture.allowedScrollTypesMask = .continuous
        dragDiagramGesture.delegate = self
        dragDiagramGesture.minimumNumberOfTouches = 2

        hoverGestureRecognizer = UIHoverGestureRecognizer(target: self, action: #selector(hovering(_:)))
        addGestureRecognizer(hoverGestureRecognizer)

        setupGestures()
    }

    func setupGestures() {
        setup(gesture: tapGesture)

        setup(gesture: dragShapeGesture)

        setup(gesture: dragDiagramGesture)
    }

    fileprivate func setup(gesture: UIGestureRecognizer) {
        if gestureRecognizers == nil || !gestureRecognizers!.contains(gesture) {
            addGestureRecognizer(gesture)
        }
    }

    @objc fileprivate func diagramTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        let t = transformFromRealToScreen()

        if case let .plus(listUUID, prevItemUUID) = diagram.cursor(to: point, with: t) {
            props?.addItemCommand.perform(with: (listUUID, prevItemUUID))
            return
        }

        selectedUUID = nil
        switch diagram.selectedUUID(to: point, with: t) {
        case let .list(uuid):
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

    @objc fileprivate func dragList(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            let point = gesture.location(in: self)
            let t = transformFromRealToScreen()
            if let uuid = diagram.draggedList(to: point, with: t),
               let index = diagram.lists.firstIndex(where: { $0.uuid == uuid }) {
                draggedListIndex = index
                beginDragRealListOrigin = diagram.listRects[uuid]?.origin
                dragTransform = transformFromRealToScreen().inverted()
                beginDragRealPoint = gesture.location(in: self).applying(dragTransform)
            }
        case .changed:
            if let beginDragRealListOrigin = beginDragRealListOrigin,
               let beginDragRealPoint = beginDragRealPoint,
               let draggedListIndex = draggedListIndex {
                let point = gesture.location(in: self).applying(dragTransform)
                let delta = beginDragRealPoint - point

                if var rect = diagram.listRects[diagram.lists[draggedListIndex].uuid] {
                    rect.origin = beginDragRealListOrigin - delta
                    diagram.listRects[diagram.lists[draggedListIndex].uuid] = rect
                    diagram.updateGeometry(list: diagram.lists[draggedListIndex])
                }

                setNeedsDisplay()
            }
        case .ended, .cancelled:
            if let _ = draggedListIndex {
                props?.updateDiagramCommand.perform(with: diagram)
            }
            beginDragRealListOrigin = nil
            beginDragRealPoint = nil
            draggedListIndex = nil
        default:
            break
        }
    }

    @objc fileprivate func dragDiagram(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            beginDragRealLeftBottom = realLeftBottom
            dragTransform = transformFromRealToScreen().inverted()
            beginDragRealPoint = gesture.location(in: self).applying(dragTransform)
        case .changed:
            if let beginDragRealLeftBottom = beginDragRealLeftBottom,
               let beginDragRealPoint = beginDragRealPoint {
                let point = gesture.location(in: self).applying(dragTransform)
                let delta = point - beginDragRealPoint

                realLeftBottom = beginDragRealLeftBottom - delta

                setNeedsDisplay()
            }
        case .ended, .cancelled:
            beginDragRealLeftBottom = nil
            beginDragRealPoint = nil
            props?.setNewListOriginCommand.perform(with: realNewListOrigin)
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
