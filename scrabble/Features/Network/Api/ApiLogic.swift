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
    func didStartGame(deviceID: String, playerName: String, onCompleteCallBack: ((Data)->Void)?)
    func didJoinGame(deviceID: String, playerName: String, gameKey: String, onCompleteCallBack: ((Data)->Void)?)
    func didPlayChance(deviceID: String, gameID: String, chances: Int, onCompleteCallBack: ((Data)->Void)?)
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
        self.requestsLogic?.didStartGame(deviceID: "1235646436346346", playerName: "12324242", onCompleteCallBack: { (data) in
            do {
                let jsonResponse = try JSON(data: data)
                let key = jsonResponse["gameKey"].stringValue
                log.debug(key)
                    self.requestsLogic?.didJoinGame(deviceID: "112323", playerName: "12345", gameKey: key, onCompleteCallBack: { (data) in
                        do {
                            let jsonResponse = try JSON(data: data)
                            log.debug(jsonResponse)
                        } catch {
                            let error = String(data: data, encoding: .utf8)
                            log.error(error)
                        }
                    })
            } catch {
                let error = String(data: data, encoding: .utf8)
                log.error(error)
            }
        })
        // ---------------
        
    }
    
    // Requests
    func didStartGame(deviceID: String, playerName: String, onCompleteCallBack: ((Data) -> Void)?) {
        self.requestsLogic?.didStartGame(deviceID: deviceID, playerName: playerName, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didJoinGame(deviceID: String, playerName: String, gameKey: String, onCompleteCallBack: ((Data) -> Void)?) {
        self.requestsLogic?.didJoinGame(deviceID: deviceID, playerName: playerName, gameKey: gameKey, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didPlayChance(deviceID: String, gameID: String, chances: Int, onCompleteCallBack: ((Data) -> Void)?) {
        self.requestsLogic?.didPlayChance(deviceID: deviceID, gameID: gameID, chances: chances, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didPlayWord(deviceID: String, gameID: String, score: Int, word: String, wildCards: Int, wildCardPosition: Int, onCompleteCallBack: ((Data) -> Void)?) {
        self.requestsLogic?.didPlayWord(deviceID: deviceID, gameID: gameID, score: score, word: word, wildCards: wildCards, wildCardPosition: wildCardPosition, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didUseWildCard(deviceID: String, gameID: String, wildCards: Int, onCompleteCallBack: ((Data) -> Void)?) {
        self.requestsLogic?.didUseWildCard(deviceID: deviceID, gameID: gameID, wildCards: wildCards, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didGameOver(deviceID: String, gameID: String, score: Int, onCompleteCallBack: ((Data) -> Void)?) {
        self.requestsLogic?.didGameOver(deviceID: deviceID, gameID: gameID, score: score, onCompleteCallBack: onCompleteCallBack)
    }
    
    func getGameState(deviceID: String, gameID: String, onCompleteCallBack: ((Data) -> Void)?) {
        self.requestsLogic?.getGameState(deviceID: deviceID, gameID: gameID, onCompleteCallBack: onCompleteCallBack)
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
