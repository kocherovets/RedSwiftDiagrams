import UIKit

extension Diagram {
    func set(lists: [ListShape]) {
        let wasEmpty = lists.count == 0
        self.listShapes = lists
        if wasEmpty, let rect = calculateRealRect(for: lists) {
            var delta = rect.origin.applying(transformFromRealToScreen())
            delta += CGPoint(x: -100, y: contentRect.height - 100)
            realLeftBottom = delta.applying(transformFromRealToScreen().inverted())
        }
        setNeedsDisplay()
    }

    public func removeShape(with uuid: UUID) {
        for i in 0 ..< listShapes.count {
            if listShapes[i].uuid == uuid {
                listShapes.remove(at: i)
                break
            }
        }
        setNeedsDisplay()
    }

    func calculateRealRect(for shapes: [DiagramShape]) -> CGRect? {
        if shapes.count == 0 {
            return nil
        }
        var newRealRect = CGRect.null
        for shape in shapes {
            newRealRect = newRealRect.union(shape.realBox)
        }
        return newRealRect
    }

    fileprivate func sortedShapesByPriority(for shapes: [DiagramShape]) -> [DiagramShape] {
        var layers = [Int: [DiagramShape]]()
        for shape in shapes {
            if layers[shape.priority] == nil {
                layers[shape.priority] = [DiagramShape]()
            }
            layers[shape.priority]!.append(shape)
        }
        var newShapes = [DiagramShape]()
        for priority in layers.keys.sorted() {
            newShapes.append(contentsOf: layers[priority]!)
        }
        return newShapes
    }
}
