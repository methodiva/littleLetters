import Foundation

struct GameParameters {
    static let timePerTurnInSeconds = 30
    static let maxTriesPerTurn = 3
    static let pointsPerLetter = 2
    static let minWordLengthForStar = 5
}

protocol GameScreenViewProtocol: FeatureViewProtocol {
    func onTapBackButton(_ target: Any?, _ handler: Selector)
    func onTapGameOverButton(_ target: Any?, _ handler: Selector)
    func onTapScreen(_ target: Any?, _ handler: Selector)
    func updatePlayerPoints(to newScore: Int)
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
    var isPlayerTurn = false
    var playerPoints = 0
    var enemyScore = 0
    var currentTries = 0
    var currentStars = 0
    var currentTimerValue = 0
    var currentLetter: Character = "a" {
        didSet {
            // Add the logic to make the character lower case
        }
    }
    
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
        self.view?.onTapTimerButton(self, #selector(startTimerTemp))
    }
    
    func resetVariables() {
        currentStars = 0
        currentTries = 0
        playerPoints = 0
        enemyScore = 0
        secondsLeftOnTimer = 0
        timer.invalidate()
    }
    
    func show() {
        log.verbose("Started Game")
        self.view?.show{
        }
    }
}

// Game Play Logic
extension GameScreenLogic {
    
    func startGame(isHost: Bool) {
        if isHost {
            currentLetter = getRandomLetter()
        }
        isPlayerTurn = isHost
        if isPlayerTurn {
            startPlayerTurn(with: currentLetter)
        } else {
            startEnemyTurn()
        }
    }
    
    // The two functions are kept seperate for now, since UI might be differnt in both cases,
    // and different functions might be needed
    func startPlayerTurn(with letter: Character) {
        currentLetter =  letter
        startTimer(of: GameParameters.timePerTurnInSeconds)
    }
    
    func startEnemyTurn() {
        startTimer(of: GameParameters.timePerTurnInSeconds)
    }
    
    func timerUp() {
        if isPlayerTurn {
            // Show use start menu?
        }
    }
    
    
    @objc
    func onScreenTap() {
        log.verbose("Screen tapped")
        guard playerCanPlay() else {
            log.warning("Invalid tap, player can't play right now")
            return
        }
        playTurn()
    }
    
    func playTurn() {
        getLabelForCurrentCameraImage { (word) in
            guard let label = word else  {
                log.warning("Coudn't find any label for the image")
                return
            }
            self.playWord(label)
        }
    }
    
    func playWord(_ label: String) {
        if isWordValid(label) {
            playedCorrect(word: label)
            startEnemyTurn()
            isPlayerTurn = false
        } else {
            playedWrong(word: label)
        }
        nPlayerPlayedWord()
    }
    
    func playedCorrect(word label: String) {
        updatePlayerPoints(to: playerPoints + calculatePoints(for: label))
        updateStar(to: currentStars + calculateStars(for: label))
    }
    
    func playedWrong(word label: String) {
        if currentTries > 0 {
            updateTries(to: currentTries - 1)
        } else {
            useStar()
        }
    }
}

// Helper functions
extension GameScreenLogic {
    func getRandomLetter() -> Character {
        return "a"
    }
    
    func startTimer(of length: Int) {
        
    }
    
    func useStar() {
        if currentStars > 0 {
            log.verbose("Player used a star")
            updateStar(to: currentStars - 1)
            updateTries(to: GameParameters.maxTriesPerTurn)
            startTimer(of: GameParameters.timePerTurnInSeconds)
        } else {
            log.verbose("Player had no star to use, game ending")
            endGame()
        }
    }
    
    func playerCanPlay() -> Bool {
        return isPlayerTurn && currentTries > 0 && currentTimerValue > 0
    }
    
    func getLabelForCurrentCameraImage(wordCallback: ((String?) -> Void)?) {
        cameraLogic?.captureImage({ (image) in
            self.objectRecognizerLogic?.getLabel(for: image, labelCallBack: { (imageLabels) in
                // ASSUMPTION: starting letter would not be capital
                let label = labelChooser.getCorrectLabel(from: imageLabels, startFrom: "b")
                wordCallback?(label)
            })
        })
    }
    
    func isWordValid(_ label: String) -> Bool{
        // TODO: Add logic to check if the word hasn't been played before
        if label.first == currentLetter {
            return true
        } else {
            return false
        }
    }
    
    func calculatePoints(for word: String) -> Int {
        // TODO: Add the correct logic here for calculating points.
        return word.count * GameParameters.pointsPerLetter
    }
    
    func calculateStars(for word: String) -> Int {
        // TODO: Add the correct logic here for calculating stars.
        if word.count > GameParameters.minWordLengthForStar {
            return 1
        }
        return 0
    }
}

// Update Variables
extension GameScreenLogic {
    func updateStar(to newStars: Int) {
        currentStars = newStars
        nPlayerStarUpdated()
        self.view?.updateCurrentStars(to: newStars)
    }
    func updateTries(to newTries: Int) {
        currentTries = newTries
        nPlayerTriesUpdated()
        self.view?.updateCurrentTries(to: newTries)
    }
    func updatePlayerPoints(to newPoints: Int) {
        playerPoints = newPoints
        nPlayerPointsUpdated()
        self.view?.updatePlayerPoints(to: playerPoints)
    }
}

// Network functions, some of them might not be network functions
extension GameScreenLogic {
    // Very temp, just writing to know what all cases to handle
    func nEnemyDidUseStar() {}
    func nEnemyDidUseTry() {}
    func nEnemyDidPlayWord() {}
    func nEmemyPointsUpdated() {}
    
    func nPlayerStarUpdated() {}
    func nPlayerTriesUpdated() {}
    func nPlayerPlayedWord() {}
    func nPlayerPointsUpdated() {}
}


// View Button action functions
extension GameScreenLogic {
    @objc
    func goBack() {
        log.verbose("Going back to home screen")
        self.view?.hide {
            self.homeScreenLogic?.show()
            self.resetVariables()
        }
    }
    
    @objc
    func endGame() {
        log.verbose("Going to end game screen")
        self.view?.hide {
            self.endGameScreenLogic?.show()
            self.resetVariables()
        }
    }
    
    
    
    // Temporary functions to test
    
    @objc
    func increasePlayerScore() {
        playerPoints += 1
        self.view?.updatePlayerPoints(to: playerPoints)
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
    
    // Rename the function after deleting the temp ui code
    @objc
    func startTimerTemp() {
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
}
