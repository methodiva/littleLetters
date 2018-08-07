import Foundation

protocol EndGameScreenViewProtocol: FeatureViewProtocol {
    func onTapEndGameButton(_ target: Any?, _ handler: Selector)
    func setEndGameVariables(gameResult: GameResult, playerScore: Int, enemyScore: Int)
}

protocol EndGameScreenLogicProtocol: FeatureLogicProtocol {
    func show()
    func showWithParameters(playerScore: Int, enemyScore: Int) 
}

enum GameResult {
    case playerWon
    case enemyWon
    case draw
}

class EndGameScreenLogic: EndGameScreenLogicProtocol {
    private weak var view: EndGameScreenViewProtocol?
    
    private weak var homeScreenLogic: HomeScreenLogicProtocol?
    
    // MARK: - FeatureProtocol conformance
    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
        guard let uiView = view as? EndGameScreenViewProtocol else {
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
        self.view?.onTapEndGameButton(self, #selector(goBack))
    }
    
    @objc
    func goBack() {
        log.verbose("Going back to home screen")
        self.view?.hide {
            self.homeScreenLogic?.show()
        }
    }
    
    func show() {
        log.verbose("Started end game screen")
        self.view?.show{}
    }
    func showWithParameters(playerScore: Int, enemyScore: Int) {
        log.verbose("Started end game screen")
        let gameResult = getGameResult(playerScore: playerScore, enemyScore: enemyScore)
        self.view?.setEndGameVariables(gameResult: gameResult, playerScore: playerScore, enemyScore: enemyScore)
        self.view?.show{}
    }
    
    private func getGameResult(playerScore: Int, enemyScore: Int) -> GameResult {
        if playerScore == enemyScore {
            return .draw
        }
        if playerScore > enemyScore {
            return .playerWon
        }
        return .enemyWon
    }
}
