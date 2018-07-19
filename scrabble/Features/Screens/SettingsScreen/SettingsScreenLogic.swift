protocol SettingsScreenViewProtocol: FeatureViewProtocol {
}

protocol SettingsScreenLogicProtocol: FeatureLogicProtocol {
}

class SettingsScreenLogic: SettingsScreenLogicProtocol {
    private weak var view: SettingsScreenViewProtocol?
    
    // MARK: - FeatureProtocol conformance
    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
        guard let uiView = view as? SettingsScreenViewProtocol else {
            log.error("Unknown view type")
            return
        }
        self.view = uiView
    }
    
    func willAppear(_ animated: Bool) {
    }
    
    func willDisappear(_ animated: Bool) {
    }
}
