import UIKit

extension CGRect {
    var x: CGFloat {
        get {
            return origin.x
        }
        set {
            origin.x = newValue
        }
    }

    var y: CGFloat {
        get {
            return origin.y
        }
        set {
            origin.y = newValue
        }
    }

    var w: CGFloat {
        get {
            return size.width
        }
        set {
            size.width = newValue
        }
    }

    var h: CGFloat {
        get {
            return size.height
        }
        set {
            size.height = newValue
        }
    }

    var top: CGFloat {
        return origin.y + size.height
    }

    var right: CGFloat {
        return origin.x + size.width
    }

    var left: CGFloat {
        get {
            return origin.x
        }
        set {
            origin.x = newValue
        }
    }

    var bottom: CGFloat {
        get {
            return origin.y
        }
        set {
            origin.y = newValue
        }
    }

    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }

    func scaledAroundCenter(factor: CGFloat) -> CGRect {
        var rect = self
        let beforeCenter = rect.center

        // SCALE path by factor
        let scaleTransform = CGAffineTransform(scaleX: factor, y: factor)
        rect = rect.applying(scaleTransform)

        let afterCenter = rect.center
        let diff = CGPoint(x: beforeCenter.x - afterCenter.x,
                           y: beforeCenter.y - afterCenter.y)

        let translateTransform = CGAffineTransform(translationX: diff.x, y: diff.y)
        rect = rect.applying(translateTransform)

        return rect
    }
}
