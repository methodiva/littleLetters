import Foundation
import SwiftyJSON

protocol GameScreenViewProtocol: FeatureViewProtocol {
    func onTapScreen(_ target: Any?, _ handler: Selector)
    func onTapTimerButton(_ target: Any?, _ handler: Selector)
    func updateTimer(to seconds: Int)
    func setUserInteractionEnabled(to isUserInteractionEnabled: Bool)
    func reduceOneTry(to leftTries: Int)
    func resetTries()
    func reduceOneWildCard(isPlayerTurn: Bool, from currentWildCardCount: Int, onCompelteCallback: (() -> Void)?)
    func showLoadingWordAnimation()
    func hideLoadingWordAnimation()
    func setScanLabelTo(isHidden: Bool)
    func hideStatusBarBlurred()
    func updateTabs(isPlayerTurn: Bool, playerScore: Int, playerWildCards: Int, enemyScore: Int, enemyWildCards: Int)
    func setNames(playerName: String, enemyName: String)
    func resetGameUI()
    func showSuccess(with word: String, isTurn: Bool, score: Int, cardPosition: Int?, isWildCardModeOn: Bool, showSuccessCallback: (() -> Void)?)
}

protocol GameScreenLogicProtocol: FeatureLogicProtocol {
    func show()
    func startTurn()
    func hide() 
    func endGame()
    func hideStatusBarBlurred()
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
    
    var isWildCardModeOn = false
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
                self.view?.resetGameUI() 
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
        self.stopTimer()
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
        return !self.isProcessingTap && gameState.isTurn &&  ( gameState.player.chances > 0 || gameState.currentLetter == "*" )
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
        secondsLeftOnTimer = timerLengthInSeconds
        resumeTimer()
    }
    
    func resumeTimer() {
        if timer.isValid { return }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        updateTimer()
    }
    
    func stopTimer() {
        timer.invalidate()
        self.view?.updateTimer(to: secondsLeftOnTimer)
        self.timerScreenLogic?.setTimer(to: secondsLeftOnTimer)
    }
    
    @objc
    func updateTimer() {
        secondsLeftOnTimer -= 1
        DispatchQueue.main.async {
            self.view?.updateTimer(to: self.secondsLeftOnTimer)
            self.timerScreenLogic?.setTimer(to: self.secondsLeftOnTimer)
        }
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
        isWildCardModeOn = false
        isProcessingTap = false
    }
    
    func show() {
        log.verbose("Started Game")
        self.view?.setNames(playerName: gameState.player.name, enemyName: gameState.enemy.name)
        self.view?.show{
            self.cameraLogic?.show()
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
        self.startTimer()
        self.view?.resetTries()
    }
    
    func updateViewTabs() {
        self.view?.updateTabs(isPlayerTurn: gameState.isTurn,
                              playerScore: gameState.player.score,
                              playerWildCards: gameState.player.wildCards,
                              enemyScore: gameState.enemy.score,
                              enemyWildCards: gameState.enemy.wildCards)
    }
    
    func hideStatusBarBlurred() {
         self.view?.hideStatusBarBlurred()
    }
}

extension GameScreenLogic {
    func playChanceEventHandler() {
        log.verbose("Recieved play chance event")
        self.isProcessingTap = false
        if gameState.isTurn && gameState.player.chances == 0 {
            if canUseWildCard() {
                useWildCardRequestHandler()
            } else {
                didGameOverRequestHandler()
            }
        } else {
            self.resumeTimer()
        }
        self.view?.hideLoadingWordAnimation()
        let chancesLeft = gameState.isTurn ? gameState.player.chances : gameState.enemy.chances
        self.view?.reduceOneTry(to: chancesLeft)
    }
    
    func playChanceRequestHandler() {
        log.verbose("Sent request for play chance event")
        apiLogic?.didPlayChance(chances: gameState.player.chances - 1, onCompleteCallBack: { (data, response, error) in
            guard let data = data, error == nil else {
                log.error("Couldnt send the request to play chance, \(String(describing: error))")
                return
            }
            do {
                let _ = try JSON(data: data)
            } catch {
                let error = String(data: data, encoding: .utf8)
                log.error("Bad request to play chance, \(String(describing: error))")
            }
        })
    }
    
    func useWildCardRequestHandler() {
        log.verbose("Sent request for play wild card event")
        apiLogic?.didUseWildCard(wildCards: gameState.player.wildCards - 1, onCompleteCallBack: { (data, response, error) in
            guard let data = data, error == nil else {
                log.error("Couldnt send the request to use wild card, \(String(describing: error))")
                return
            }
            do {
                let _ = try JSON(data: data)
            } catch {
                let error = String(data: data, encoding: .utf8)
                log.error("Bad request to use wild card, \(String(describing: error))")
            }
        })
    }
    
    func useWildCardEventHandler() {
        log.verbose("Recieved play wild card event")
        secondsLeftOnTimer = -1
        self.timerScreenLogic?.hide()
        self.stopTimer()
        isWildCardModeOn = true
        self.view?.setScanLabelTo(isHidden: false)
        let currentWildCards = gameState.isTurn ? gameState.player.wildCards : gameState.enemy.wildCards
        self.view?.reduceOneWildCard(isPlayerTurn: gameState.isTurn, from: currentWildCards) {
            self.isProcessingTap = false
        }
    }
    
    func didGameOverRequestHandler() {
        log.verbose("Sent request for game over event")
        self.endGame()
        apiLogic?.didGameOver(onCompleteCallBack: { (data, response, error) in
            guard let data = data, error == nil else {
                log.error("Couldnt send the request to end game, \(String(describing: error))")
                return
            }
            do {
                let _ = try JSON(data: data)
            } catch {
                let error = String(data: data, encoding: .utf8)
                log.error("Bad request to end game, \(String(describing: error))")
            }
        })
    }
    
    func didGameOverEventHandler() {
        log.verbose("Recieved game over event")
        self.endGame()
    }
    
    func playWordEventHandler(word: String, wildCardPosition: Int) {
        log.verbose("Recieved play word event")
        let cardPosition = wildCardPosition != -1 ? wildCardPosition : nil
        let score = gameState.isTurn ? gameState.enemy.score : gameState.player.score
        DispatchQueue.main.async {
            self.resumeTimer()
            self.view?.hideLoadingWordAnimation()
            log.debug(score )
            self.view?.showSuccess(with: word, isTurn: gameState.isTurn, score: score, cardPosition: cardPosition, isWildCardModeOn: self.isWildCardModeOn, showSuccessCallback: {
                self.view?.setScanLabelTo(isHidden: true)
                self.isWildCardModeOn = false
                self.isProcessingTap = false
                self.startTurn()
            })
        }
    }
    
    func playWordRequestHandler(with word: String) {
        log.verbose("Sent request for play word event")
        DispatchQueue.main.async {
            self.stopTimer()
        }
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
                                    let _ = try JSON(data: data)
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

