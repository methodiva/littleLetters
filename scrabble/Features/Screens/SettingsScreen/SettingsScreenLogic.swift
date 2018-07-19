import Foundation

protocol SettingsScreenViewProtocol: FeatureViewProtocol {
    func onTapBackButton(_ target: Any?, _ handler: Selector)
}

protocol SettingsScreenLogicProtocol: FeatureLogicProtocol {
    func show()
}

class SettingsScreenLogic: SettingsScreenLogicProtocol {
    private weak var view: SettingsScreenViewProtocol?
    
    private weak var homeScreenLogic: HomeScreenLogicProtocol?
    
    // MARK: - FeatureProtocol conformance
    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
        guard let uiView = view as? SettingsScreenViewProtocol else {
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
        self.view?.onTapBackButton(self, #selector(goBack))
    }
    
    @objc
    func goBack() {
        log.verbose("Stopping connect dots game")
        self.view?.hide {
            self.homeScreenLogic?.show{}
        }
    }
    
    func show() {
        self.view?.show{}
    }
    
    func willAppear(_ animated: Bool) {
    }
    
    func willDisappear(_ animated: Bool) {
    }
}
