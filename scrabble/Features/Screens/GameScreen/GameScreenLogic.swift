import Foundation

protocol GameScreenViewProtocol: FeatureViewProtocol {
    func onTapScreen(_ target: Any?, _ handler: Selector)
    func onTapTimerButton(_ target: Any?, _ handler: Selector)
    func updateTimer(to time: String)
    func setUserInteractionEnabled(to isUserInteractionEnabled: Bool)
    func reduceOneTry()
    func resetTries()
    func updateTabs(isPlayerTurn: Bool, score: Int, cards: Int)
    func showSuccess(with word: String, showSuccessCallback: (() -> Void)?)
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
    
    // Game's state variables
    var playerScore = 15
    var enemyScore = 5
    var currentTries = 0
    var currentStars = 3
    
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
            self.endGameScreenLogic?.showWithParameters(playerScore: self.playerScore, enemyScore: self.enemyScore)
            self.resetVariables()
        }
    }
    
    @objc
    func onScreenTap() {
        log.verbose("Screen tapped")
        cameraLogic?.captureImage({ (image) in
            self.objectRecognizerLogic?.getLabel(for: image, labelCallBack: { (imageLabels) in
                // ASSUMPTION: starting letter would not be capital
                let label = labelSelector.getCorrectLabel(from: imageLabels, startFrom: "b")
                log.debug(label)
            })
        })	
    }
    
    @objc
    func onTimerTap() {
        log.verbose("Timer Tapped")
        self.view?.setUserInteractionEnabled(to: false)
        self.timerScreenLogic?.setPlayerCards(to: currentStars)
        self.timerScreenLogic?.setScore(to: String(playerScore))
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
        // Temp lines to check functions
        if secondsLeftOnTimer == 25 {
            self.view?.showSuccess(with: "THIS", showSuccessCallback: {
                
            })
        }
//        if secondsLeftOnTimer == 2 {
//            self.view?.resetTries()
//            
//        }
//        if secondsLeftOnTimer == 28 {
//            self.endGame()
//        }
        // Temp functions end
        let time = getTimeInString(from: secondsLeftOnTimer)
        self.view?.updateTimer(to: time)
        self.timerScreenLogic?.setTimer(to: time)
        if secondsLeftOnTimer <= 0 {
            timer.invalidate()
        }
    }
    
    func resetVariables() {
        currentStars = 0
        currentTries = 0
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
            self.view?.updateTabs(isPlayerTurn: true, score: self.playerScore, cards: 3)
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
