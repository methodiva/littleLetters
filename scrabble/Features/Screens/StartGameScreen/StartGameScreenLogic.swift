import Foundation
import SwiftyJSON

protocol StartGameScreenViewProtocol: FeatureViewProtocol {
    func onTapBackButton(_ target: Any?, _ handler: Selector)
    func onTapShareKeyButton()
    func showGameStartingLoading(_ onShowing: (() -> Void)?)
    func showWith(key: Int, onShowing: (() -> Void)?)
}

protocol StartGameScreenLogicProtocol: FeatureLogicProtocol {
    func show()
    func startGameEvent()
}

class StartGameScreenLogic: StartGameScreenLogicProtocol {
    private weak var view: StartGameScreenViewProtocol?
    
    private weak var homeScreenLogic: HomeScreenLogicProtocol?
    private weak var gameScreenLogic: GameScreenLogicProtocol?
    private weak var apiLogic: ApiLogicProtocol?
    
    private var didCancelStartGameRequest = false
    
    // MARK: - FeatureProtocol conformance
    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
        guard let uiView = view as? StartGameScreenViewProtocol else {
            log.error("Unknown view type")
            return
        }
        guard let deps = dependencies,
            let homeScreenLogic = deps[.HomeScreen] as? HomeScreenLogicProtocol,
            let gameScreenLogic = deps[.GameScreen] as? GameScreenLogicProtocol,
            let apiLogic = deps[.Api] as? ApiLogicProtocol else {
                log.error("Dependency unfulfilled")
                return
        }
        
        self.homeScreenLogic = homeScreenLogic
        self.gameScreenLogic = gameScreenLogic
        self.apiLogic = apiLogic
        
        
        self.view = uiView
        self.view?.onTapBackButton(self, #selector(goBack))
        self.view?.onTapShareKeyButton()
    }
    
    @objc
    func goBack() {
        log.verbose("Going back to home screen")
        self.didCancelStartGameRequest = true
        self.apiLogic?.didGameOver(onCompleteCallBack: { (data, response, error) in
            guard let data = data, let response = response, error == nil else {
                log.error("Couldnt send the request to end start game, \(String(describing: error))")
                return
            }
            do {
                let jsonResponse = try JSON(data: data)
                log.debug(jsonResponse)
            } catch {
                let error = String(data: data, encoding: .utf8)
                log.error(error ?? "Unknown error occurred")
            }
            gameState = GameState()
            // TODO: If the network isnt working
        })
        self.view?.hide {
            self.homeScreenLogic?.show()
        }
    }
    
    func startGameEvent() {
        log.verbose("Starting Game")
        self.startGame()
    }
    
    func show() {
        log.verbose("Started game menu")
        self.didCancelStartGameRequest = false
        self.view?.showGameStartingLoading({
            self.apiLogic?.didStartGame(onCompleteCallBack: { (data, response, error) in
                guard let data = data, error == nil else {
                    log.error("Couldnt send the request to start game, \(String(describing: error))")
                    return
                }
                do {
                    let jsonResponse = try JSON(data: data)
                    gameState.updateStateFrom(json: jsonResponse)
                    DispatchQueue.main.async {
                        if !self.didCancelStartGameRequest {
                            self.view?.showWith(key: gameState.gameKey, onShowing: {
                                //
                            })
                        }
                    }
                } catch {
                    let error = String(data: data, encoding: .utf8)
                    log.error(error ?? "Unknown error occurred")
                }
            })
        })
        self.view?.show{}
    }
    
    @objc
    func startGame() {
        log.verbose("Starting game")
        self.view?.hide({
            self.gameScreenLogic?.show()
            self.gameScreenLogic?.startTurn()
        })
    }
}
