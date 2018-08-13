import Foundation

protocol SettingsScreenViewProtocol: FeatureViewProtocol {
    func onTapBackButton(_ target: Any?, _ handler: Selector)
    func onTapChangeNameButton(_ target: Any?, _ handler: Selector)
    func onTapRateUsButton()
}

protocol SettingsScreenLogicProtocol: FeatureLogicProtocol {
    func show()
}

class SettingsScreenLogic: SettingsScreenLogicProtocol {
    private weak var view: SettingsScreenViewProtocol?
    
    private weak var homeScreenLogic: HomeScreenLogicProtocol?
    private weak var changeNameScreenLogic: ChangeNameScreenLogicProtocol?
    
    // MARK: - FeatureProtocol conformance
    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
        guard let uiView = view as? SettingsScreenViewProtocol else {
            log.error("Unknown view type")
            return
        }
        guard let deps = dependencies,
            let homeScreenLogic = deps[.HomeScreen] as? HomeScreenLogicProtocol,
            let changeNameScreenLogic = deps[.ChangeNameScreen] as? ChangeNameScreenLogicProtocol else {
                log.error("Dependency unfulfilled")
                return
        }
        self.homeScreenLogic = homeScreenLogic
        self.changeNameScreenLogic = changeNameScreenLogic
        self.view = uiView
        addHandlersToUI()
    }
    
    private func addHandlersToUI() {
        self.view?.onTapBackButton(self, #selector(goBack))
        self.view?.onTapChangeNameButton(self, #selector(showChangeNameScreen))
        self.view?.onTapRateUsButton()
    }
    
    @objc
    func goBack() {
        log.verbose("Going back to home screen")
        self.view?.hide {
            self.homeScreenLogic?.show()
        }
    }
    
    @objc
    func showChangeNameScreen(){
        log.verbose("Showing change name screen")
        self.view?.hide {
            self.changeNameScreenLogic?.show()
        }
    }
    
    func show() {
        log.verbose("Started settings screen")
        self.view?.show{}
    }
}
