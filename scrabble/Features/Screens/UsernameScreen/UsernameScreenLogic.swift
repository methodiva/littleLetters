import Foundation

protocol UsernameScreenViewProtocol: FeatureViewProtocol {
    func onTapChangeNameButton(_ target: Any?, _ handler: Selector)
    func getCurrentName() -> String?
    func keyboardDismiss()
}

protocol UsernameScreenLogicProtocol: FeatureLogicProtocol {
    func show()
    func changeName()
}

class UsernameScreenLogic: UsernameScreenLogicProtocol {
    private weak var view: UsernameScreenViewProtocol?
    private weak var homeScreenLogic: HomeScreenLogicProtocol?
    
    // MARK: - FeatureProtocol conformance
    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
        guard let uiView = view as? UsernameScreenViewProtocol else {
            log.error("Unknown view type")
            return
        }
        guard let deps = dependencies,
            let homeScreenLogic = deps[.HomeScreen] as? HomeScreenLogicProtocol else {
                log.error("Dependency unfulfilled")
                return
        }
        self.homeScreenLogic = homeScreenLogic
        self.view = uiView
        addHandlersToUI()
    }
    
    private func addHandlersToUI() {
        self.view?.onTapChangeNameButton(self, #selector(changeName))
    }
    
    @objc
    func changeName(){
        log.verbose("Changed name")
        if let name = self.view?.getCurrentName() {
            UserDefaults.standard.set(name, forKey: "playerName")
            gameState.player.name = name
            self.view?.keyboardDismiss()
            self.view?.hide {
                self.homeScreenLogic?.show()
            }
        }
    }
    
    func show() {
        log.verbose("Started change name screen")
        self.view?.show{}
    }
}
