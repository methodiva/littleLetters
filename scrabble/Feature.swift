import Foundation

struct Feature {
    var logic: FeatureLogicProtocol
    var dependencies: [FeatureName]?
    var view: FeatureViewProtocol?
    var viewOrder: Int?
}

// swiftlint:disable identifier_name
enum FeatureName {
    case Camera
    case Api
    case Events
    case Requests
    case UsernameScreen
    case HomeScreen
    case StartGameScreen
    case EndGameScreen
    case TimerScreen
    case GameScreen
    case TutorialScreen
    case SettingsScreen
    case ChangeNameScreen
    case JoinGameScreen
    case ObjectRecognizer
}
// swiftlint:enable identifier_name

protocol FeatureLogicProtocol: class {
    func initialize(root: RootProtocol, view: FeatureViewProtocol?, dependencies: [FeatureName: FeatureLogicProtocol]?)
    func willAppear(_ animated: Bool)
    func willDisappear(_ animated: Bool)
    func receivePushNotification(data: [AnyHashable : Any])
    func applicationWillTerminate()
    func applicationDidEnterBackground()
    func applicationDidEnterForeground()
    func dispose()
}

extension FeatureLogicProtocol {
    func willAppear(_ animated: Bool) {}
    func willDisappear(_ animated: Bool) {}
    func receivePushNotification(data: [AnyHashable : Any]) {}
    func applicationDidEnterBackground() {}
    func applicationWillTerminate() {}
    func applicationDidEnterForeground() {}
    func dispose() {}
}

protocol FeatureViewProtocol: class {
    func show(_ onShowing: (() -> Void)?)
    func hide(_ onHidden: (() -> Void)?)
    func removeFromSuperview()
}

extension FeatureViewProtocol {
    func show(_ onShowing: (() -> Void)?) {
        onShowing?()
    }
    func hide(_ onHidden: (() -> Void)?) {
        onHidden?()
    }
}
