import Foundation
import SwiftyJSON

protocol StartGameScreenViewProtocol: FeatureViewProtocol {
    func onTapBackButton(_ target: Any?, _ handler: Selector)
    func onTapShareKeyButton()
    func showGameStartingLoading(_ onShowing: (() -> Void)?)
    func showWith(key: String, onShowing: (() -> Void)?)
}

protocol StartGameScreenLogicProtocol: FeatureLogicProtocol {
    func show()
}

class StartGameScreenLogic: StartGameScreenLogicProtocol {
    private weak var view: StartGameScreenViewProtocol?
    
    private weak var homeScreenLogic: HomeScreenLogicProtocol?
    private weak var gameScreenLogic: GameScreenLogicProtocol?
    private weak var apiLogic: ApiLogicProtocol?
    
    
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
        self.view?.hide {
            self.homeScreenLogic?.show()
        }
    }
    
    func show() {
        log.verbose("Started game menu")
        self.view?.showGameStartingLoading({
            self.apiLogic?.didStartGame(onCompleteCallBack: { (data, response, error) in
                guard let data = data, error == nil else {
                    log.error("Couldnt send the request to start game, \(error)")
                    return
                }
                if let key = self.getKey(from: data) {
                    DispatchQueue.main.async {
                        self.view?.showWith(key: key, onShowing: {
                         //
                        })
                    }
                }
            })
        })
        self.view?.show{}
    }
    
    func getKey(from data: Data) -> String? {
        do {
            let jsonResponse = try JSON(data: data)
            return jsonResponse["gameKey"].stringValue
        } catch {
            let error = String(data: data, encoding: .utf8)
            log.error(error)
            return nil
        }
    }
    
    @objc
    func startGame() {
        log.verbose("Starting game")
        self.view?.hide({
            self.gameScreenLogic?.show()
        })
    }
}
