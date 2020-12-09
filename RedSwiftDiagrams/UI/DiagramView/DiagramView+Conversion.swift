import UIKit

extension DiagramView {
    func transformFromRealToScreen(realLeftBottom: CGPoint? = nil,
                                   scale: CGPoint? = nil,
                                   contentRect: CGRect? = nil) -> CGAffineTransform {
        let _realLeftBottom = realLeftBottom ?? self.realLeftBottom
        let _scale = scale ?? self.scale
        let _contentRect = contentRect ?? self.contentRect

        let t1 = CGAffineTransform.identity.translatedBy(x: -_realLeftBottom.x,
                                                         y: -_realLeftBottom.y)

        let t2 = CGAffineTransform.identity.scaledBy(x: _scale.x,
                                                     y: -_scale.y)

        let t3 = CGAffineTransform.identity.translatedBy(x: _contentRect.left,
                                                         y: _contentRect.top)

        return t1.concatenating(t2).concatenating(t3)
    }
}
