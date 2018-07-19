import UIKit

class GameScreenView: UIView, GameScreenViewProtocol {
    weak var featureLogic: GameScreenLogicProtocol!
    
    convenience init(_ featureLogic: FeatureLogicProtocol) {
        self.init(frame: UIScreen.main.bounds)
        guard let logic = featureLogic as? GameScreenLogicProtocol else {
            log.error("Invalid featureLogic provided")
            return
        }
        self.featureLogic = logic
        self.isUserInteractionEnabled = false
        initUI()
        initConstraints()
    }
    
    
    let screenTitleLabel = UILabel()
    let backButton = BackButton()
    let endGameButton = UIButton()
    
    let playerScoreButton = UIButton()
    let enemyScoreButton = UIButton()
    let currentStarsButton = UIButton()
    let timerButton = UIButton()
    let currentTriesButton = UIButton()
    
    let crossHairLabel = UILabel()
    
    func initUI() {
        screenTitleLabel.text = "Game Screen"
        screenTitleLabel.textAlignment = .center
        endGameButton.backgroundColor = .green
        endGameButton.setTitle("End Game", for: .normal)
        
        playerScoreButton.setTitle("Player Score: 0", for: .normal)
        enemyScoreButton.setTitle("Enemy Score: 0", for: .normal)
        currentStarsButton.setTitle("Current Stars: 0", for: .normal)
        timerButton.setTitle("Current Time: 30", for: .normal)
        currentTriesButton.setTitle("Current Tries: 0", for: .normal)
        crossHairLabel.text = "+"
        
        self.addSubview(playerScoreButton)
        self.addSubview(enemyScoreButton)
        self.addSubview(currentStarsButton)
        self.addSubview(timerButton)
        self.addSubview(currentTriesButton)
        self.addSubview(crossHairLabel)
        
        self.addSubview(backButton)
        self.addSubview(screenTitleLabel)
        self.addSubview(endGameButton)
        self.hide{}
    }
    
    func initConstraints() {
        playerScoreButton.snp.makeConstraints { make in
            make.topMargin.equalTo(420)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        enemyScoreButton.snp.makeConstraints { make in
            make.topMargin.equalTo(100)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        currentStarsButton.snp.makeConstraints { make in
            make.topMargin.equalTo(180)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        timerButton.snp.makeConstraints { make in
            make.topMargin.equalTo(260)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        currentTriesButton.snp.makeConstraints { make in
            make.topMargin.equalTo(340)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        crossHairLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        screenTitleLabel.snp.makeConstraints { make in
            make.topMargin.equalTo(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        backButton.snp.makeConstraints { make in
            make.topMargin.equalTo(30)
            make.leftMargin.equalTo(30)
        }
        endGameButton.snp.makeConstraints { make in
            make.topMargin.equalTo(580)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
    }
    
    func updatePlayerScore(to newScore: Int) {
        log.verbose("Updated player score to \(String(newScore))")
        playerScoreButton.setTitle("Player Score: \(String(newScore))", for: .normal)
    }
    
    func updateEnemyScore(to newScore: Int) {
        
        log.verbose("Updated enemy score to \(String(newScore))")
        enemyScoreButton.setTitle("Enemy Score: \(String(newScore))", for: .normal)
    }
    
    func updateCurrentStars(to stars: Int) {
        log.verbose("Updated current stars to \(String(stars))")
        currentStarsButton.setTitle("Current Stars: \(String(stars))", for: .normal)
    }
    
    func updateCurrentTries(to tries: Int) {
        log.verbose("Updated current tries to \(String(tries))")
        currentTriesButton.setTitle("Current Tries: \(String(tries))", for: .normal)
    }
    
    func updateTimer(to time: Int) {
//        log.verbose("Updated timer to \(String(time))")
        timerButton.setTitle("Current Time: \(String(time))", for: .normal)
    }
    
    func onTapBackButton(_ target: Any?, _ handler: Selector) {
        self.backButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    func onTapGameOverButton(_ target: Any?, _ handler: Selector) {
        self.endGameButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    // Temporary functions to test the functionality
    
    func onTapPlayerScoreButton(_ target: Any?, _ handler: Selector) {
        self.playerScoreButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    func onTapEnemyScoreButton(_ target: Any?, _ handler: Selector) {
        self.enemyScoreButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    func onTapCurrentTriesButton(_ target: Any?, _ handler: Selector) {
        self.currentTriesButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    func onTapCurrentStarsButton(_ target: Any?, _ handler: Selector) {
        self.currentStarsButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    func onTapTimerButton(_ target: Any?, _ handler: Selector) {
        self.timerButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    func hide(_ onHidden: (() -> Void)?) {
        self.isUserInteractionEnabled = false
        self.alpha = 0
        onHidden?()
    }
    
    func show(_ onShowing: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.alpha = 1
    }
}
