protocol EndGameScreenViewProtocol: FeatureViewProtocol {
}

protocol EndGameScreenLogicProtocol: FeatureLogicProtocol {
}

class EndGameScreenLogic: EndGameScreenLogicProtocol {
    private weak var view: EndGameScreenViewProtocol?
    
    // MARK: - FeatureProtocol conformance
    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
        guard let uiView = view as? EndGameScreenViewProtocol else {
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
