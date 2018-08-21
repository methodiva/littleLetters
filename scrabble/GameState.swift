struct GameState {
    var deviceId: String
    var gameId: String
    var gameKey: Int
    
    var currentLetter: Character
    var timeStamp: String
    
    var player: Player
    var enemy: Player
}

struct Player {
    var name: String
    var chances: Int
    var score: Int
    var wildCards: Int
}


var gameState = GameState(deviceId: "",
                          gameId: "",
                          gameKey: 0,
                          currentLetter: "A",
                          timeStamp: "",
                          player: Player(name: playerName, chances: 0, score: 0, wildCards: 0),
                          enemy: Player(name: "", chances: 0, score: 0, wildCards: 0))
