import Foundation
import SwiftyJSON

protocol JoinGameScreenViewProtocol: FeatureViewProtocol {
    func onTapBackButton(_ target: Any?, _ handler: Selector)
    func onTapJoinGameButton(_ target: Any?, _ handler: Selector)
    func getGameKey() -> Int?
    func showWaitingForGame()
    func stopWaitingForGame()
    func keyboardDismiss()
    func showFail(with message: String)
}

protocol JoinGameScreenLogicProtocol: FeatureLogicProtocol {
    func show()
    func startGameEvent()
}

class JoinGameScreenLogic: JoinGameScreenLogicProtocol {
    private weak var view: JoinGameScreenViewProtocol?
    
    private weak var homeScreenLogic: HomeScreenLogicProtocol?
    private weak var gameScreenLogic: GameScreenLogicProtocol?
    private weak var apiLogic: ApiLogicProtocol?
    
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
        self.view?.onTapJoinGameButton(self, #selector(joinGame))
    }
    
    @objc
    func goBack() {
        log.verbose("Going back to home screen")
        self.view?.hide {
            self.homeScreenLogic?.show()
        }
    }
    
    func show() {
        log.verbose("Started join game screen")
        self.view?.show{}
    }
    
    @objc
    func joinGame() {
        log.verbose("Sending request for join game")
        self.view?.keyboardDismiss()
        guard let key = self.view?.getGameKey() else {
            return
        }
        self.view?.showWaitingForGame()
        self.apiLogic?.didJoinGame(gameKey: key, onCompleteCallBack: { (data, response, error) in
            guard let data = data, error == nil else {
                log.error("Couldnt send the request to join game, \(String(describing: error))")
                return
            }
            DispatchQueue.main.async {
                self.view?.stopWaitingForGame()
            }
            do {
                let json = try JSON(data: data)
                log.debug(json)
            } catch {
                let error = String(data: data, encoding: .utf8)
                log.error("Bad request to join game, \(String(describing: error))")
                DispatchQueue.main.async {
                    self.view?.showFail(with: "Sorry! Incorrect Key")
                }
            }
        })
    }
    
    func startGameEvent() {
        log.verbose("Start Game")
        self.startGame()
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
