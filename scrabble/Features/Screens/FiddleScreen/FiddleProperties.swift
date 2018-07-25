import Foundation
import UIKit

struct ConfigProperty {
    let propertyName: String
    var value: Int
    let minBound: Int
    let maxBound: Int
}

struct Section {
    let name: String
    var properties: [ConfigProperty]
}

class FiddleScreenProperties {
    //Remember to add the attribute to display the feature in both the array and the didSet function
    var tableData = [
        Section(name: "Game Parameters",
                properties:[
                    ConfigProperty(
                        propertyName: "Timer/turn in seconds",
                        value: config.gameParameters.timePerTurnInSeconds,
                        minBound: 10,
                        maxBound: 120
                    ),
                    ConfigProperty(
                        propertyName: "Tries per turn",
                        value: config.gameParameters.maxTriesPerTurn,
                        minBound: 1,
                        maxBound: 10
                    ),
                    ConfigProperty(
                        propertyName: "Points per letter",
                        value: config.gameParameters.pointsPerLetter,
                        minBound: 1,
                        maxBound: 30
                    ),
                    ConfigProperty(
                        propertyName: "Minimum word length for star",
                        value: config.gameParameters.minWordLengthForStar,
                        minBound: 1,
                        maxBound: 20
                    ),
                ])
        ] {
        didSet {
            config.gameParameters.timePerTurnInSeconds = self.tableData[0].properties[0].value
            config.gameParameters.maxTriesPerTurn = self.tableData[0].properties[1].value
            config.gameParameters.pointsPerLetter = self.tableData[0].properties[2].value
            config.gameParameters.minWordLengthForStar = self.tableData[0].properties[3].value
        }
    }
}
var property = FiddleScreenProperties()
