import Foundation
import SwiftyJSON

enum RequestType: String {
    case startGame = "start"
    case endStartGame = "endstart"
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
    func didEndStartGame(onCompleteCallBack: ((Data?, URLResponse?, Error?) ->Void)?)
    func didJoinGame(gameKey: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
    func didPlayChance(chances: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
    func didPlayWord(score: Int, word: String, wildCards: Int, wildCardPosition: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
    func didUseWildCard(wildCards: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
    func didGameOver(onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
    func getGameState(onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
    
    // Events
    func gameStarted(json: JSON)
    func chancePlayed(json: JSON)
    func wordPlayed(json: JSON)
    func wildCardUsed(json: JSON)
    func gameOver(json: JSON)
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
    }
    
    // Requests
    func didStartGame(onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
        self.requestsLogic?.didStartGame(deviceID: deviceId, playerName: gameState.player.name, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didEndStartGame(onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
        self.requestsLogic?.didEndStartGame(deviceID: deviceId, gameID: gameState.gameId, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didJoinGame(gameKey: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
         self.requestsLogic?.didJoinGame(deviceID: deviceId, playerName: gameState.player.name, gameKey: gameKey, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didPlayChance(chances: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?)-> Void)?) {
          self.requestsLogic?.didPlayChance(deviceID: deviceId, gameID: gameState.gameId, chances: chances, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didPlayWord(score: Int, word: String, wildCards: Int, wildCardPosition: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
        self.requestsLogic?.didPlayWord(deviceID: deviceId, gameID: gameState.gameId, score: score, word: word, wildCards: wildCards, wildCardPosition: wildCardPosition, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didUseWildCard(wildCards: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
       self.requestsLogic?.didUseWildCard(deviceID: deviceId, gameID: gameState.gameId, wildCards: wildCards, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didGameOver(onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
       self.requestsLogic?.didGameOver(deviceID: deviceId, gameID: gameState.gameId, onCompleteCallBack: onCompleteCallBack)
    }
    
    func getGameState(onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
       self.requestsLogic?.getGameState(deviceID: deviceId, gameID: gameState.gameId, onCompleteCallBack: onCompleteCallBack)
    }
    
    // Events
    func gameStarted(json: JSON) {
        gameState.updateStateFrom(json: json)
        
    }
    
    func chancePlayed(json: JSON) {
        gameState.updateStateFrom(json: json)
        self.gameScreenLogic?.playChanceEventHandler()
    }
    
    func wordPlayed(json: JSON) {
        gameState.updateStateFrom(json: json)
        if let word = json["word"].string, let wildCardPosition = json["wildCardPosition"].number?.intValue {
            self.gameScreenLogic?.playWordEventHandler(word: word, wildCardPosition: wildCardPosition)
        }
    }
    
    func wildCardUsed(json: JSON) {
        gameState.updateStateFrom(json: json)
        self.gameScreenLogic?.useWildCardEventHandler()
    }
    
    func gameOver(json: JSON) {
        gameState.updateStateFrom(json: json)
        self.gameScreenLogic?.didGameOverEventHandler()
        
    }
    
}
