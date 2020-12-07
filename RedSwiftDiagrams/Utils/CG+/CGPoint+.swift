import UIKit

extension CGPoint {
    var asSize: CGSize {
        return CGSize(width: x, height: y)
    }

    func distance(to: CGPoint) -> CGFloat {
        return hypot(x - to.x, y - to.y)
    }

    func clamp(min: CGPoint, max: CGPoint) -> CGPoint {
        return CGPoint(x: x.clamp(min: min.x, max: max.x),
                       y: y.clamp(min: min.y, max: max.y))
    }

    static func + (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x + right, y: left.y + right)
    }

    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    static func + (left: CGPoint, right: CGSize) -> CGPoint {
        return CGPoint(x: left.x + right.width, y: left.y + right.height)
    }

    static func += (left: inout CGPoint, right: CGPoint) {
        left = left + right
    }

    static func - (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x - right, y: left.y - right)
    }

    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

    static func - (left: CGPoint, right: CGSize) -> CGPoint {
        return CGPoint(x: left.x - right.width, y: left.y - right.height)
    }

    static func * (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * right, y: left.y * right)
    }

    static func * (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x * right.x, y: left.y * right.y)
    }

    static func * (left: CGPoint, right: CGSize) -> CGPoint {
        return CGPoint(x: left.x * right.width, y: left.y * right.height)
    }

    static func / (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x / right, y: left.y / right)
    }

    static func / (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x / right.x, y: left.y / right.y)
    }

    static func / (left: CGPoint, right: CGSize) -> CGPoint {
        return CGPoint(x: left.x / right.width, y: left.y / right.height)
    }
}
