import Foundation
import SwiftyJSON

protocol EventsLogicProtocol: FeatureLogicProtocol {
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
    
    func receivePushNotification(data: [AnyHashable : Any]) {
        log.debug(data)
        guard let eventType = data["eventType"] as? String else {
            log.error("Event type for the notfication not recieved")
            return
        }
        gameState.updateStateFrom(data: data)
        switch eventType {
        case "gamestarted":
            gameStarted(data: data)
        case "playchance":
            chancePlayed(data: data)
        case "playword":
            wordPlayed(data: data)
        case "playwildcard":
            wildCardUsed(data: data)
        case "gameover":
            gameOver(data: data)
        default:
            log.error("Unknown event found")
        }
    }
    
    func gameStarted(data: [AnyHashable : Any]) {
        self.apiLogic?.gameStarted()
    }
    
    func chancePlayed(data: [AnyHashable : Any]) {
        self.apiLogic?.chancePlayed()
    }
    
    func wordPlayed(data: [AnyHashable : Any]) {
        if let wildCardPosition = data["wildcardPosition"] as? Int, let word = data["previousWord"] as? String{
            self.apiLogic?.wordPlayed(word: word, wildCardPosition: wildCardPosition)
        }
    }
    
    func wildCardUsed(data: [AnyHashable : Any]) {
        self.apiLogic?.wildCardUsed()
    }
    
    func gameOver(data: [AnyHashable : Any]) {
        self.apiLogic?.gameOver()
    }
}
