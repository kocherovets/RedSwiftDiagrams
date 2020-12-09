import UIKit

extension DiagramView {
    func set(diagram: Diagram) {
        let wasEmpty = self.diagram.lists.count == 0
        self.diagram = diagram
        if wasEmpty, let rect = calculateRealRect() {
            var delta = rect.origin.applying(transformFromRealToScreen())
            delta += CGPoint(x: -100, y: contentRect.height - 100)
            realLeftBottom = delta.applying(transformFromRealToScreen().inverted())
        }
        setNeedsDisplay()
    }

    func calculateRealRect() -> CGRect? {
        if diagram.lists.count == 0 {
            return nil
        }
        var newRealRect = CGRect.null
        for rect in diagram.listRects.values {
            newRealRect = newRealRect.union(rect)
        }
        return newRealRect
    }
}
