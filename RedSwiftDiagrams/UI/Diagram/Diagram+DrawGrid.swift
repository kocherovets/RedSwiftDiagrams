import UIKit

extension Diagram {
    func drawGrid(rect: CGRect, in context: CGContext) {
        context.setStrokeColor(red: 221.0 / 255.0, green: 221.0 / 255.0, blue: 221.0 / 255.0, alpha: 1)
        context.setLineWidth(0.5)
        let cellWidth: CGFloat = 20
        var x = cellWidth
        while x < rect.width  {
            context.drawLine(from: CGPoint(x: x,
                                           y: bounds.bottom),
                             to: CGPoint(x: x,
                                         y: bounds.top))
            x += cellWidth
        }
        var y = cellWidth
        while y < rect.height {
            context.drawLine(from: CGPoint(x: bounds.left,
                                           y: y),
                             to: CGPoint(x: bounds.right,
                                         y: y))
            y += cellWidth
        }
    }
}
