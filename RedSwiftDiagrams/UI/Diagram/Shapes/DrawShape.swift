import UIKit

protocol DrawShape {
    func draw(on rect: CGRect, with transform: CGAffineTransform, in context: CGContext, selectedUUID: UUID?)
}
