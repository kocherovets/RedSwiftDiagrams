import UIKit

extension Diagram {
    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)

        drawGrid(rect: rect, in: context)

        let transform = transformFromRealToScreen()

        context.saveGState()

        context.restoreGState()

        for list in listShapes {
            list.draw(on: rect, with: transform, in: context, selectedUUID: selectedUUID)
        }
    }
}
