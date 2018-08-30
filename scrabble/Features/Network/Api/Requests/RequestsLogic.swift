import Foundation
import SwiftyJSON

protocol RequestsLogicProtocol: FeatureLogicProtocol {
    func didStartGame(deviceID: String, playerName: String, onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
    func didJoinGame(deviceID: String, playerName: String, gameKey: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
    func didPlayChance(deviceID: String, gameID: String, chances: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
    func didPlayWord(deviceID: String, gameID: String, score: Int, word: String, wildCards: Int, wildCardPosition: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
    func didUseWildCard(deviceID: String, gameID: String, wildCards: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
    func didGameOver(deviceID: String, gameID: String, onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
    func getGameState(deviceID: String, gameID: String, onCompleteCallBack: ((Data?, URLResponse?, Error?)->Void)?)
}

class RequestsLogic: RequestsLogicProtocol {
    
    private let urlSession = URLSession.shared
    private let apiURL = URL(string: "https://littleletters.byondreal.net/api")!
    
    func initialize(root: RootProtocol, view: FeatureViewProtocol?, dependencies: [FeatureName : FeatureLogicProtocol]?) {
    }
    
    func didStartGame(deviceID: String, playerName: String, onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
        let json: JSON = [
                "deviceId": deviceID,
                "playerName": playerName,
                "token": "a827089yd2y093ys8",
                "eventType": RequestType.startGame.rawValue,
        ]
        
        let jsonObject = JSON(json)
        guard let request = makeRequest(jsonObject: jsonObject) else {
            log.error("Couldn't create a request for start game")
            return
        }
        runRequest(request, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didJoinGame(deviceID: String, playerName: String, gameKey: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
        let json: JSON = [
            "deviceId": deviceID,
            "playerName": playerName,
            "token": "u093j1u09du489032u",
            "gameKey": gameKey,
            "eventType": RequestType.joinGame.rawValue
            ]
        
        let jsonObject = JSON(json)
        guard let request = makeRequest(jsonObject: jsonObject) else {
            log.error("Couldn't create a request for join game")
            return
        }
        runRequest(request, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didPlayChance(deviceID: String, gameID: String, chances: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
        let json: JSON = [
            "deviceId": deviceID,
            "gameId": gameID,
            "chances": chances,
            "eventType": RequestType.playChance.rawValue
        ]
        
        let jsonObject = JSON(json)
        guard let request = makeRequest(jsonObject: jsonObject) else {
            log.error("Couldn't create a request for play chance")
            return
        }
        runRequest(request, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didPlayWord(deviceID: String, gameID: String, score: Int, word: String, wildCards: Int, wildCardPosition: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
        let json: JSON = [
            "deviceId": deviceID,
            "gameId": gameID,
            "score": score,
            "word": word,
            "wildcards": wildCards,
            "wildcardPosition": wildCardPosition,
            "eventType": RequestType.playWord.rawValue
        ]
        
        let jsonObject = JSON(json)
        guard let request = makeRequest(jsonObject: jsonObject) else {
            log.error("Couldn't create a request for play word")
            return
        }
        runRequest(request, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didUseWildCard(deviceID: String, gameID: String, wildCards: Int, onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
        let json: JSON = [
            "deviceId": deviceID,
            "gameId": gameID,
            "wildcards": wildCards,
            "eventType": RequestType.useWildCard.rawValue
        ]
        
        let jsonObject = JSON(json)
        guard let request = makeRequest(jsonObject: jsonObject) else {
            log.error("Couldn't create a request for use wild card")
            return
        }
        runRequest(request, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didGameOver(deviceID: String, gameID: String, onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
        let json: JSON = [
            "deviceId": deviceID,
            "gameId": gameID,
            "eventType": RequestType.gameover.rawValue
        ]

        let jsonObject = JSON(json)
        guard let request = makeRequest(jsonObject: jsonObject) else {
            log.error("Couldn't create a request for use wild card")
            return
        }
        runRequest(request, onCompleteCallBack: onCompleteCallBack)
    }
    
    func getGameState(deviceID: String, gameID: String, onCompleteCallBack: ((Data?, URLResponse?, Error?) -> Void)?) {
        let json: JSON = [
            "deviceId": deviceID,
            "gameId": gameID,
            "eventType": RequestType.getGameState.rawValue
        ]
        
        let jsonObject = JSON(json)
        guard let request = makeRequest(jsonObject: jsonObject) else {
            log.error("Couldn't create a request for getting game state")
            return
        }
        runRequest(request, onCompleteCallBack: onCompleteCallBack)
    }
    
    private func makeRequest(jsonObject: JSON) -> URLRequest? {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
       guard let data = try? jsonObject.rawData() else {
            return nil
        }
        request.httpBody = data
        return request
    }
    
    private func runRequest(_ request: URLRequest, onCompleteCallBack:((Data?, URLResponse?, Error?) -> Void)?) {
        let task: URLSessionDataTask = urlSession.dataTask(with: request) { (data, response, error) in
            onCompleteCallBack?(data, response, error)
        }
        task.resume()
    }
    
}
