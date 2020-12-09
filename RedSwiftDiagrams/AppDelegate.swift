import DITranquillity
import RedSwift
import ReduxVM
import UIKit

class AppFramework: DIFramework {
    static func load(container: DIContainer) {
        container.register(AppState.init).lifetime(.single)

        container.register { DispatchQueue(label: "diagrams", qos: .userInitiated) }
            .as(DispatchQueue.self, name: "storeQueue")
            .lifetime(.single)

        container.register {
            Store<AppState>(state: $0,
                            queue: $1,
                            middleware: [LoggingMiddleware(loggingExcludedActions: [],
                                                           firstPart: "RedSwiftDiagrams"),
                            ])
        }
        .lifetime(.single)
    }
}

let container = DIContainer()

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ReduxVMSettings.logRenderMessages = false
        ReduxVMSettings.logSkipRenderMessages = false
        ReduxVMSettings.logSubscribeMessages = false

        container.append(framework: AppFramework.self)

        #if DEBUG
            if !container.makeGraph().checkIsValid(checkGraphCycles: true) {
                fatalError("invalid graph")
            }
        #endif

        container.initializeSingletonObjects()

        InteractorLogger.loggingExcludedSideEffects = [
        ]

        let uuid1 = UUID()
        let uuid2 = UUID()
        let uuid3 = UUID()
        (container.resolve() as Store<AppState>).dispatch(AppState.SetListsAction(lists: [
            Diagram.ListWithPosition(list: List(header: List.Item(uuid: UUID(),
                                                                  typeName: "Title",
                                                                  tags: ""),
                                                items: [
                                                    List.Item(uuid: uuid1,
                                                              typeName: "Item 1",
                                                              tags: "UIToolbar"),
                                                    List.Item(uuid: UUID(),
                                                              typeName: "Item 2",
                                                              tags: ""),
                                                    List.Item(uuid: uuid3,
                                                              typeName: "Item 3",
                                                              tags: ""),
                                                ]),
                                     origin: .zero),
            Diagram.ListWithPosition(list: List(header: List.Item(uuid: UUID(),
                                                                  typeName: "Title 2",
                                                                  tags: ""),
                                                items: [
                                                    List.Item(uuid: UUID(),
                                                              typeName: "Item df askldjf aksfj sdfsdf sdf sdf",
                                                              tags: ""),
                                                    List.Item(uuid: uuid2,
                                                              typeName: "Item  skdfj sf skdf",
                                                              tags: ""),
                                                ]),
                                     origin: CGPoint(x: 300, y: 300))]))

        (container.resolve() as Store<AppState>).dispatch(AppState.SetLinksAction(links: [
            Diagram.Link(from: uuid1, to: uuid2),
            Diagram.Link(from: uuid3, to: uuid2),
            Diagram.Link(from: uuid2, to: uuid1),
        ]))

        return true
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }

        switch key.keyCode {
        case .keyboardD:
            if key.modifierFlags.contains(.control) {
                (container.resolve() as Store<AppState>).dispatch(AppState.DeleteSelectedAction())
            } default:
            super.pressesBegan(presses, with: event)
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
