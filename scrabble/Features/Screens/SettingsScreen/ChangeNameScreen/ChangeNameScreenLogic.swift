import Foundation

protocol ChangeNameScreenViewProtocol: FeatureViewProtocol {
    func onTapBackButton(_ target: Any?, _ handler: Selector)
    func onTapChangeNameButton(_ target: Any?, _ handler: Selector)
}

protocol ChangeNameScreenLogicProtocol: FeatureLogicProtocol {
    func show()
}

class ChangeNameScreenLogic: ChangeNameScreenLogicProtocol {
    private weak var view: ChangeNameScreenViewProtocol?
    private weak var settingsScreenLogic: SettingsScreenLogicProtocol?
    
    // MARK: - FeatureProtocol conformance
    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
        guard let uiView = view as? ChangeNameScreenViewProtocol else {
            log.error("Unknown view type")
            return
        }
        guard let deps = dependencies,
            let settingsScreenLogic = deps[.SettingsScreen] as? SettingsScreenLogicProtocol else {
                log.error("Dependency unfulfilled")
                return
        }
        self.settingsScreenLogic = settingsScreenLogic
        self.view = uiView
        addHandlersToUI()    }
    
    private func addHandlersToUI() {
        self.view?.onTapBackButton(self, #selector(goBack))
        self.view?.onTapChangeNameButton(self, #selector(showChangeNameScreen))
    }
    
    @objc
    func goBack() {
        log.verbose("Going back to settings screen")
        self.view?.hide {
            self.settingsScreenLogic?.show()
        }
    }
    
    @objc
    func showChangeNameScreen(){
        
    }
    
    func show() {
        log.verbose("Started change name screen")
        self.view?.show{}
    }
}