import Foundation
import SwiftyJSON

enum RequestType: String {
    case startGame = "start"
    case joinGame = "join"
    case playChance = "playchance"
    case playWord = "playword"
    case useWildCard = "usewildcard"
    case gameover = "over"
    case getGameState = "getgamestate"
}

protocol ApiLogicProtocol: FeatureLogicProtocol {
    
    // Requests
    func didStartGame(onCompleteCallBack: ((Data?, URLResponse?, Error?) ->Void)?)
    func didJoinGame(gameKey: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
    func didPlayChance(chances: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
    func didPlayWord(deviceID: String, gameID: String, score: Int, word: String, wildCards: Int, wildCardPosition: Int, onCompleteCallBack: ((Data)->Void)?)
    func didUseWildCard(deviceID: String, gameID: String, wildCards: Int, onCompleteCallBack: ((Data)->Void)?)
    func didGameOver(deviceID: String, gameID: String, score: Int, onCompleteCallBack: ((Data)->Void)?)
    func getGameState(deviceID: String, gameID: String, onCompleteCallBack: ((Data)->Void)?)
    
    // Events
    func gameStarted(gameID: String, deviceID: String, enemyName: String, isPlayerTurn: Bool, onCompleteCallBack: (()->Void)?)
    func chancePlayed(gameID: String, deviceID: String, didPlayerPlayChance: Bool, chances: Int, onCompleteCallBack: (()->Void)?)
    func wordPlayed(gameID: String, deviceID: String, didPlayerPlayWord: Bool, score: Int, word: String, wildCards: Int, wildCardPosition: Int, onCompleteCallBack: (()->Void)?)
    func wildCardUsed(gameID: String, deviceID: String, didPlayerUseWildCard: Bool, wildCards: Int, onCompleteCallBack: (()->Void)?)
    func gameOver(deviceID: String, gameID: String, enemyScore: Int, playerScore: Int, onCompleteCallBack: (()->Void)?)
}

class ApiLogic: ApiLogicProtocol {
    private weak var gameScreenLogic: GameScreenLogicProtocol?
    private weak var requestsLogic: RequestsLogicProtocol?
    
    func initialize(root: RootProtocol, view: FeatureViewProtocol?, dependencies: [FeatureName : FeatureLogicProtocol]?) {
        guard let deps = dependencies,
            let gameScreenLogic = deps[.GameScreen] as? GameScreenLogicProtocol,
            let requestsLogic = deps[.Requests] as? RequestsLogicProtocol else {
                log.error("Dependency unfulfilled")
                return
        }
        self.gameScreenLogic = gameScreenLogic
        self.requestsLogic = requestsLogic
        
        
        // Test code -------------
//        self.requestsLogic?.didStartGame(deviceID: "1235646436346346", playerName: "12324242", onCompleteCallBack: { (data, response, error) in
//            guard let data = data else{
//                log.error("nonono")
//                return
//            }
//            do {
//                let jsonResponse = try JSON(data: data)
//                let key = jsonResponse["gameKey"].stringValue
//                log.debug(key)
//                    self.requestsLogic?.didJoinGame(deviceID: "112323", playerName: "12345", gameKey: key, onCompleteCallBack: { (data, response, error) in
//                        guard let data = data else{
//                            log.error("nonono")
//                            return
//                        }
//                        do {
//                            let jsonResponse = try JSON(data: data)
//                            log.debug(jsonResponse)
//                        } catch {
//                            let error = String(data: data, encoding: .utf8)
//                            log.error(error)
//                        }
//                    })
//            } catch {
//                let error = String(data: data, encoding: .utf8)
//                log.error(error)
//            }
//        })
        // ---------------
        
    }
    
    // Requests
    func didStartGame(onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
        self.requestsLogic?.didStartGame(deviceID: gameState.deviceId, playerName: gameState.player.name, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didJoinGame(gameKey: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
         self.requestsLogic?.didJoinGame(deviceID: gameState.deviceId, playerName: gameState.player.name, gameKey: gameKey, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didPlayChance(chances: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?)-> Void)?) {
    //    self.requestsLogic?.didPlayChance(deviceID: gameState.deviceId, gameID: gameState.player.name, chances: chances, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didPlayWord(deviceID: String, gameID: String, score: Int, word: String, wildCards: Int, wildCardPosition: Int, onCompleteCallBack: ((Data) -> Void)?) {
//        self.requestsLogic?.didPlayWord(deviceID: deviceID, gameID: gameID, score: score, word: word, wildCards: wildCards, wildCardPosition: wildCardPosition, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didUseWildCard(deviceID: String, gameID: String, wildCards: Int, onCompleteCallBack: ((Data) -> Void)?) {
//        self.requestsLogic?.didUseWildCard(deviceID: deviceID, gameID: gameID, wildCards: wildCards, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didGameOver(deviceID: String, gameID: String, score: Int, onCompleteCallBack: ((Data) -> Void)?) {
//        self.requestsLogic?.didGameOver(deviceID: deviceID, gameID: gameID, score: score, onCompleteCallBack: onCompleteCallBack)
    }
    
    func getGameState(deviceID: String, gameID: String, onCompleteCallBack: ((Data) -> Void)?) {
//        self.requestsLogic?.getGameState(deviceID: deviceID, gameID: gameID, onCompleteCallBack: onCompleteCallBack)
    }
    
    // Events
    func gameStarted(gameID: String, deviceID: String, enemyName: String, isPlayerTurn: Bool, onCompleteCallBack: (() -> Void)?) {
    }
    
    func chancePlayed(gameID: String, deviceID: String, didPlayerPlayChance: Bool, chances: Int, onCompleteCallBack: (() -> Void)?) {
    }
    
    func wordPlayed(gameID: String, deviceID: String, didPlayerPlayWord: Bool, score: Int, word: String, wildCards: Int, wildCardPosition: Int, onCompleteCallBack: (() -> Void)?) {
    }
    
    func wildCardUsed(gameID: String, deviceID: String, didPlayerUseWildCard: Bool, wildCards: Int, onCompleteCallBack: (() -> Void)?) {
    }
    func gameOver(deviceID: String, gameID: String, enemyScore: Int, playerScore: Int, onCompleteCallBack: (()->Void)?) {
        
    }
    
}
