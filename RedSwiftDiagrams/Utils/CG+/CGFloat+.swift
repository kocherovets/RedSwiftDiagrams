import UIKit

extension CGFloat {
    func clamp(min: CGFloat, max: CGFloat) -> CGFloat {
        return fmax(fmin(self, max), min)
    }

    func positiveClamp() -> CGFloat {
        return clamp(min: CGFloat.leastNormalMagnitude, max: CGFloat.greatestFiniteMagnitude)
    }

    static func random(min: Double, max: Double) -> CGFloat {
        return CGFloat(drand48() * (max - min) + min)
    }
}
