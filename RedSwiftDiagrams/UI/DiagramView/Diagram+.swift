import UIKit

public enum Cursor {
    case arrow
    case plus(prevItemUUID: UUID)
}

extension Diagram {
    func selected(to touchPoint: CGPoint, with transform: CGAffineTransform) -> Diagram.Selected? {
        for (uuid, rect) in itemRects {
            if rect.applying(transform).contains(touchPoint) {
                return .item(uuid: uuid)
            }
        }
        for uuid in links.map({ $0.from }) {
            if linkFromRect(uuid: uuid)?.applying(transform).contains(touchPoint) == true {
                return .from(uuid: uuid)
            }
        }
        for uuid in links.map({ $0.to }) {
            if linkToRect(uuid: uuid)?.applying(transform).contains(touchPoint) == true {
                return .to(uuid: uuid)
            }
        }
        return nil
    }

    func cursor(to touchPoint: CGPoint, with transform: CGAffineTransform) -> Cursor? {
        for (itemUUID, addRect) in addRects {
            if addRect.applying(transform).contains(touchPoint) {
                return .plus(prevItemUUID: itemUUID)
            }
        }
        return nil
    }

    func draggedList(to touchPoint: CGPoint, with transform: CGAffineTransform) -> UUID? {
        for (uuid, rect) in listRects {
            if rect.applying(transform).contains(touchPoint) {
                return uuid
            }
        }
        return nil
    }

    mutating func updateGeometry(list: List) {
        let origin = listRects[list.uuid]?.origin ?? .zero
        eraseRects(uuid: list.uuid)

        var height = ListUI.titleHeight
        var width: CGFloat = 100

        let size = list.header.title.boundingRect(with: CGSize(width: 1000, height: ListUI.titleHeight),
                                                  options: [.usesLineFragmentOrigin],
                                                  attributes: ListUI.titleAttributes,
                                                  context: nil).size
        width = max(size.width + ListUI.marging * 2, width)
        titleRects[list.header.uuid] = CGRect(x: origin.x + ListUI.marging,
                                              y: origin.y + (ListUI.titleHeight - size.height) / 2,
                                              width: size.width,
                                              height: size.height)

        for index in 1 ..< list.items.count {
            let size = list.items[index].title.boundingRect(with: CGSize(width: 1000, height: ListUI.itemHeight),
                                                            options: [.usesLineFragmentOrigin],
                                                            attributes: ListUI.itemAttributes,
                                                            context: nil).size
            height += ListUI.itemHeight
            let y = origin.y + ListUI.titleHeight + ListUI.itemHeight * CGFloat(index - 1)
            titleRects[list.items[index].uuid] = CGRect(x: origin.x + ListUI.marging,
                                                        y: y + (ListUI.itemHeight - size.height) / 2,
                                                        width: size.width,
                                                        height: size.height)
            width = max(size.width + ListUI.marging * 2, width)
        }

        //

        height = ListUI.titleHeight

        let headerRect = CGRect(origin: origin, size: CGSize(width: width, height: ListUI.titleHeight))
        itemRects[list.header.uuid] = headerRect
        addRects[list.header.uuid] = CGRect(x: headerRect.x,
                                            y: headerRect.y + headerRect.height - 3,
                                            width: headerRect.width,
                                            height: 6)

        for index in 1 ..< list.items.count {
            height += ListUI.itemHeight
            let rect = CGRect(x: origin.x,
                              y: origin.y + ListUI.titleHeight + ListUI.itemHeight * CGFloat(index - 1),
                              width: width,
                              height: ListUI.itemHeight)
            itemRects[list.items[index].uuid] = rect
            addRects[list.items[index].uuid] = CGRect(x: rect.x,
                                                      y: rect.y + rect.height - 3,
                                                      width: rect.width,
                                                      height: 6)
        }

        listRects[list.uuid] = CGRect(origin: origin, size: CGSize(width: width, height: height))
    }

    func draw(on rect: CGRect,
              with transform: CGAffineTransform,
              in context: CGContext,
              selected: Diagram.Selected?) {
        for list in lists {
            if let listRect = listRects[list.uuid],
               rect.intersects(listRect.applying(transform)) {
                context.setFillColor(ListUI.titleBackgroundColor)

                guard
                    let headerRect = itemRects[list.uuid],
                    let headerTitleRect = titleRects[list.uuid]
                else { return }
                context.fill(headerRect.applying(transform))
                list.header.title.draw(with: headerTitleRect.applying(transform),
                                       options: [.usesLineFragmentOrigin],
                                       attributes: ListUI.titleAttributes,
                                       context: nil)

                for index in 1 ..< list.items.count {
                    context.setFillColor(index % 2 == 0 ? ListUI.oddColor : ListUI.evenColor)
                    guard
                        let rect = itemRects[list.items[index].uuid],
                        let titleRect = titleRects[list.items[index].uuid]
                    else { return }
                    context.fill(rect.applying(transform))
                    list.items[index].title.draw(with: titleRect.applying(transform),
                                                 options: [.usesLineFragmentOrigin],
                                                 attributes: ListUI.itemAttributes,
                                                 context: nil)
                }

                context.setLineWidth(1)
                context.setStrokeColor(ListUI.borderColor)
                context.stroke(listRect.applying(transform))
                context.stroke(headerRect.applying(transform))
            }
        }

        context.setLineWidth(1)
        context.setStrokeColor(ListUI.borderColor)
        for link in links {
            if let lable = linkLables[link.to] {
                let size = lable.boundingRect(with: CGSize(width: 1000, height: ListUI.linkDiameter),
                                              options: [.usesLineFragmentOrigin],
                                              attributes: ListUI.itemAttributes,
                                              context: nil).size
                if let linkRect = linkFromRect(uuid: link.from)?.applying(transform) {
                    context.strokeEllipse(in: linkRect)
                    let lableRect = CGRect(origin: CGPoint(x: linkRect.x + (linkRect.width - size.width) / 2,
                                                           y: linkRect.y + (linkRect.height - size.height) / 2),
                                           size: size)
                    lable.draw(with: lableRect,
                               options: [.usesLineFragmentOrigin],
                               attributes: ListUI.itemAttributes,
                               context: nil)
                }
                if let linkRect = linkToRect(uuid: link.to)?.applying(transform) {
                    context.strokeEllipse(in: linkRect)
                    let lableRect = CGRect(origin: CGPoint(x: linkRect.x + (linkRect.width - size.width) / 2,
                                                           y: linkRect.y + (linkRect.height - size.height) / 2),
                                           size: size)
                    lable.draw(with: lableRect,
                               options: [.usesLineFragmentOrigin],
                               attributes: ListUI.itemAttributes,
                               context: nil)
                }
            }
        }
        
        context.setLineWidth(3)
        context.setStrokeColor(ListUI.selectedBorderColor)
        switch selected {
        case let .item(uuid):
            guard
                let rect = itemRects[uuid]
            else { return }
            context.stroke(rect.applying(transform))
        case let .from(uuid):
            guard
                let rect = linkFromRect(uuid: uuid)
            else { return }
            context.strokeEllipse(in: rect.applying(transform))
        case let .to(uuid):
            guard
                let rect = linkToRect(uuid: uuid)
            else { return }
            context.strokeEllipse(in: rect.applying(transform))
        default:
            break
        }
    }

    func linkFromRect(uuid: UUID) -> CGRect? {
        if let rect = itemRects[uuid] {
            return CGRect(x: rect.right + 10,
                          y: rect.y + ListUI.linkMargin,
                          width: ListUI.linkDiameter,
                          height: ListUI.linkDiameter)
        }
        return nil
    }

    func linkToRect(uuid: UUID) -> CGRect? {
        if let rect = itemRects[uuid] {
            return CGRect(x: rect.left - 10 - ListUI.linkDiameter,
                          y: rect.y + ListUI.linkMargin,
                          width: ListUI.linkDiameter,
                          height: ListUI.linkDiameter)
        }
        return nil
    }
}

struct ListUI {
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
    static let linkDiameter: CGFloat = ListUI.itemHeight - 10
    static let linkMargin: CGFloat = (ListUI.itemHeight - linkDiameter) / 2

    static let borderColor = UIColor.black.cgColor
    static let selectedBorderColor = UIColor.blue.cgColor
    static let titleBackgroundColor = UIColor(red: 245.0 / 255, green: 186.0 / 255, blue: 137.0 / 255, alpha: 1).cgColor
    static let evenColor = UIColor.white.cgColor
    static let oddColor = UIColor.secondarySystemBackground.cgColor
}
