import DeclarativeTVC
import DITranquillity
import Foundation
import RedSwift
import ReduxVM

class FileInteractor: Interactor<AppState> {
    
    fileprivate let fs: FSService

    init(store: Store<AppState>, fs: FSService)
    {
        self.fs = fs
        super.init(store: store)
    }

    override public var sideEffects: [AnySideEffect] {
        [
            SaveSE(),
            LoadSE(),
        ]
    }
}

extension FileInteractor {
    struct SaveSE: SideEffect {
        func condition(box: StateBox<AppState>) -> Bool {
            box.lastAction is AppState.SaveAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: FileInteractor) {
            _ = interactor.fs.save(value: box.state.diagram.fsDiagram())
        }
    }
    
    struct LoadSE: SideEffect {
        func condition(box: StateBox<AppState>) -> Bool {
            box.lastAction is AppState.LoadAction
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: FileInteractor) {
            interactor.fs.load { result in
                switch result {
                case .success(let diagram):
                    trunk.dispatch(AppState.SetFSDiagramAction(diagram: diagram))
                case .failure(let error):
                    trunk.dispatch(AppState.ErrorAction(error: .error(error.localizedDescription)))
                }
            }
        }
    }

}
