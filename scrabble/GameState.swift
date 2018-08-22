import SwiftyJSON

class GameState {
    var deviceId: String
    var gameId: String
    var gameKey: Int
    
    var currentTurn: String
    var currentLetter: Character
    var timeStamp: String
    
    var isTurn: Bool {
        get {
           return currentTurn == deviceId
        }
    }
    
    var player: Player
    var enemy: Player
    
    init() {
         deviceId = ""
         gameId = ""
         gameKey = 0
         currentLetter = "A"
         timeStamp = ""
         currentTurn = "x"
         player = Player()
         enemy = Player()
    }
    
    func updateStateFrom(json: JSON) {
        log.debug(json)
        if let gameId = json["gameId"].string {
            self.gameId = gameId
        }
        if let currentLetter = json["currentLetter"].string, let letter = currentLetter.first {
            self.currentLetter = letter
        }
        if let gameKey = json["gameKey"].number {
            self.gameKey = gameKey.intValue
        }
        if let currentTurn = json["currentTurn"].string {
            self.currentTurn = currentTurn
        }
        
        var playerKey = ""
        var enemyKey = ""
        
        if let deviceId = json["playerOne"]["deviceId"].string {
            if deviceId == self.deviceId {
                playerKey = "playerOne"
                enemyKey = "playerTwo"
            } else {
                playerKey = "playerTwo"
                enemyKey = "playerOne"
            }
        }
        
        if let playerName = json[playerKey]["name"].string {
            self.player.name = playerName
        }
        if let playerChances = json[playerKey]["chances"].number {
            self.player.chances = playerChances.intValue
        }
        if let playerWildCards = json[playerKey]["wildcards"].number {
            self.player.wildCards = playerWildCards.intValue
        }
        if let playerScore = json[playerKey]["score"].number {
            self.player.score = playerScore.intValue
        }
        if let enemyName = json[enemyKey]["name"].string {
            self.enemy.name = enemyName
        }
        if let enemyChances = json[enemyKey]["chances"].number {
            self.enemy.chances = enemyChances.intValue
        }
        if let enemyWildCards = json[enemyKey]["wildcards"].number {
            self.enemy.wildCards = enemyWildCards.intValue
        }
        if let enemyScore = json[enemyKey]["score"].number {
            self.enemy.score = enemyScore.intValue
        }
    }
}

struct Player {
    var name: String
    var chances: Int
    var score: Int
    var wildCards: Int
    
    init() {
        name = ""
        chances = 0
        score = 0
        wildCards = 0
    }
    
}

var gameState = GameState()
