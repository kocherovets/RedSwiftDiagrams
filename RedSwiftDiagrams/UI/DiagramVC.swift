import DeclarativeTVC
import DITranquillity
import Foundation
import RedSwift
import ReduxVM
import SnapKit
import UIKit

enum DiagramVCModule {
    struct Props: Properties, Equatable {
        let diagramProps: DiagramView.Props
    }

    class Presenter: PresenterBase<AppState, Props, ViewController> {
        override func reaction(for box: StateBox<AppState>) -> ReactionToState {
            .props
        }

        override func props(for box: StateBox<AppState>, trunk: Trunk) -> Props? {
            return Props(
                diagramProps: DiagramView.Props(
                    diagram: box.state.diagram,
                    addItemCommand: CommandWith<UUID> { prevItemUUID in
                        trunk.dispatch(AppState.AddItemAction(prevUUID: prevItemUUID))
                    },
                    selectCommand: CommandWith<Diagram.Selected?> {
                        trunk.dispatch(AppState.SetSelectedAction(selected: $0))
                    },
                    updateDiagramCommand: CommandWith<Diagram> {
                        trunk.dispatch(AppState.SetDiagramAction(diagram: $0))
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

        var diagram: DiagramView!

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

            diagram = DiagramView()
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
