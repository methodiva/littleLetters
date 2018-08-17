import Foundation

enum RequestType: String {
    case startGame = "start"
    case joinGame = "join"
    case playChance = "playchance"
    case playWord = "playword"
    case useWildCard = "usewildcard"
    case gameover = "gameover"
    case getGameState = "getgamestate"
}

protocol ApiLogicProtocol: FeatureLogicProtocol {
    
    // Requests
    func didStartGame(deviceID: String, playerName: String, onCompleteCallBack: ((Data)->Void)?)
    func didJoinGame(deviceID: String, playerName: String, gameKey: String, onCompleteCallBack: ((Data)->Void)?)
    func didPlayChance(deviceID: String, gameID: String, chances: Int, onCompleteCallBack: ((Data)->Void)?)
    func didPlayWord(deviceID: String, gameID: String, score: Int, word: String, wildCards: Int, wildCardPosition: Int, onCompleteCallBack: ((Data)->Void)?)
    func didUseWildCard(deviceID: String, gameID: String, wildCards: Int, onCompleteCallBack: ((Data)->Void)?)
    func didGameGetOver(deviceID: String, gameID: String, score: Int, onCompleteCallBack: ((Data)->Void)?)
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
    private weak var apiLogic: ApiLogicProtocol?
    
    func initialize(root: RootProtocol, view: FeatureViewProtocol?, dependencies: [FeatureName : FeatureLogicProtocol]?) {
        guard let deps = dependencies,
            let gameScreenLogic = deps[.GameScreen] as? GameScreenLogicProtocol,
            let requestsLogic = deps[.Requests] as? RequestsLogicProtocol,
            let apiLogic = deps[.Api] as? ApiLogicProtocol else {
                log.error("Dependency unfulfilled")
                return
        }
        self.gameScreenLogic = gameScreenLogic
        self.requestsLogic = requestsLogic
        self.apiLogic = apiLogic
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
    
    func didGameGetOver(deviceID: String, gameID: String, score: Int, onCompleteCallBack: ((Data) -> Void)?) {
        self.requestsLogic?.didGameGetOver(deviceID: deviceID, gameID: gameID, score: score, onCompleteCallBack: onCompleteCallBack)
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
