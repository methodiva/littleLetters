protocol GameScreenViewProtocol: FeatureViewProtocol {
}

protocol GameScreenLogicProtocol: FeatureLogicProtocol {
    func startGame()
}

class GameScreenLogic: GameScreenLogicProtocol {
    private weak var view: GameScreenViewProtocol?
    
    // MARK: - FeatureProtocol conformance
    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
        guard let uiView = view as? GameScreenViewProtocol else {
            log.error("Unknown view type")
            return
        }
        self.view = uiView
    }
    
    func willAppear(_ animated: Bool) {
    }
    
    func willDisappear(_ animated: Bool) {
    }
    
    func startGame() {
        log.verbose("Started Game")
    }
    
    
}
