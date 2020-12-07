import Foundation
import UIKit

public enum SelectedUUID {
    case list(UUID)
    case arrow(UUID)
}

public enum Cursor {
    case arrow
    case plus(listUUID: UUID, prevItemUUID: UUID?)
}

public protocol DiagramShape {
    var uuid: UUID { get }

    var priority: Int { get }
    var realBox: CGRect { get }

    func drawBox(with transform: CGAffineTransform) -> CGRect

    func selectedUUID(to touchPoint: CGPoint, with transform: CGAffineTransform) -> SelectedUUID?

    func cursor(to touchPoint: CGPoint, with transform: CGAffineTransform) -> Cursor?

    func draggedList(to touchPoint: CGPoint, with transform: CGAffineTransform) -> UUID?
}

extension DiagramShape {
    public func selectedUUID(to touchPoint: CGPoint, with transform: CGAffineTransform) -> SelectedUUID? {
        return nil
    }

    public func cursor(to touchPoint: CGPoint, with transform: CGAffineTransform) -> Cursor? {
        nil
    }

    func draggedList(to touchPoint: CGPoint, with transform: CGAffineTransform) -> UUID? {
        nil
    }

    public var priority: Int {
        return 0
    }
}
