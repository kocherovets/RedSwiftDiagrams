import UIKit

public enum SelectedUUID {
    case list(UUID)
    case arrow(UUID)
}

public enum Cursor {
    case arrow
    case plus(listUUID: UUID, prevItemUUID: UUID?)
}

extension Diagram {
    func selectedUUID(to touchPoint: CGPoint, with transform: CGAffineTransform) -> SelectedUUID? {
        for (uuid, rect) in itemRects {
            if rect.applying(transform).contains(touchPoint) {
                return .list(uuid)
            }
        }
        return nil
    }

    func cursor(to touchPoint: CGPoint, with transform: CGAffineTransform) -> Cursor? {
        for (listUUID, addRect) in addRects {
            if addRect.rect.applying(transform).contains(touchPoint) {
                return .plus(listUUID: listUUID, prevItemUUID: addRect.prevItem)
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

        for index in 0 ..< list.items.count {
            let size = list.items[index].title.boundingRect(with: CGSize(width: 1000, height: ListUI.itemHeight),
                                                            options: [.usesLineFragmentOrigin],
                                                            attributes: ListUI.itemAttributes,
                                                            context: nil).size
            height += ListUI.itemHeight
            let y = origin.y + ListUI.titleHeight + ListUI.itemHeight * CGFloat(index)
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
        addRects[list.header.uuid] = AddRect(prevItem: nil,
                                             rect: CGRect(x: headerRect.x,
                                                          y: headerRect.y + headerRect.height - 3,
                                                          width: headerRect.width,
                                                          height: 6))

        for index in 0 ..< list.items.count {
            height += ListUI.itemHeight
            let rect = CGRect(x: origin.x,
                              y: origin.y + ListUI.titleHeight + ListUI.itemHeight * CGFloat(index),
                              width: width,
                              height: ListUI.itemHeight)
            itemRects[list.items[index].uuid] = rect
            addRects[list.items[index].uuid] = AddRect(prevItem: list.items[index].uuid,
                                                       rect: CGRect(x: rect.x,
                                                                    y: rect.y + rect.height - 3,
                                                                    width: rect.width,
                                                                    height: 6))
        }

        listRects[list.header.uuid] = CGRect(origin: origin, size: CGSize(width: width, height: height))
    }

    func draw(on rect: CGRect,
              with transform: CGAffineTransform,
              in context: CGContext,
              selectedUUID: UUID?) {
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

                for index in 0 ..< list.items.count {
                    context.setFillColor(index % 2 != 0 ? ListUI.oddColor : ListUI.evenColor)
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

                if list.header.uuid == selectedUUID {
                    context.setLineWidth(3)
                    context.setStrokeColor(ListUI.selectedBorderColor)
                } else {
                    context.setLineWidth(1)
                    context.setStrokeColor(ListUI.borderColor)
                }
                context.stroke(headerRect.applying(transform))

                for item in list.items {
                    if item.uuid == selectedUUID {
                        context.setLineWidth(3)
                        context.setStrokeColor(ListUI.selectedBorderColor)
                        guard
                            let rect = itemRects[item.uuid]
                        else { return }
                        context.stroke(rect.applying(transform))
                    }
                }
            }
        }
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

    static let borderColor = UIColor.black.cgColor
    static let selectedBorderColor = UIColor.blue.cgColor
    static let titleBackgroundColor = UIColor(red: 245.0 / 255, green: 186.0 / 255, blue: 137.0 / 255, alpha: 1).cgColor
    static let evenColor = UIColor.white.cgColor
    static let oddColor = UIColor.secondarySystemBackground.cgColor
}
