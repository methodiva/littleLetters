import UIKit

fileprivate let titleFont = UIFont(name: "Coiny", size: 50)
fileprivate let playerNameFont = UIFont(name: "Montserrat-Bold", size: 25)
fileprivate let playerScoreFont = UIFont(name: "Montserrat-Bold", size: 30)
fileprivate let endGameButtonFont = UIFont(name: "Montserrat-Bold", size: 25)

fileprivate let scoreTabImage = UIImage(named: "scoreTabBig")
fileprivate let playerWonTabImage = UIImage(named: "playerWonTabImage")
fileprivate let playerLostTabImage = UIImage(named: "playerLostTabImage")
fileprivate let enemyWonTabImage = UIImage(named: "enemyWonTabImage")
fileprivate let enemyLostTabImage = UIImage(named: "enemyLostTabImage")
fileprivate let endGameButtonImage = UIImage(named: "purpleButton")

let winnerNameMargin = 38
let loserNameMargin = 30
let winnerScoreMargin = 30
let loserScoreMargin = 20
let winnerCenterOffset = 2
let loserCenterOffset = -2


class EndGameScreenView: UIView, EndGameScreenViewProtocol {
    weak var featureLogic: EndGameScreenLogicProtocol!
    
    convenience init(_ featureLogic: FeatureLogicProtocol) {
        self.init(frame: UIScreen.main.bounds)
        guard let logic = featureLogic as? EndGameScreenLogicProtocol else {
            log.error("Invalid featureLogic provided")
            return
        }
        self.featureLogic = logic
        self.isUserInteractionEnabled = false
        initUI()
        initConstraints()
    }
    
    // UI elements
    let backgroundImage = UIImageView(image: UIImage(named: "BackgroundImage"))
    let screenTitleLabel = UILabel()
    
    let tabStack = UIStackView()
    
    let playerTab = UIImageView()
    let playerNameLabel = UILabel()
    let playerScoreTab = UIImageView()
    let playerScoreLabel = UILabel()
    
    let enemyTab = UIImageView()
    let enemyNameLabel = UILabel()
    let enemyScoreTab = UIImageView()
    let enemyScoreLabel = UILabel()
    
    let endGameButton = UIButton()
    
    func initUI() {
        self.addSubview(backgroundImage)
        initTitleLabelUI()
        initTabs()
        initEndGameButton()
        self.isUserInteractionEnabled = false
        self.alpha = 0
    }

    func initTitleLabelUI() {
        screenTitleLabel.text = "Player Wins!"
        screenTitleLabel.font = titleFont
        screenTitleLabel.textColor = appColors.white
        screenTitleLabel.textAlignment = .center
        self.addSubview(screenTitleLabel)
    }
    
    func initTabs() {
        tabStack.axis = .vertical
        tabStack.spacing = gridHeight
        tabStack.alignment = .center
        
        initPlayerTab()
        initEnemyTab()
        
        self.addSubview(tabStack)
    }
    
    func initPlayerTab() {
        playerTab.addSubview(playerNameLabel)
        playerTab.addSubview(playerScoreTab)

        // Initialising the score tab
        playerScoreTab.addSubview(playerScoreLabel)
        playerScoreTab.image = scoreTabImage
        playerScoreLabel.text = String(0)
        playerScoreLabel.font = playerScoreFont
        playerScoreLabel.textColor = appColors.darkPurple
        playerScoreLabel.textAlignment = .center
        
        // Initialising name tab
        playerNameLabel.font = playerNameFont
        playerNameLabel.textColor = appColors.white
        playerNameLabel.text = playerName
        tabStack.addArrangedSubview(playerTab)
    }
    
    func initEnemyTab() {
        enemyTab.addSubview(enemyNameLabel)
        enemyTab.addSubview(enemyScoreTab)
        
        // Initialising the score tab
        enemyScoreTab.addSubview(enemyScoreLabel)
        enemyScoreTab.image = scoreTabImage
        enemyScoreLabel.text = String(0)
        enemyScoreLabel.font = playerScoreFont
        enemyScoreLabel.textColor = appColors.darkPurple
        enemyScoreLabel.textAlignment = .center
        
        // Initialising name tab
        enemyNameLabel.font = playerNameFont
        enemyNameLabel.textColor = appColors.white
        enemyNameLabel.text = enemyName
        tabStack.addArrangedSubview(enemyTab)
    }
    
    func initEndGameButton() {
        endGameButton.setBackgroundImage(endGameButtonImage, for: .normal)
        var attributes = [NSAttributedStringKey: AnyObject]()
        attributes[.foregroundColor] = appColors.white
        
        let endGameTitle = "End Game"
        let endGameAttributedString = NSMutableAttributedString(string: endGameTitle, attributes: attributes)
        endGameAttributedString.addAttribute(kCTKernAttributeName as NSAttributedStringKey,
                                               value: CGFloat(5.0),
                                               range: NSRange(location: 0, length: endGameTitle.count-1))
        endGameButton.setAttributedTitle(endGameAttributedString, for: .normal)
        endGameButton.titleLabel?.font = endGameButtonFont
        self.addSubview(endGameButton)
    }
    
    func initConstraints() {
        backgroundImage.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        screenTitleLabel.snp.makeConstraints { make in
            make.topMargin.equalTo(gridHeight * 2)
            make.centerX.equalToSuperview()
        }
        tabStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(screenTitleLabel.snp.bottom).offset(gridHeight * 2)
        }
        endGameButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(gridHeight * 3)
        }
        
        // Player Tab constraints
        playerScoreTab.snp.makeConstraints { make in
            make.centerY.equalToSuperview().inset(loserCenterOffset)
            make.right.equalToSuperview().inset(loserScoreMargin)
        }
        playerScoreLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        playerNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().inset(loserCenterOffset)
            make.left.equalToSuperview().inset(loserNameMargin)
        }
        
        // Enemy tab constraints
        enemyScoreTab.snp.makeConstraints { make in
            make.centerY.equalToSuperview().inset(loserCenterOffset)
            make.right.equalToSuperview().inset(loserScoreMargin)
        }
        enemyScoreLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        enemyNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().inset(loserCenterOffset)
            make.left.equalToSuperview().inset(loserNameMargin)
        }
    }
    
    func onTapEndGameButton(_ target: Any?, _ handler: Selector) {
        self.endGameButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    func setEndGameVariables(gameResult: GameResult, playerScore: Int, enemyScore: Int) {
        playerScoreLabel.text = String(playerScore)
        enemyScoreLabel.text = String(enemyScore)
        screenTitleLabel.text = getScreenTitle(for: gameResult)
        setTabImages(for: gameResult)
        setConstraintsForWinner(for: gameResult)
    }
    
    private func setTabImages(for result: GameResult) {
        switch result {
        case .playerWon:
            playerTab.image = playerWonTabImage
            enemyTab.image = enemyLostTabImage
        case .enemyWon:
            playerTab.image = playerLostTabImage
            enemyTab.image = enemyWonTabImage
        case .draw:
            playerTab.image = playerLostTabImage
            enemyTab.image = enemyLostTabImage
        }
    }
    
    private func setConstraintsForWinner(for result: GameResult) {
        if result == .playerWon {
            playerScoreTab.snp.updateConstraints { make in
                make.centerY.equalToSuperview().inset(winnerCenterOffset)
                make.right.equalToSuperview().inset(winnerScoreMargin)
            }
            playerNameLabel.snp.updateConstraints { make in
                make.centerY.equalToSuperview().inset(winnerCenterOffset)
                make.left.equalToSuperview().inset(winnerNameMargin)
            }
        }
        
        if result == .enemyWon {
            enemyScoreTab.snp.updateConstraints { make in
                make.centerY.equalToSuperview().inset(winnerCenterOffset)
                make.right.equalToSuperview().inset(winnerScoreMargin)
            }
            enemyNameLabel.snp.updateConstraints { make in
                make.centerY.equalToSuperview().inset(winnerCenterOffset)
                make.left.equalToSuperview().inset(winnerScoreMargin)
            }
        }
    }
    
    private func resetConstraints() {
        // Player Tab constraints
        playerScoreTab.snp.updateConstraints { make in
            make.centerY.equalToSuperview().inset(loserCenterOffset)
            make.right.equalToSuperview().inset(loserScoreMargin)
        }
        playerNameLabel.snp.updateConstraints { make in
            make.centerY.equalToSuperview().inset(loserCenterOffset)
            make.left.equalToSuperview().inset(loserNameMargin)
        }
        
        // Enemy tab constraints
        enemyScoreTab.snp.updateConstraints { make in
            make.centerY.equalToSuperview().inset(loserCenterOffset)
            make.right.equalToSuperview().inset(loserScoreMargin)
        }
        enemyNameLabel.snp.updateConstraints { make in
            make.centerY.equalToSuperview().inset(loserCenterOffset)
            make.left.equalToSuperview().inset(loserNameMargin)
        }
    }
    
    private func getScreenTitle(for result: GameResult) -> String {
        switch result {
        case .draw:
            return "It's a Draw!"
        case .playerWon:
            return playerName + " Won!"
        case .enemyWon:
            return enemyName + " Won!"
        }
    }
    
    
    func hide(_ onHidden: (() -> Void)?) {
        self.resetConstraints()
        self.isUserInteractionEnabled = false
        self.alpha = 0
        onHidden?()
    }
    
    func show(_ onShowing: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.alpha = 1
        onShowing?()
    }
}
