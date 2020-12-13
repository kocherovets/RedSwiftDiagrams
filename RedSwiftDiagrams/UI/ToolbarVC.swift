import DeclarativeTVC
import DITranquillity
import Foundation
import RedSwift
import ReduxVM
import SnapKit
import UIKit

enum ToolbarVCModule {
    struct Props: Properties, Equatable {
        let typeName: String
        let tags: String
        let undoEnabled: Bool
        let redoEnabled: Bool
        let trashEnabled: Bool
        let changeTypeNameCommand: CommandWith<String>
        let changeTagsCommand: CommandWith<String>
        let addListCommand: Command
        let addLinkCommand: Command
        let loadCommand: Command
        let saveCommand: Command
        let undoCommand: Command
        let redoCommand: Command
        let removeCommand: Command
    }

    class Presenter: PresenterBase<AppState, Props, ViewController> {
        override func reaction(for box: StateBox<AppState>) -> ReactionToState {
            .props
        }

        override func props(for box: StateBox<AppState>, trunk: Trunk) -> Props? {
            let item = box.state.selectedItem()
            return Props(
                typeName: item?.typeName ?? "",
                tags: item?.tags ?? "",
                undoEnabled: box.state.undo.count > 0,
                redoEnabled: box.state.redo.count > 0,
                trashEnabled: box.state.diagram.selected != nil,
                changeTypeNameCommand: CommandWith<String> {
                    trunk.dispatch(AppState.SetTypeNameAction(typeName: $0))
                },
                changeTagsCommand: CommandWith<String> {
                    trunk.dispatch(AppState.SetTagsAction(tags: $0))
                },
                addListCommand: Command {
                    trunk.dispatch(AppState.AddNewListAction())
                },
                addLinkCommand: Command {
                    trunk.dispatch(AppState.StartNewLinkAction())
                },
                loadCommand: Command {
                    trunk.dispatch(AppState.LoadAction())
                },
                saveCommand: Command {
                    trunk.dispatch(AppState.SaveAction())
                },
                undoCommand: Command {
                    trunk.dispatch(AppState.UndoAction())
                },
                redoCommand: Command {
                    trunk.dispatch(AppState.RedoAction())
                },
                removeCommand: Command {
                    trunk.dispatch(AppState.DeleteSelectedAction())
                }
            )
        }
    }

    class ViewController: VC, PropsReceiver {
        typealias Props = ToolbarVCModule.Props

        init(store: Store<AppState>) {
            super.init(nibName: nil, bundle: nil)

            let pr = Presenter(store: store)
            presenter = pr
            pr.propsReceiver = self
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        var typeNameTF: UITextField?
        var tagsTF: UITextField?
        var undoButton: UIButton?
        var redoButton: UIButton?
        var removeButton: UIButton?

        override func viewDidLoad() {
            super.viewDidLoad()

            let addButton = UIButton(type: UIButton.ButtonType.system)
            addButton.setImage(UIImage(systemName: "rectangle.badge.plus"), for: [])
            addButton.addTarget(self, action: #selector(addList), for: .touchUpInside)
            view.addSubview(addButton)
            addButton.snp.makeConstraints { make in
                make.left.equalTo(self.view).offset(16)
                make.centerY.equalTo(self.view)
                make.width.height.equalTo(40)
            }

            let linkButton = UIButton(type: UIButton.ButtonType.system)
            linkButton.setImage(UIImage(systemName: "link"), for: [])
            linkButton.addTarget(self, action: #selector(addLink), for: .touchUpInside)
            view.addSubview(linkButton)
            linkButton.snp.makeConstraints { make in
                make.left.equalTo(addButton.snp.right).offset(10)
                make.centerY.equalTo(self.view)
                make.width.height.equalTo(40)
            }

            let loadButton = UIButton(type: UIButton.ButtonType.system)
            loadButton.setImage(UIImage(systemName: "square.and.arrow.down"), for: [])
            loadButton.addTarget(self, action: #selector(load), for: .touchUpInside)
            view.addSubview(loadButton)
            loadButton.snp.makeConstraints { make in
                make.left.equalTo(linkButton.snp.right).offset(20)
                make.centerY.equalTo(self.view)
                make.width.height.equalTo(40)
            }

            let saveButton = UIButton(type: UIButton.ButtonType.system)
            saveButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: [])
            saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
            view.addSubview(saveButton)
            saveButton.snp.makeConstraints { make in
                make.left.equalTo(loadButton.snp.right).offset(10)
                make.centerY.equalTo(self.view)
                make.width.height.equalTo(40)
            }

            undoButton = UIButton(type: UIButton.ButtonType.system)
            undoButton!.setImage(UIImage(systemName: "arrow.counterclockwise"), for: [])
            undoButton!.addTarget(self, action: #selector(undo), for: .touchUpInside)
            view.addSubview(undoButton!)
            undoButton!.snp.makeConstraints { make in
                make.left.equalTo(saveButton.snp.right).offset(20)
                make.centerY.equalTo(self.view)
                make.width.height.equalTo(40)
            }
            
            redoButton = UIButton(type: UIButton.ButtonType.system)
            redoButton!.setImage(UIImage(systemName: "arrow.clockwise"), for: [])
            redoButton!.addTarget(self, action: #selector(redo), for: .touchUpInside)
            view.addSubview(redoButton!)
            redoButton!.snp.makeConstraints { make in
                make.left.equalTo(undoButton!.snp.right).offset(10)
                make.centerY.equalTo(self.view)
                make.width.height.equalTo(40)
            }

            removeButton = UIButton(type: UIButton.ButtonType.system)
            removeButton!.setImage(UIImage(systemName: "trash"), for: [])
            removeButton!.addTarget(self, action: #selector(trash), for: .touchUpInside)
            view.addSubview(removeButton!)
            removeButton!.snp.makeConstraints { make in
                make.left.equalTo(redoButton!.snp.right).offset(20)
                make.centerY.equalTo(self.view)
                make.width.height.equalTo(40)
            }

            let label1 = UILabel()
            label1.text = "Type:"
            view.addSubview(label1)
            label1.snp.makeConstraints { make in
                make.left.equalTo(removeButton!.snp.right).offset(20)
                make.centerY.equalTo(self.view)
            }

            typeNameTF = UITextField()
            typeNameTF!.delegate = self
            typeNameTF!.borderStyle = .roundedRect
            view.addSubview(typeNameTF!)
            typeNameTF!.snp.makeConstraints { make in
                make.left.equalTo(label1.snp.right).offset(10)
                make.width.equalTo(300)
                make.centerY.equalTo(self.view)
            }

            let label2 = UILabel()
            label2.text = "Tags:"
            view.addSubview(label2)
            label2.snp.makeConstraints { make in
                make.left.equalTo(typeNameTF!.snp.right).offset(20)
                make.centerY.equalTo(self.view)
            }

            tagsTF = UITextField()
            tagsTF!.delegate = self
            tagsTF!.borderStyle = .roundedRect
            view.addSubview(tagsTF!)
            tagsTF!.snp.makeConstraints { make in
                make.left.equalTo(label2.snp.right).offset(10)
                make.width.equalTo(200)
                make.centerY.equalTo(self.view)
            }

            let separator = SeparatorView()
            separator.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(separator)
            separator.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        override func render() {
            guard let props = props else { return }

            typeNameTF?.text = props.typeName
            tagsTF?.text = props.tags
            undoButton?.isEnabled = props.undoEnabled
            redoButton?.isEnabled = props.redoEnabled
            removeButton?.isEnabled = props.trashEnabled
        }

        @objc func addList() {
            props?.addListCommand.perform()
        }

        @objc func addLink() {
            props?.addLinkCommand.perform()
        }

        @objc func load() {
            props?.loadCommand.perform()
        }

        @objc func save() {
            props?.saveCommand.perform()
        }
        @objc func undo() {
            props?.undoCommand.perform()
        }
        @objc func redo() {
            props?.redoCommand.perform()
        }
        @objc func trash() {
            props?.removeCommand.perform()
        }
    }
}

extension ToolbarVCModule.ViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === typeNameTF {
            props?.changeTypeNameCommand.perform(with: textField.text ?? "")
        }
        if textField === tagsTF {
            props?.changeTagsCommand.perform(with: textField.text ?? "")
        }
        textField.endEditing(true)
    }
}

extension UITextField {
    #if targetEnvironment(macCatalyst)
        @objc(_focusRingType)
        var focusRingType: UInt {
            return 1 // NSFocusRingTypeNone
        }
    #endif
}
