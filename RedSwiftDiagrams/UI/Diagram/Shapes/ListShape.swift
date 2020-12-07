import UIKit

protocol Geometry {
    mutating func updateGeometry(origin: CGPoint)
}

extension List: Geometry {
    mutating func updateGeometry(origin: CGPoint) {
        var height = ListShape.titleHeight
        var width: CGFloat = 100

        let size = header.title.boundingRect(with: CGSize(width: 1000, height: ListShape.titleHeight),
                                             options: [.usesLineFragmentOrigin],
                                             attributes: ListShape.titleAttributes,
                                             context: nil).size
        width = max(size.width + ListShape.marging * 2, width)

        header.rect = CGRect(origin: origin, size: CGSize(width: width, height: ListShape.titleHeight))
        header.titleRect = CGRect(x: origin.x + ListShape.marging,
                                  y: origin.y + (ListShape.titleHeight - size.height) / 2,
                                  width: size.width,
                                  height: size.height)

        for index in 0 ..< items.count {
            height += ListShape.itemHeight
            let size = items[index].title.boundingRect(with: CGSize(width: 1000, height: ListShape.itemHeight),
                                                       options: [.usesLineFragmentOrigin],
                                                       attributes: ListShape.itemAttributes,
                                                       context: nil).size
            width = max(size.width + ListShape.marging * 2, width)
            let rect = CGRect(x: origin.x,
                              y: origin.y + ListShape.titleHeight + ListShape.itemHeight * CGFloat(index),
                              width: width,
                              height: ListShape.itemHeight)
            items[index].rect = rect
            items[index].titleRect = CGRect(x: origin.x + ListShape.marging,
                                            y: rect.y + (ListShape.titleHeight - size.height) / 2,
                                            width: size.width,
                                            height: size.height)
            addRects.append(
                AddRect(prevItem: index == 0 ? nil : items[index - 1].uuid,
                        rect: CGRect(x: rect.x, y: rect.y - 3, width: rect.width, height: 6)
                )
            )
            if index == items.count - 1 {
                addRects.append(
                    AddRect(prevItem: items[items.count - 1].uuid,
                            rect: CGRect(x: rect.x, y: rect.y + ListShape.itemHeight - 3, width: rect.width, height: 6)
                    )
                )
            }
        }

        header.rect.w = width
        for index in 0 ..< items.count {
            items[index].rect.w = width
        }

        rect = CGRect(origin: header.rect.origin, size: CGSize(width: width, height: height))
    }
}

extension ListShape {
    static let titleAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.boldSystemFont(ofSize: fontSise),
        .foregroundColor: UIColor.darkGray,
    ]

    static let itemAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: fontSise),
        .foregroundColor: UIColor.darkGray,
    ]

    static let fontSise: CGFloat = 17
    static let titleHeight: CGFloat = 40
    static let itemHeight: CGFloat = 40
    static let marging: CGFloat = 10
}

struct ListShape: DiagramShape {
    var list: List
    private let _priority: Int
    private let _realBox: CGRect

    init(list: List,
         priority: Int = 0)
    {
        self.list = list
        _priority = priority

        _realBox = list.rect
    }

    var uuid: UUID {
        list.header.uuid
    }

    var priority: Int {
        _priority
    }

    var realBox: CGRect {
        _realBox
    }

    func drawBox(with transform: CGAffineTransform) -> CGRect {
        realBox.applying(transform)
    }

    public func selectedUUID(to touchPoint: CGPoint, with transform: CGAffineTransform) -> SelectedUUID? {
        if list.header.rect.applying(transform).contains(touchPoint) {
            return .list(list.header.uuid)
        }
        for item in list.items {
            if item.rect.applying(transform).contains(touchPoint) {
                return .list(item.uuid)
            }
        }
        return nil
    }

    public func cursor(to touchPoint: CGPoint, with transform: CGAffineTransform) -> Cursor? {
        for addRect in list.addRects {
            if addRect.rect.applying(transform).contains(touchPoint) {
                return .plus(listUUID: list.header.uuid, prevItemUUID: addRect.prevItem)
            }
        }
        return nil
    }

    func draggedList(to touchPoint: CGPoint, with transform: CGAffineTransform) -> UUID? {
        if list.rect.applying(transform).contains(touchPoint) {
            return list.header.uuid
        }
        return nil
    }
}
