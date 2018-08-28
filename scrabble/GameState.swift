import SwiftyJSON

var deviceId: String = ""
let maxNameLength = 6


class GameState {
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
         gameId = ""
         gameKey = 0
         currentLetter = "A"
         timeStamp = ""
         currentTurn = "x"
         player = Player()
         if let savedValue = UserDefaults.standard.string(forKey: "playerName") {
            player.name = savedValue
         }
         enemy = Player()
    }
    
    func updateStateFrom(data: [AnyHashable : Any]) {
        if let gameId = data["gameId"] as? String {
            self.gameId = gameId
        }
        if let currentLetter = data["currentLetter"] as? String, let letter = currentLetter.first {
            self.currentLetter = letter
        }
        if let gameKey = data["gameKey"] as? Int {
            self.gameKey = gameKey
        }
        if let currentTurn = data["currentTurn"] as? String {
            self.currentTurn = currentTurn
        }
        
        var playerKey = ""
        var enemyKey = ""
        
        if let playerOne = data["playerOne"] as? [AnyHashable : Any], let id = playerOne["deviceId"] as? String {
            if id == deviceId {
                playerKey = "playerOne"
                enemyKey = "playerTwo"
            } else {
                playerKey = "playerTwo"
                enemyKey = "playerOne"
            }
        }
        
        if let player = data[playerKey] as? [AnyHashable : Any] {
            if let playerName = player["name"] as? String {
                self.player.name = playerName
            }
            if let playerChances = player["chances"] as? Int {
                self.player.chances = playerChances
            }
            if let playerWildCards = player["wildcards"] as? Int {
                self.player.wildCards = playerWildCards
            }
            if let playerScore = player["score"] as? Int {
                self.player.score = playerScore
            }
        }
        
        if let enemy = data[enemyKey] as? [AnyHashable : Any] {
            if let enemyName = enemy["name"] as? String {
                self.enemy.name = enemyName
            }
            if let enemyChances = enemy["chances"] as? Int {
                self.enemy.chances = enemyChances
            }
            if let enemyWildCards = enemy["wildcards"] as? Int {
                self.enemy.wildCards = enemyWildCards
            }
            if let enemyScore = enemy["score"] as? Int {
                self.enemy.score = enemyScore
            }
        }
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
            if deviceId == deviceId {
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
        name = "asd"
        chances = 0
        score = 0
        wildCards = 0
    }
    
}

var gameState = GameState()
