import UIKit

extension CGContext {
    func drawLine(from: CGPoint, to: CGPoint) {
        beginPath()
        move(to: from)
        addLine(to: to)
        strokePath()
    }
}
