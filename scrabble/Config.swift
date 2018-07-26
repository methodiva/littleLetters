import UIKit

struct Config {
    // Initialise the structures
    var gameParameters = GameParameters()
    
    // Connect Game Logic
    struct GameParameters {
        var timePerTurnInSeconds = 30
        var maxTriesPerTurn = 3
        var pointsPerLetter = 2
        var minWordLengthForStar = 5
    }
}

var config = Config()
