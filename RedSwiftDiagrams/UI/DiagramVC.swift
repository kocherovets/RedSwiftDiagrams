import DeclarativeTVC
import DITranquillity
import Foundation
import RedSwift
import ReduxVM
import SnapKit
import UIKit

enum DiagramVCModule {
    struct Props: Properties, Equatable {
        let diagramProps: Diagram.Props
    }

    class Presenter: PresenterBase<AppState, Props, ViewController> {
        override func reaction(for box: StateBox<AppState>) -> ReactionToState {
            .props
        }

        override func props(for box: StateBox<AppState>, trunk: Trunk) -> Props? {
            return Props(
                diagramProps: Diagram.Props(
                    lists: box.state.lists,
                    addItemCommand: CommandWith<(UUID, UUID?)> { listUUID, prevItemUUID in
                        trunk.dispatch(AppState.AddItemAction(listUUID: listUUID, prevUUID: prevItemUUID))
                    },
                    selectCommand: CommandWith<UUID?> {
                        trunk.dispatch(AppState.SetSelectedAction(uuid: $0))
                    },
                    updateListOriginCommand: CommandWith<(UUID, CGPoint)> {
                        trunk.dispatch(AppState.SetListOriginAction(listUUID: $0, origin: $1))
                    },
                    setNewListOriginCommand: CommandWith<CGPoint> {
                        trunk.dispatch(AppState.SetNewListOriginAction(point: $0))
                    }
                )
            )
        }
    }

    class ViewController: VC, PropsReceiver {
        typealias Props = DiagramVCModule.Props

        var diagram: Diagram!

        init(store: Store<AppState>) {
            super.init(nibName: nil, bundle: nil)

            let pr = Presenter(store: store)
            presenter = pr
            pr.propsReceiver = self
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidLoad() {
            super.viewDidLoad()

            diagram = Diagram()
            view.addSubview(diagram)
            diagram.snp.makeConstraints { make in
                make.edges.equalTo(self.view)
            }
        }

        override func render() {
            guard let props = props else { return }

            diagram.props = props.diagramProps
        }
    }
}
