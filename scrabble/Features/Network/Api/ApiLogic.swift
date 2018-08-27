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
    func didJoinGame(gameKey: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
    func didPlayChance(chances: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
    func didPlayWord(score: Int, word: String, wildCards: Int, wildCardPosition: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
    func didUseWildCard(wildCards: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
    func didGameOver(onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
    func getGameState(onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
    
    // Events
    func gameStarted()
    func chancePlayed()
    func wordPlayed(word: String, wildCardPosition: Int)
    func wildCardUsed()
    func gameOver() 
}

class ApiLogic: ApiLogicProtocol {
    private weak var gameScreenLogic: GameScreenLogicProtocol?
    private weak var startGameScreenLogic: StartGameScreenLogicProtocol?
    private weak var joinGameScreenLogic: JoinGameScreenLogicProtocol?
    private weak var requestsLogic: RequestsLogicProtocol?
    
    func initialize(root: RootProtocol, view: FeatureViewProtocol?, dependencies: [FeatureName : FeatureLogicProtocol]?) {
        guard let deps = dependencies,
            let gameScreenLogic = deps[.GameScreen] as? GameScreenLogicProtocol,
            let startGameScreenLogic = deps[.StartGameScreen] as? StartGameScreenLogicProtocol,
            let joinGameScreenLogic = deps[.JoinGameScreen] as? JoinGameScreenLogicProtocol,
            let requestsLogic = deps[.Requests] as? RequestsLogicProtocol else {
                log.error("Dependency unfulfilled")
                return
        }
        self.gameScreenLogic = gameScreenLogic
        self.startGameScreenLogic = startGameScreenLogic
        self.joinGameScreenLogic = joinGameScreenLogic
        self.requestsLogic = requestsLogic
    }
    
    // Requests
    func didStartGame(onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
        self.requestsLogic?.didStartGame(deviceID: deviceId, playerName: gameState.player.name, onCompleteCallBack: onCompleteCallBack)
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
    func gameStarted() {
        if gameState.isTurn {
            startGameScreenLogic?.startGameEvent()
        } else {
            joinGameScreenLogic?.startGameEvent()
        }
    }
    
    func chancePlayed() {
        gameScreenLogic?.playChanceEventHandler()
    }
    
    func wordPlayed(word: String, wildCardPosition: Int) {
        gameScreenLogic?.playWordEventHandler(word: word, wildCardPosition: wildCardPosition)
    }
    
    func wildCardUsed() {
        gameScreenLogic?.useWildCardEventHandler()
    }
    
    func gameOver() {
        gameScreenLogic?.didGameOverEventHandler()
    }
    
}
