import UIKit

extension DiagramView {
    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)

        drawGrid(rect: rect, in: context)

        let transform = transformFromRealToScreen()

        context.saveGState()

        context.restoreGState()

        diagram.draw(on: rect, with: transform, in: context, selectedUUID: selectedUUID)
    }
}
