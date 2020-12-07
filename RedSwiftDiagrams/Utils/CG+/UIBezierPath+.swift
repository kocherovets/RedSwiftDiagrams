import UIKit

extension UIBezierPath {
    func scaleAroundCenter(factor: CGFloat) {
        let beforeCenter = bounds.center

        // SCALE path by factor
        let scaleTransform = CGAffineTransform(scaleX: factor, y: factor)
        apply(scaleTransform)

        let afterCenter = bounds.center
        let diff = CGPoint(x: beforeCenter.x - afterCenter.x,
                           y: beforeCenter.y - afterCenter.y)

        let translateTransform = CGAffineTransform(translationX: diff.x, y: diff.y)
        apply(translateTransform)
    }
}
