import UIKit

class SeparatorView: UIView {
    
    var indentation: Int = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var color: UIColor = UIColor.separator {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var showLeftSeparator: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var showTopSeparator: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var showRightSeparator: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var showBottomSeparator: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var lineWidth: CGFloat = 2 {
        didSet {
            setNeedsDisplay()
        }
    }

    init() {
        super.init(frame: .zero)
        
        self.contentMode = .redraw
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(rect)
        
        if showBottomSeparator {
            draw1PxStroke(context!,
                          startPoint: CGPoint(x: CGFloat(indentation), y: bounds.height),
                          endPoint: CGPoint(x: bounds.width, y: bounds.height),
                          color: color.cgColor);
        }
        if showTopSeparator {
            draw1PxStroke(context!,
                          startPoint: CGPoint(x: CGFloat(indentation), y: 0),
                          endPoint: CGPoint(x: bounds.width, y: 0),
                          color: color.cgColor);
        }
        if showRightSeparator {
            draw1PxStroke(context!,
                          startPoint: CGPoint(x: bounds.width, y: 0),
                          endPoint: CGPoint(x: bounds.width, y: bounds.height),
                          color: color.cgColor);
        }
        if showLeftSeparator {
            draw1PxStroke(context!,
                          startPoint: CGPoint(x: 0, y: 0),
                          endPoint: CGPoint(x: 0, y: bounds.height),
                          color: color.cgColor);
        }
    }
    
    private func draw1PxStroke(_ context: CGContext, startPoint: CGPoint, endPoint: CGPoint, color: CGColor) {
        context.saveGState()
        context.setLineCap(.square)
        context.setStrokeColor(color)
        context.setLineWidth(lineWidth)
        context.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
        context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
        context.strokePath()
        context.restoreGState()
    }
}
