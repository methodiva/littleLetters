import Foundation

protocol GameScreenViewProtocol: FeatureViewProtocol {
    func onTapScreen(_ target: Any?, _ handler: Selector)
    func onTapTimerButton(_ target: Any?, _ handler: Selector)
    func updateTimer(to time: String)
    func showSuccess(with word: String, showSuccessCallback: (() -> Void)?)
    func reduceOneTry()
    func resetTries()
    func updateTabs(isPlayerTurn: Bool, score: Int, cards: Int)
    func updateCurrentLetter(to letter: Character)
}

protocol GameScreenLogicProtocol: FeatureLogicProtocol {
    func show()
}

class GameScreenLogic: GameScreenLogicProtocol {
    private weak var view: GameScreenViewProtocol?
    private weak var homeScreenLogic: HomeScreenLogicProtocol?
    private weak var cameraLogic: CameraLogicProtocol?
    private weak var timerScreenLogic: TimerScreenLogicProtocol?
    private weak var endGameScreenLogic: EndGameScreenLogicProtocol?
    private weak var objectRecognizerLogic: ObjectRecognizerLogicProtocol?
    
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
            let homeScreenLogic = deps[.HomeScreen] as? HomeScreenLogicProtocol,
            let endGameScreenLogic = deps[.EndGameScreen] as? EndGameScreenLogicProtocol,
            let cameraLogic = deps[.Camera] as? CameraLogicProtocol,
            let timerScreenLogic = deps[.TimerScreen] as? TimerScreenLogicProtocol,
            let objectRecognizerLogic = deps[.ObjectRecognizer] as? ObjectRecognizerLogicProtocol else {
                log.error("Dependency unfulfilled")
                return
        }
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
        self.view?.hide {
            self.cameraLogic?.hide()
            self.endGameScreenLogic?.showWithParameters(playerScore: playerScore, enemyScore: enemyScore)
            self.resetVariables()
        }
    }
    
    @objc
    func onScreenTap() {
        log.verbose("Screen tapped")
        guard isPlayerTurn else {
            log.warning("Not the players turn, tap wouldn't work")
            return
        }
        cameraLogic?.captureImage({ (image) in
            self.objectRecognizerLogic?.getLabel(for: image, labelCallBack: { (imageLabels) in
                // ASSUMPTION: starting letter would not be capital
                guard let label = labelSelector.getCorrectLabel(from: imageLabels, startFrom: currentLetter) else {
                    log.warning("No word found")
                    return
                }
                log.debug(label)
                self.playTurn(with: label)
            })
        })	
    }
    
    func playTurn(with word: String) {
        DispatchQueue.main.async {
            let isSuccess = self.isWordPlayerCorrect(for: word)
            if isSuccess {
                isPlayerTurn = false
                if !playerInWildCardMode {
                    self.addToPlayerScore(for: word)
                }
                self.view?.showSuccess(with: word, showSuccessCallback: {
                    currentLetter = word.last!
                    self.view?.updateCurrentLetter(to: currentLetter)
                    if playerInWildCardMode {
                        playerInWildCardMode = false
                        self.playerChanceComplete()
                        return
                    }
                    self.playerChanceComplete()
                })
            } else {
                self.manageWrongWordPlayed()
            }
        }
    }
    
    func playerChanceComplete() {
        self.startTimer()
        self.view?.updateTabs(isPlayerTurn: false, score: enemyScore, cards: enemyCards)
    }
    
    func addToPlayerScore(for word: String){
        playerScore = playerScore + word.count
        self.view?.updateTabs(isPlayerTurn: true, score: playerScore, cards: playerCards)
    }
    
    func manageWrongWordPlayed() {
        if canUseTry() {
            useTry()
            return
        }
        if canUseCard() {
            useCard()
            return
        }
        DispatchQueue.main.async {
            self.endGame()
        }
    }
    
    func canUseTry() -> Bool{
        return playerTries > 0
    }
    
    func useTry() {
        self.view?.reduceOneTry()
        playerTries = playerTries - 1
    }
    
    func canUseCard() -> Bool {
        return playerCards > 0
    }
    
    func useCard() {
        playerTries = maxTries
        playerInWildCardMode = true
        playerCards = playerCards - 1
        self.setTimerToWildCardMode()
        self.view?.resetTries()
        self.view?.updateTabs(isPlayerTurn: true, score: playerScore, cards: playerCards)
        self.timerScreenLogic?.setPlayerCards(to: playerCards)
    }
    
    func setTimerToWildCardMode() {
        
    }
    
    func isWordPlayerCorrect(for word: String) -> Bool {
        if word.count < 1  {
            return false
        }
        if playerInWildCardMode {
            //  TODO: Add a check to not let the user repeat the word which have been done before
            return true
        }
        if currentLetter == word.first {
            return true
        } else {
            return false
        }
    }
    
    @objc
    func onTimerTap() {
        log.verbose("Timer Tapped")
        self.timerScreenLogic?.setPlayerCards(to: playerCards)
        self.timerScreenLogic?.setScore(to: String(playerScore))
        self.view?.hide {
            self.cameraLogic?.hide()
            self.timerScreenLogic?.show()
        }
    }
    
    
    @objc
    func startTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        secondsLeftOnTimer = timerLengthInSeconds
    }
    
    @objc
    func updateTimer() {
        secondsLeftOnTimer -= 1
        // Temp Function
        if !isPlayerTurn {
            if secondsLeftOnTimer == 15 {
                playEnemyTurn()
            }
        }
        let time = getTimeInString(from: secondsLeftOnTimer)
        self.view?.updateTimer(to: time)
        self.timerScreenLogic?.setTimer(to: time)
        if secondsLeftOnTimer <= 0 {
            timer.invalidate()
        }
    }
    
    // temp function
    func playEnemyTurn() {
        for word in tempWordsForEnemyToPlay {
            if word.first == currentLetter {
                enemyScore = enemyScore + word.count
                self.view?.updateTabs(isPlayerTurn: false, score: enemyScore, cards: enemyCards)
                self.view?.showSuccess(with: word.uppercased(), showSuccessCallback: {
                    currentLetter = word.uppercased().last!
                    self.view?.updateCurrentLetter(to: currentLetter)
                    isPlayerTurn = true
                    self.startTimer()
                    self.view?.updateTabs(isPlayerTurn: true, score: playerScore, cards: playerCards)
                    self.enemyTurnComplete()
                })
                return
            }
        }
    }
    
    func enemyTurnComplete() {
        
    }
    
    func resetVariables() {
        playerCards = 0
        playerTries = 0
        playerScore = 0
        enemyScore = 0
        secondsLeftOnTimer = 0
        timer.invalidate()
    }
    
    func show() {
        log.verbose("Started Game")
        self.view?.show{
            self.cameraLogic?.show()
            self.startTimer()
            self.view?.updateTabs(isPlayerTurn: true, score: playerScore, cards: 3)
        }
    }
    
    
}

fileprivate func getTimeInString(from seconds: Int) -> String {
    // This assumes time is less than 60 seconds, please change if necessary
    if (seconds > 9 ) {
        return  "00:\(String(seconds))"
    } else {
        return "00:0\(String(seconds))"
    }
}
