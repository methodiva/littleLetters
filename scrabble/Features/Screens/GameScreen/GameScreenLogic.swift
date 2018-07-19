import Foundation

protocol GameScreenViewProtocol: FeatureViewProtocol {
    func onTapBackButton(_ target: Any?, _ handler: Selector)
    func onTapGameOverButton(_ target: Any?, _ handler: Selector)
}

protocol GameScreenLogicProtocol: FeatureLogicProtocol {
    func show()
}

class GameScreenLogic: GameScreenLogicProtocol {
    private weak var view: GameScreenViewProtocol?
    private weak var homeScreenLogic: HomeScreenLogicProtocol?
    private weak var cameraLogic: CameraLogicProtocol?
    private weak var endGameScreenLogic: EndGameScreenLogicProtocol?
    
    // MARK: - FeatureProtocol conformance
    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
        guard let uiView = view as? GameScreenViewProtocol else {
            log.error("Unknown view type")
            return
        }
        guard let deps = dependencies,
            let homeScreenLogic = deps[.HomeScreen] as? HomeScreenLogicProtocol,
            let endGameScreenLogic = deps[.EndGameScreen] as? EndGameScreenLogicProtocol,
            let cameraLogic = deps[.Camera] as? CameraLogicProtocol else {
                log.error("Dependency unfulfilled")
                return
        }
        self.homeScreenLogic = homeScreenLogic
        self.endGameScreenLogic = endGameScreenLogic
        self.cameraLogic = cameraLogic
        self.view = uiView
        self.view?.onTapBackButton(self, #selector(goBack))
        self.view?.onTapGameOverButton(self, #selector(endGame))
    }
    
    func willAppear(_ animated: Bool) {
    }
    
    func willDisappear(_ animated: Bool) {
    }
     
    @objc
    func goBack() {
        log.verbose("Stopping connect dots game")
        self.view?.hide {
            self.homeScreenLogic?.show{}
        }
    }
    
    @objc
    func endGame() {
        log.verbose("Stopping connect dots game")
        self.view?.hide {
            self.endGameScreenLogic?.show()
        }
    }
    
    func show() {
        log.verbose("Started Game")
        self.view?.show{
            
        }
    }
    
    
}
