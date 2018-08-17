import Foundation

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
    
    func gameStarted() {
 //      self.apiLogic?.gameStarted(gameID: <#T##String#>, deviceID: <#T##String#>, enemyName: <#T##String#>, isPlayerTurn: <#T##Bool#>, onCompleteCallBack: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
    }
    
    func chancePlayed() {
        
    }
    
    func wordPlayed() {
        
    }
    
    func wildCardUsed() {
        
    }
    
    func gameOver() {
        
    }
}
