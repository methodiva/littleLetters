import Foundation

protocol TimerScreenViewProtocol: FeatureViewProtocol {
    func setTimer(to time: String)
    func setScore(to score: String)
    func setPlayerCards(to numberOfCards: Int)
    func onTapBackButton(_ target: Any?, _ handler: Selector)
    func onTapEndGameButton(_ target: Any?, _ handler: Selector)
}

protocol TimerScreenLogicProtocol: FeatureLogicProtocol {
    func setTimer(to time: String)
    func setScore(to score: String)
    func setPlayerCards(to numberOfCards: Int)
    func show()
}

class TimerScreenLogic: TimerScreenLogicProtocol {
    private weak var view: TimerScreenViewProtocol?
    
    private weak var homeScreenLogic: HomeScreenLogicProtocol?
    private weak var gameScreenLogic: GameScreenLogicProtocol?
    
    // MARK: - FeatureProtocol conformance
    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
        guard let uiView = view as? TimerScreenViewProtocol else {
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
        addHandlersToUI()
    }
    
    private func addHandlersToUI() {
        self.view?.onTapBackButton(self, #selector(goBack))
        self.view?.onTapEndGameButton(self, #selector(endGame))
    }
    
    @objc
    func goBack() {
        log.verbose("Going back to game screen")
        self.view?.hide {
           self.gameScreenLogic?.show()
        }
    }
    
    @objc
    func endGame() {
        log.verbose("Going back to home screen")
        self.view?.hide {
            self.homeScreenLogic?.show()
        }
    }
    
    func show() {
        log.verbose("Started timer screen")
        self.view?.show{}
    }
    
    func setTimer(to time: String) {
        self.view?.setTimer(to: time)
    }
    
    func setPlayerCards(to numberOfCards: Int) {
        self.view?.setPlayerCards(to: numberOfCards)
    }
    
    func setScore(to score: String) {
        self.view?.setScore(to: score)
    }
}
