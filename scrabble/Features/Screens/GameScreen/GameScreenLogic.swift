import Foundation
import SwiftyJSON

protocol GameScreenViewProtocol: FeatureViewProtocol {
    func onTapScreen(_ target: Any?, _ handler: Selector)
    func onTapTimerButton(_ target: Any?, _ handler: Selector)
    func updateTimer(to seconds: Int)
    func setUserInteractionEnabled(to isUserInteractionEnabled: Bool)
    func reduceOneTry()
    func resetTries()
    func reduceOneWildCard(isPlayerTurn: Bool, from currentWildCardCount: Int)
    func showLoadingWordAnimation()
    func hideLoadingWordAnimation()
    func startWildCardMode(_ callback: (() -> Void)?)
    func stopWildCardMode(_ callback: (() -> Void)?)
    func updateTabs(isPlayerTurn: Bool, playerScore: Int, playerWildCards: Int, enemyScore: Int, enemyWildCards: Int)
    func setNames(playerName: String, enemyName: String) 
    func showSuccess(with word: String, isTurn: Bool, score: Int, cardPosition: Int?, showSuccessCallback: (() -> Void)?)
}

protocol GameScreenLogicProtocol: FeatureLogicProtocol {
    func show()
    func hide() 
    func endGame()
    func didGameOverRequestHandler()
    func playChanceEventHandler()
    func useWildCardEventHandler()
    func didGameOverEventHandler()
    func playWordEventHandler(word: String, wildCardPosition: Int)
}

class GameScreenLogic: GameScreenLogicProtocol {
    private weak var view: GameScreenViewProtocol?
    private weak var apiLogic: ApiLogicProtocol?
    private weak var homeScreenLogic: HomeScreenLogicProtocol?
    private weak var cameraLogic: CameraLogicProtocol?
    private weak var timerScreenLogic: TimerScreenLogicProtocol?
    private weak var endGameScreenLogic: EndGameScreenLogicProtocol?
    private weak var objectRecognizerLogic: ObjectRecognizerLogicProtocol?
    
    var isProcessingTap = false
    
    var timer = Timer()
    let timerLengthInSeconds = 30
    var secondsLeftOnTimer = 0
    
    // MARK: - FeatureProtocol conformance
    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
        guard let uiView = view as? GameScreenViewProtocol else {
            log.error("Unknown view type")
            return
        }
        guard let deps = dependencies,
            let apiLogic = deps[.Api] as? ApiLogicProtocol,
            let homeScreenLogic = deps[.HomeScreen] as? HomeScreenLogicProtocol,
            let endGameScreenLogic = deps[.EndGameScreen] as? EndGameScreenLogicProtocol,
            let cameraLogic = deps[.Camera] as? CameraLogicProtocol,
            let timerScreenLogic = deps[.TimerScreen] as? TimerScreenLogicProtocol,
            let objectRecognizerLogic = deps[.ObjectRecognizer] as? ObjectRecognizerLogicProtocol else {
                log.error("Dependency unfulfilled")
                return
        }
        self.apiLogic = apiLogic
        self.homeScreenLogic = homeScreenLogic
        self.endGameScreenLogic = endGameScreenLogic
        self.timerScreenLogic = timerScreenLogic
        self.cameraLogic = cameraLogic
        self.objectRecognizerLogic = objectRecognizerLogic
        
        self.view = uiView
        self.view?.onTapScreen(self, #selector(onScreenTap))
        self.view?.onTapTimerButton(self, #selector(onTimerTap))
    }
    
    @objc
    func endGame() {
        log.verbose("Going to end game screen")
        DispatchQueue.main.async {
            self.view?.hide {
                self.cameraLogic?.hide()
                self.endGameScreenLogic?.showWithParameters(playerScore: gameState.player.score, enemyScore: gameState.enemy.score)
                self.resetVariables()
            }
        }
    }
    
    @objc
    func onScreenTap() {
        log.verbose("Screen tapped")
        guard canPlay() else {
            log.warning("Can't play right now!")
            return
        }
        playTurn()
    }
    
    func playTurn() {
        isProcessingTap = true
        self.view?.showLoadingWordAnimation()
        cameraLogic?.captureImage({ (image) in
            self.objectRecognizerLogic?.getLabel(for: image, labelCallBack: { (imageLabels) in
                if let label = labelSelector.getCorrectLabel(from: imageLabels, startFrom: gameState.currentLetter){
                    self.playWith(word: label)
                } else {
                    log.warning("Word for image not found")
                    if gameState.currentLetter != "*" {
                        self.playChanceRequestHandler()
                    }
                }
            })
        })
    }
    
    func playWith(word: String) {
        if isPlayedWordCorrect(word: word) {
            playWordRequestHandler(with: word)
        } else {
            playChanceRequestHandler()
        }
    }
    
    func canUseWildCard() -> Bool {
        return gameState.player.wildCards > 0
    }
    
    func canPlay() -> Bool{
        return !self.isProcessingTap && gameState.isTurn &&  gameState.player.chances > 0
    }
    
    func calculateScore(from word: String) -> Int{
        if gameState.currentLetter == "*" {
            return 0
        }
        return word.count
    }
    
    func isPlayedWordCorrect(word: String) -> Bool {
        if gameState.currentLetter == "*" {
            //  Word is always correct in case of wild card
            return true
        }
        if let startingLetter = word.first, startingLetter == gameState.currentLetter {
            return true
        }
        return false
    }
    
    func getWildCardPosition(for word: String) -> Int {
        return 1
    }
    
    @objc
    func onTimerTap() {
        log.verbose("Timer Tapped")
        self.view?.setUserInteractionEnabled(to: false)
        self.timerScreenLogic?.setPlayerCards(to: gameState.player.wildCards)
        self.timerScreenLogic?.setScore(to: String(gameState.player.score))
        self.timerScreenLogic?.show()
    }
    
    
    @objc
    func startTimer() {
        if timer.isValid { return }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        secondsLeftOnTimer = timerLengthInSeconds
    }
    
    @objc
    func updateTimer() {
        secondsLeftOnTimer -= 1
        self.view?.updateTimer(to: secondsLeftOnTimer)
        self.timerScreenLogic?.setTimer(to: secondsLeftOnTimer)
        if secondsLeftOnTimer <= 0 {
            if gameState.isTurn {
                if canUseWildCard() {
                    useWildCardRequestHandler()
                } else {
                    didGameOverRequestHandler()
                }
            }
            timer.invalidate()
        }
    }
    
    func resetVariables() {
        secondsLeftOnTimer = 0
        timer.invalidate()
    }
    
    func show() {
        log.verbose("Started Game")
        self.view?.setNames(playerName: gameState.player.name, enemyName: gameState.enemy.name)
        self.view?.show{
            self.cameraLogic?.show()
            self.startTimer()
            self.updateViewTabs()
        }
    }
    
    func hide() {
        log.verbose("Hiding game screen")
        self.view?.hide {
            self.cameraLogic?.hide()
        }
    }
    
    func startTurn() {
        self.updateViewTabs()
        self.view?.resetTries()
        self.startTimer()
    }
    
    func updateViewTabs() {
        self.view?.updateTabs(isPlayerTurn: gameState.isTurn,
                              playerScore: gameState.player.score,
                              playerWildCards: gameState.player.wildCards,
                              enemyScore: gameState.enemy.score,
                              enemyWildCards: gameState.enemy.wildCards)
    }
}

extension GameScreenLogic {
    func playChanceEventHandler() {
        if gameState.isTurn && gameState.player.chances == 0 {
            if canUseWildCard() {
                useWildCardRequestHandler()
            } else {
                didGameOverRequestHandler()
            }
        }
        self.view?.hideLoadingWordAnimation()
        self.view?.reduceOneTry()
    }
    
    func playChanceRequestHandler() {
        apiLogic?.didPlayChance(chances: gameState.player.chances - 1, onCompleteCallBack: { (data, response, error) in
            guard let data = data, error == nil else {
                log.error("Couldnt send the request to play chance, \(String(describing: error))")
                return
            }
            do {
                let json = try JSON(data: data)
                log.debug(json)
            } catch {
                let error = String(data: data, encoding: .utf8)
                log.error("Bad request to play chance, \(String(describing: error))")
            }
        })
    }
    
    func useWildCardRequestHandler() {
        apiLogic?.didUseWildCard(wildCards: gameState.player.wildCards - 1, onCompleteCallBack: { (data, response, error) in
            guard let data = data, error == nil else {
                log.error("Couldnt send the request to use wild card, \(String(describing: error))")
                return
            }
            do {
                let json = try JSON(data: data)
                log.debug(json)
            } catch {
                let error = String(data: data, encoding: .utf8)
                log.error("Bad request to use wild card, \(String(describing: error))")
            }
        })
    }
    
    func useWildCardEventHandler() {
        self.timerScreenLogic?.hide()
        self.updateViewTabs()
        self.view?.startWildCardMode {
            self.isProcessingTap = false
        }
    }
    
    func didGameOverRequestHandler() {
        self.endGame()
        apiLogic?.didGameOver(onCompleteCallBack: { (data, response, error) in
            guard let data = data, error == nil else {
                log.error("Couldnt send the request to end game, \(String(describing: error))")
                return
            }
            do {
                let json = try JSON(data: data)
                log.debug(json)
            } catch {
                let error = String(data: data, encoding: .utf8)
                log.error("Bad request to end game, \(String(describing: error))")
            }
        })
    }
    
    func didGameOverEventHandler() {
        self.endGame()
    }
    
    func playWordEventHandler(word: String, wildCardPosition: Int) {
        let cardPosition = wildCardPosition != -1 ? wildCardPosition : nil
        let score = gameState.isTurn ? gameState.player.score : gameState.enemy.score
        self.view?.hideLoadingWordAnimation()
        self.view?.showSuccess(with: word, isTurn: gameState.isTurn, score: score, cardPosition: cardPosition, showSuccessCallback: {
            self.isProcessingTap = false
            self.startTurn()
        })
    }
    
    func playWordRequestHandler(with word: String) {
        let wildCardPosition = getWildCardPosition(for: word)
        let isWildCard = wildCardPosition != -1
        let wildCards = isWildCard ? gameState.player.wildCards + 1 : gameState.player.wildCards
        apiLogic?.didPlayWord(score: gameState.player.score + calculateScore(from: word),
                              word: word,
                              wildCards: wildCards,
                              wildCardPosition: wildCardPosition,
                              onCompleteCallBack: { (data, response, error) in
                                guard let data = data, error == nil else {
                                    log.error("Couldnt send the request to play word, \(String(describing: error))")
                                    return
                                }
                                do {
                                    let json = try JSON(data: data)
                                    log.debug(json)
                                } catch {
                                    let error = String(data: data, encoding: .utf8)
                                    log.error("Bad request to play word, \(String(describing: error))")
                                }
        })
    }
}

func getTimeInString(from seconds: Int) -> String {
    // This assumes time is less than 60 seconds, please change if necessary
    if (seconds > 9 ) {
        return  "00:\(String(seconds))"
    } else {
        return "00:0\(String(seconds))"
    }
}

