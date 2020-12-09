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

        (container.resolve() as Store<AppState>).dispatch(AppState.SetListsAction(lists: [
            Diagram.ListWithPosition(list: List(header: List.Item(uuid: UUID(),
                                                                  typeName: "Title",
                                                                  tags: ""),
                                                items: [
                                                    List.Item(uuid: UUID(),
                                                              typeName: "Item 1",
                                                              tags: "UIToolbar"),
                                                    List.Item(uuid: UUID(),
                                                              typeName: "Item 2",
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
                                                    List.Item(uuid: UUID(),
                                                              typeName: "Item  skdfj sf skdf",
                                                              tags: ""),
                                                ]),
                                     origin: CGPoint(x: 300, y: 300))]))

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
