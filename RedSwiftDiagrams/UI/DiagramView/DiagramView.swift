import DeclarativeTVC
import UIKit

public class DiagramView: UIView {
    struct Props: Equatable {
        let diagram: Diagram
        let addItemCommand: CommandWith<UUID>
        let selectCommand: CommandWith<Diagram.Selected?>
        let updateDiagramCommand: CommandWith<Diagram>
        let setNewListOriginCommand: CommandWith<CGPoint>
    }

    var props: Props? {
        didSet {
            if let props = props {
                set(diagram: props.diagram)
            }
        }
    }

    var diagram = Diagram()

    var realRect = CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0)

    private var _scale = CGPoint(x: 1, y: -1)
    var scale: CGPoint {
        return _scale
    }

    var contentRect: CGRect {
        return bounds
    }

    private var _realLeftBottom: CGPoint = .zero
    var realLeftBottom: CGPoint {
        get {
            return _realLeftBottom
        }
        set {
            _realLeftBottom = newValue
            setNeedsDisplay()
        }
    }

    override public var bounds: CGRect {
        didSet {
            if oldValue == .zero {
                if let rect = calculateRealRect() {
                    var delta = rect.origin.applying(transformFromRealToScreen())
                    delta += CGPoint(x: -100, y: contentRect.height - 100)
                    realLeftBottom = delta.applying(transformFromRealToScreen().inverted())
                }
            }
            props?.setNewListOriginCommand.perform(with: realNewListOrigin)
            setNeedsDisplay()
        }
    }

    var realNewListOrigin: CGPoint {
        _realLeftBottom + CGPoint(x: 100,
                                  y: -contentRect.applying(transformFromRealToScreen().inverted()).size.height + 100)
    }

    var minScale = CGPoint(x: 1, y: 1)
    var maxScale = CGPoint(x: CGFloat.greatestFiniteMagnitude, y: CGFloat.greatestFiniteMagnitude)

    var tapGesture: UITapGestureRecognizer!
    var dragGesture: UIPanGestureRecognizer!
    var hoverGestureRecognizer: UIHoverGestureRecognizer!

    var beginDragRealLeftBottom: CGPoint?
    var beginDragRealPoint: CGPoint?
    var dragTransform = CGAffineTransform.identity
    var currentPoint: CGPoint?

    var beginDragRealListOrigin: CGPoint?
    var draggedListIndex: Int?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        contentMode = .redraw
        backgroundColor = UIColor.white
        clipsToBounds = true
        createGestures()
    }
}
