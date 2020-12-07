import UIKit

extension Diagram: UIGestureRecognizerDelegate {
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

        for shape in listShapes {
            switch shape.cursor(to: point, with: t) {
            case let .plus(listUUID, prevItemUUID):
                props?.addItemCommand.perform(with: (listUUID, prevItemUUID))
                return
            default:
                break
            }
        }

        closestShape(to: point)
        setNeedsDisplay()
    }

    @objc fileprivate func dragList(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            let point = gesture.location(in: self)
            let t = transformFromRealToScreen()
            for shape in listShapes {
                if let uuid = shape.draggedList(to: point, with: t),
                   let index = listShapes.firstIndex(where: { $0.uuid == uuid }) {
                    draggedListIndex = index
                    beginDragRealListOrigin = listShapes[index].list.rect.origin
                    dragTransform = transformFromRealToScreen().inverted()
                    beginDragRealPoint = gesture.location(in: self).applying(dragTransform)
                }
            }
        case .changed:
            if let beginDragRealListOrigin = beginDragRealListOrigin,
               let beginDragRealPoint = beginDragRealPoint,
               let draggedListIndex = draggedListIndex {
                let point = gesture.location(in: self).applying(dragTransform)
                let delta = beginDragRealPoint - point

                listShapes[draggedListIndex].list.updateGeometry(origin: beginDragRealListOrigin - delta)

                setNeedsDisplay()
            }
        case .ended, .cancelled:
            if let draggedListIndex = draggedListIndex {
                props?.updateListOriginCommand.perform(
                    with: (listShapes[draggedListIndex].uuid, listShapes[draggedListIndex].list.rect.origin))
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

    fileprivate func closestShape(to point: CGPoint) {
        let t = transformFromRealToScreen()
        selectedUUID = nil
        for shape in listShapes {
            let shape = shape.selectedUUID(to: point, with: t)
            switch shape {
            case let .list(uuid):
                selectedUUID = uuid
            case let .arrow(uuid):
                if selectedUUID == nil {
                    selectedUUID = uuid
                }
            default:
                break
            }
        }
        props?.selectCommand.perform(with: selectedUUID)
    }

    @objc
    func hovering(_ gesture: UIHoverGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            let point = gesture.location(in: self)
            let t = transformFromRealToScreen()
            for shape in listShapes {
                switch shape.cursor(to: point, with: t) {
                case .plus:
                    NSCursor.crosshair.set()
                    return
                default:
                    break
                }
            }
            NSCursor.arrow.set()
        case .ended:
            currentPoint = nil
        default:
            break
        }
    }
}
