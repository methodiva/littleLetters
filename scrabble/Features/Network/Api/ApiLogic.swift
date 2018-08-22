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
    }
    
    // Requests
    func didStartGame(onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
        self.requestsLogic?.didStartGame(deviceID: gameState.deviceId, playerName: gameState.player.name, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didEndStartGame(onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
        self.requestsLogic?.didEndStartGame(deviceID: gameState.deviceId, gameID: gameState.gameId, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didJoinGame(gameKey: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
         self.requestsLogic?.didJoinGame(deviceID: gameState.deviceId, playerName: gameState.player.name, gameKey: gameKey, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didPlayChance(chances: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?)-> Void)?) {
          self.requestsLogic?.didPlayChance(deviceID: gameState.deviceId, gameID: gameState.gameId, chances: chances, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didPlayWord(score: Int, word: String, wildCards: Int, wildCardPosition: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
        self.requestsLogic?.didPlayWord(deviceID: gameState.deviceId, gameID: gameState.gameId, score: score, word: word, wildCards: wildCards, wildCardPosition: wildCardPosition, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didUseWildCard(wildCards: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
       self.requestsLogic?.didUseWildCard(deviceID: gameState.deviceId, gameID: gameState.gameId, wildCards: wildCards, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didGameOver(onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
       self.requestsLogic?.didGameOver(deviceID: gameState.deviceId, gameID: gameState.gameId, onCompleteCallBack: onCompleteCallBack)
    }
    
    func getGameState(onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
       self.requestsLogic?.getGameState(deviceID: gameState.deviceId, gameID: gameState.gameId, onCompleteCallBack: onCompleteCallBack)
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
