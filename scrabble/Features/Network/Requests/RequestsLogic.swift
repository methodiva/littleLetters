import Foundation
import SwiftyJSON

protocol RequestsLogicProtocol: FeatureLogicProtocol {
    func didStartGame(deviceID: String, playerName: String, onCompleteCallBack: ((Data)->Void)?)
    func didJoinGame(deviceID: String, playerName: String, gameKey: String, onCompleteCallBack: ((Data)->Void)?)
    func didPlayChance(deviceID: String, gameID: String, chances: Int, onCompleteCallBack: ((Data)->Void)?)
    func didPlayWord(deviceID: String, gameID: String, score: Int, word: String, wildCards: Int, wildCardPosition: Int, onCompleteCallBack: ((Data)->Void)?)
    func didUseWildCard(deviceID: String, gameID: String, wildCards: Int, onCompleteCallBack: ((Data)->Void)?)
    func didGameGetOver(deviceID: String, gameID: String, score: Int, onCompleteCallBack: ((Data)->Void)?)
    func getGameState(deviceID: String, gameID: String, onCompleteCallBack: ((Data)->Void)?)
}

class RequestsLogic: RequestsLogicProtocol {
    
    private let urlSession = URLSession.shared
    private let apiURL = URL(string: "https://littleletters.byondreal.net/api")!
    
    func initialize(root: RootProtocol, view: FeatureViewProtocol?, dependencies: [FeatureName : FeatureLogicProtocol]?) {
    }
    
    func didStartGame(deviceID: String, playerName: String, onCompleteCallBack: ((Data) -> Void)?) {
        let jsonRequest = [
            "requests": [
                "deviceID": [
                    "content": deviceID
                ],
                "playerName": [
                    "content": playerName
                ],
                "eventType": [
                    "content": RequestType.startGame.rawValue
                ],
            ]
        ]
        
        let jsonObject = JSON(jsonRequest)
        guard let request = makeRequest(jsonObject: jsonObject) else {
            log.error("Couldn't create a request for start game")
            return
        }
        runRequest(request, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didJoinGame(deviceID: String, playerName: String, gameKey: String, onCompleteCallBack: ((Data) -> Void)?) {
        let jsonRequest = [
            "requests": [
                "deviceID": [
                    "content": deviceID
                ],
                "playerName": [
                    "content": playerName
                ],
                "gameKey": [
                    "content": gameKey
                ],
                "eventType": [
                    "content": RequestType.joinGame.rawValue
                ],
            ]
        ]
        
        let jsonObject = JSON(jsonRequest)
        guard let request = makeRequest(jsonObject: jsonObject) else {
            log.error("Couldn't create a request for join game")
            return
        }
        runRequest(request, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didPlayChance(deviceID: String, gameID: String, chances: Int, onCompleteCallBack: ((Data) -> Void)?) {
        let jsonRequest = [
            "requests": [
                "deviceID": [
                    "content": deviceID
                ],
                "gameID": [
                    "content": gameID
                ],
                "chances": [
                    "content": chances
                ],
                "eventType": [
                    "content": RequestType.playChance.rawValue
                ],
            ]
        ]
        
        let jsonObject = JSON(jsonRequest)
        guard let request = makeRequest(jsonObject: jsonObject) else {
            log.error("Couldn't create a request for play chance")
            return
        }
        runRequest(request, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didPlayWord(deviceID: String, gameID: String, score: Int, word: String, wildCards: Int, wildCardPosition: Int, onCompleteCallBack: ((Data) -> Void)?) {
        let jsonRequest = [
            "requests": [
                "deviceID": [
                    "content": deviceID
                ],
                "gameID": [
                    "content": gameID
                ],
                "score": [
                    "content": String(score)
                ],
                "word": [
                    "content": word
                ],
                "wildCards": [
                    "content": String(wildCards)
                ],
                "wildCardPosition": [
                    "content": String(wildCardPosition)
                ],
                "eventType": [
                    "content": RequestType.playWord.rawValue
                ],
            ]
        ]
        
        let jsonObject = JSON(jsonRequest)
        guard let request = makeRequest(jsonObject: jsonObject) else {
            log.error("Couldn't create a request for play word")
            return
        }
        runRequest(request, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didUseWildCard(deviceID: String, gameID: String, wildCards: Int, onCompleteCallBack: ((Data) -> Void)?) {
        let jsonRequest = [
            "requests": [
                "deviceID": [
                    "content": deviceID
                ],
                "gameID": [
                    "content": gameID
                ],
                "wildCards": [
                    "content": String(wildCards)
                ],
                "eventType": [
                    "content": RequestType.useWildCard.rawValue
                ],
            ]
        ]
        
        let jsonObject = JSON(jsonRequest)
        guard let request = makeRequest(jsonObject: jsonObject) else {
            log.error("Couldn't create a request for use wild card")
            return
        }
        runRequest(request, onCompleteCallBack: onCompleteCallBack)
    }
    
    func didGameGetOver(deviceID: String, gameID: String, score: Int, onCompleteCallBack: ((Data) -> Void)?) {
        let jsonRequest = [
            "requests": [
                "deviceID": [
                    "content": deviceID
                ],
                "gameID": [
                    "content": gameID
                ],
                "score": [
                    "content": String(score)
                ],
                "eventType": [
                    "content": RequestType.gameover.rawValue
                ],
            ]
        ]
        
        let jsonObject = JSON(jsonRequest)
        guard let request = makeRequest(jsonObject: jsonObject) else {
            log.error("Couldn't create a request for use game over")
            return
        }
        runRequest(request, onCompleteCallBack: onCompleteCallBack)
    }
    
    func getGameState(deviceID: String, gameID: String, onCompleteCallBack: ((Data) -> Void)?) {
        let jsonRequest = [
            "requests": [
                "deviceID": [
                    "content": deviceID
                ],
                "gameID": [
                    "content": gameID
                ],
                "eventType": [
                    "content": RequestType.getGameState.rawValue
                ],
            ]
        ]
        
        let jsonObject = JSON(jsonRequest)
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
    
    private func runRequest(_ request: URLRequest, onCompleteCallBack:((Data) -> Void)?) {
        let task: URLSessionDataTask = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                log.error(error?.localizedDescription ?? "")
                return
            }
            onCompleteCallBack?(data)
        }
        task.resume()
    }
    
}
