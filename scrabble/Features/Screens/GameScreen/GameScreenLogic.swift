import Foundation

protocol GameScreenViewProtocol: FeatureViewProtocol {
    func onTapBackButton(_ target: Any?, _ handler: Selector)
    func onTapGameOverButton(_ target: Any?, _ handler: Selector)
    func onTapScreen(_ target: Any?, _ handler: Selector)
    func updatePlayerScore(to newScore: Int)
    func updateEnemyScore(to newScore: Int)
    func updateCurrentStars(to stars: Int)
    func updateCurrentTries(to tries: Int)
    func updateTimer(to time: Int)
    
    // Temporary functions to test
    
    func onTapPlayerScoreButton(_ target: Any?, _ handler: Selector)
    func onTapEnemyScoreButton(_ target: Any?, _ handler: Selector)
    func onTapCurrentTriesButton(_ target: Any?, _ handler: Selector)
    func onTapCurrentStarsButton(_ target: Any?, _ handler: Selector)
    func onTapTimerButton(_ target: Any?, _ handler: Selector)
}

protocol GameScreenLogicProtocol: FeatureLogicProtocol {
    func show()
}

class GameScreenLogic: GameScreenLogicProtocol {
    private weak var view: GameScreenViewProtocol?
    private weak var homeScreenLogic: HomeScreenLogicProtocol?
    private weak var cameraLogic: CameraLogicProtocol?
    private weak var endGameScreenLogic: EndGameScreenLogicProtocol?
    private weak var objectRecognizerLogic: ObjectRecognizerLogicProtocol?
    
    // Game's state variables
    var playerScore = 0
    var enemyScore = 0
    var currentTries = 0
    var currentStars = 0
    
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
            let objectRecognizerLogic = deps[.ObjectRecognizer] as? ObjectRecognizerLogicProtocol else {
                log.error("Dependency unfulfilled")
                return
        }
        self.homeScreenLogic = homeScreenLogic
        self.endGameScreenLogic = endGameScreenLogic
        self.cameraLogic = cameraLogic
        self.objectRecognizerLogic = objectRecognizerLogic
        
        self.view = uiView
        self.view?.onTapBackButton(self, #selector(goBack))
        self.view?.onTapGameOverButton(self, #selector(endGame))
        self.view?.onTapScreen(self, #selector(onScreenTap))
        
        // Temp functions
        self.view?.onTapPlayerScoreButton(self, #selector(increasePlayerScore))
        self.view?.onTapEnemyScoreButton(self, #selector(increaseEnemyScore))
        self.view?.onTapCurrentStarsButton(self, #selector(increaseCurrentStars))
        self.view?.onTapCurrentTriesButton(self, #selector(increaseCurrentTries))
        self.view?.onTapTimerButton(self, #selector(startTimer))
    }
     
    @objc
    func goBack() {
        log.verbose("Going back to home screen")
        self.view?.hide {
            self.cameraLogic?.hide()
            self.homeScreenLogic?.show()
            self.resetVariables()
        }
    }
    
    @objc
    func endGame() {
        log.verbose("Going to end game screen")
        self.view?.hide {
            self.cameraLogic?.hide()
            self.endGameScreenLogic?.show()
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
    
    // Temporary functions to test
    
    @objc
    func increasePlayerScore() {
        playerScore += 1
        self.view?.updatePlayerScore(to: playerScore)
    }
    
    @objc
    func increaseEnemyScore() {
        enemyScore += 1
        self.view?.updateEnemyScore(to: enemyScore)
    }
    
    @objc
    func increaseCurrentTries() {
        currentTries += 1
        self.view?.updateCurrentTries(to: currentTries)
    }
    
    @objc
    func increaseCurrentStars() {
        currentStars += 1
        self.view?.updateCurrentStars(to: currentStars)
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
        }
    }
    
    
}
