import Foundation
import SwiftyJSON

protocol EventsLogicProtocol: FeatureLogicProtocol {
    func handleEvent()
}

class EventsLogic: EventsLogicProtocol {
    private weak var apiLogic: ApiLogicProtocol?
    
    func initialize(root: RootProtocol, view: FeatureViewProtocol?, dependencies: [FeatureName : FeatureLogicProtocol]?) {
        guard let deps = dependencies,
            let apiLogic = deps[.Api] as? ApiLogicProtocol else {
                log.error("Dependency unfulfilled")
                return
        }
        self.apiLogic = apiLogic
    }
    
    func handleEvent() {
        // Temp variables ---
        let json = JSON()
        let eventType = ""
        // -----------------
        switch eventType {
        case "start":
            apiLogic?.gameStarted(json: json)
        case "playchance":
            apiLogic?.chancePlayed(json: json)
        case "playword":
            apiLogic?.wordPlayed(json: json)
        case "usewildcard":
            apiLogic?.wildCardUsed(json: json)
        case "over":
            apiLogic?.gameOver(json: json)
        default:
            log.error("Unknown event found")
        }
    }
}
