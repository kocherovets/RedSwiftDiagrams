import UIKit

extension CGSize {
    var asPoint: CGPoint {
        return CGPoint(x: width, y: height)
    }

    static var veryBig: CGSize {
        return CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    }

    static func + (left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(width: left.width + right, height: left.height + right)
    }

    static func + (left: CGSize, right: CGPoint) -> CGSize {
        return CGSize(width: left.width + right.x, height: left.height + right.y)
    }

    static func + (left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width + right.width, height: left.height + right.height)
    }

    static func += (left: inout CGSize, right: CGSize) {
        left = left + right
    }

    static func - (left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(width: left.width - right, height: left.height - right)
    }

    static func - (left: CGSize, right: CGPoint) -> CGSize {
        return CGSize(width: left.width - right.x, height: left.height - right.y)
    }

    static func - (left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width - right.width, height: left.height - right.height)
    }

    static func * (left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(width: left.width * right, height: left.height * right)
    }

    static func * (left: CGSize, right: CGPoint) -> CGSize {
        return CGSize(width: left.width * right.x, height: left.height * right.y)
    }

    static func * (left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width * right.width, height: left.height * right.height)
    }

    static func / (left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(width: left.width / right, height: left.height / right)
    }

    static func / (left: CGSize, right: CGPoint) -> CGSize {
        return CGSize(width: left.width / right.x, height: left.height / right.y)
    }

    static func / (left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width / right.width, height: left.height / right.height)
    }
}
