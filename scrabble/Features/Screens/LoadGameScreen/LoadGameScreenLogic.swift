import Foundation

protocol LoadGameScreenViewProtocol: FeatureViewProtocol {
    func onTapBackButton(_ target: Any?, _ handler: Selector)
    func onTapPlayGameButton(_ target: Any?, _ handler: Selector)
}

protocol LoadGameScreenLogicProtocol: FeatureLogicProtocol {
    func show()
}

class LoadGameScreenLogic: LoadGameScreenLogicProtocol {
    private weak var view: LoadGameScreenViewProtocol?
    
    private weak var homeScreenLogic: HomeScreenLogicProtocol?
    private weak var gameScreenLogic: GameScreenLogicProtocol?
    
    // MARK: - FeatureProtocol conformance
    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
        guard let uiView = view as? LoadGameScreenViewProtocol else {
            log.error("Unknown view type")
            return
        }
        guard let deps = dependencies,
            let homeScreenLogic = deps[.HomeScreen] as? HomeScreenLogicProtocol,
            let gameScreenLogic = deps[.GameScreen] as? GameScreenLogicProtocol else {
                log.error("Dependency unfulfilled")
                return
        }
        
        self.homeScreenLogic = homeScreenLogic
        self.gameScreenLogic = gameScreenLogic
        
        self.view = uiView
        self.view?.onTapBackButton(self, #selector(goBack))
        self.view?.onTapPlayGameButton(self, #selector(startGame))
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
    
    @objc
    func startGame() {
        self.gameScreenLogic?.startGame()
    }
    
    func willAppear(_ animated: Bool) {
    }
    
    func willDisappear(_ animated: Bool) {
    }
}
