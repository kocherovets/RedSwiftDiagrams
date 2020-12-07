import RedSwift
import UIKit

class MainVC: UIViewController {
    var toolbarVC = ToolbarVCModule.ViewController(store: container.resolve() as Store<AppState>)
    var diagramVC = DiagramVCModule.ViewController(store: container.resolve() as Store<AppState>)

    override func viewDidLoad() {
        super.viewDidLoad()

        add(toolbarVC) {
            $0.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(0)
                make.left.equalTo(self.view).offset(0)
                make.right.equalTo(self.view).offset(0)
                make.height.equalTo(50)
            }
        }
        add(diagramVC) {
            $0.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(toolbarVC.view.snp.bottom)
                make.left.equalTo(self.view).offset(0)
                make.right.equalTo(self.view).offset(0)
                make.bottom.equalTo(self.view)
            }
        }
    }
}

@nonobjc extension UIViewController {
    func add(_ child: UIViewController, complete: (UIView) -> Void) {
        addChild(child)
        view.addSubview(child.view)
        complete(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
