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
