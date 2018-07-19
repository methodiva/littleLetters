import Foundation

protocol JoinGameScreenViewProtocol: FeatureViewProtocol {
    func onTapBackButton(_ target: Any?, _ handler: Selector)
    func onTapPlayGameButton(_ target: Any?, _ handler: Selector)
}

protocol JoinGameScreenLogicProtocol: FeatureLogicProtocol {
    func show()
}

class JoinGameScreenLogic: JoinGameScreenLogicProtocol {
    private weak var view: JoinGameScreenViewProtocol?
    
    private weak var homeScreenLogic: HomeScreenLogicProtocol?
    private weak var gameScreenLogic: GameScreenLogicProtocol?
    
    // MARK: - FeatureProtocol conformance
    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
        guard let uiView = view as? JoinGameScreenViewProtocol else {
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
        log.verbose("Going back to home screen")
        self.view?.hide {
            self.homeScreenLogic?.show{}
        }
    }
    
    func show() {
        log.verbose("Started join game screen")
        self.view?.show{}
    }
    
    @objc
    func startGame() {
        log.verbose("Starting game")
        self.view?.hide({
            self.gameScreenLogic?.show()
        })
    }
}
