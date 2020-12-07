import UIKit

extension ListShape: DrawShape {
    static let borderColor = UIColor.black.cgColor
    static let selectedBorderColor = UIColor.blue.cgColor
    static let titleBackgroundColor = UIColor(red: 245.0 / 255, green: 186.0 / 255, blue: 137.0 / 255, alpha: 1).cgColor
    static let evenColor = UIColor.white.cgColor
    static let oddColor = UIColor.secondarySystemBackground.cgColor

    func draw(on rect: CGRect,
              with transform: CGAffineTransform,
              in context: CGContext,
              selectedUUID: UUID?)
    {
        if rect.intersects(list.rect.applying(transform)) {
            context.setFillColor(ListShape.titleBackgroundColor)
            context.fill(list.header.rect.applying(transform))
            list.header.item.title.draw(with: list.header.titleRect.applying(transform),
                                        options: [.usesLineFragmentOrigin],
                                        attributes: ListShape.titleAttributes,
                                        context: nil)

            for index in 0 ..< list.items.count {
                context.setFillColor(index % 2 != 0 ? ListShape.oddColor : ListShape.evenColor)
                context.fill(list.items[index].rect.applying(transform))
                list.items[index].title.draw(with: list.items[index].titleRect.applying(transform),
                                             options: [.usesLineFragmentOrigin],
                                             attributes: ListShape.itemAttributes,
                                             context: nil)
            }

            context.setLineWidth(1)
            context.setStrokeColor(ListShape.borderColor)
            context.stroke(list.header.rect.applying(transform))

            if list.header.uuid == selectedUUID {
                context.setLineWidth(3)
                context.setStrokeColor(ListShape.selectedBorderColor)
            } else {
                context.setLineWidth(1)
                context.setStrokeColor(ListShape.borderColor)
            }
            context.stroke(list.rect.applying(transform))

            for item in list.items {
                if item.uuid == selectedUUID {
                    context.setLineWidth(3)
                    context.setStrokeColor(ListShape.selectedBorderColor)
                    context.stroke(item.rect.applying(transform))
                }
            }
        }
    }
}
