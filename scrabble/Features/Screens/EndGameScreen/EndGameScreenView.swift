import UIKit

fileprivate let titleFont = UIFont(name: "Baloo", size: 30)
fileprivate let playerNameFont = UIFont(name: "Baloo", size: 30)
fileprivate let playerScoreFont = UIFont(name: "Baloo", size: 30)
fileprivate let endGameButtonFont = UIFont(name: "Baloo", size: 30)

fileprivate let scoreTabImage = UIImage(named: "scoreTabImage")
fileprivate let playerWonTabImage = UIImage(named: "playerWonImage")
fileprivate let playerLostTabImage = UIImage(named: "playerLostImage")
fileprivate let enemyWonTabImage = UIImage(named: "enemyWonImage")
fileprivate let enemyLostTabImage = UIImage(named: "enemyLostIamge")
fileprivate let endGameButtonImage = UIImage(named: "endGameButtonImage")


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
        self.hide{}
    }

    func initTitleLabelUI() {
        screenTitleLabel.text = "Player Wins!"
        screenTitleLabel.font = titleFont
        screenTitleLabel.textAlignment = .center
        self.addSubview(screenTitleLabel)
    }
    
    func initTabs() {
        initPlayerTab()
        initEnemyTab()
        
        tabStack.axis = .vertical
        tabStack.spacing = 3 * gridHeight
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
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = appColors.white
        
        let endGameTitle = "End Game"
        let endGameAttributedString = NSMutableAttributedString(string: endGameTitle, attributes: attributes)
        endGameAttributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key,
                                               value: CGFloat(10.0),
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
            make.topMargin.equalTo(80)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        tabStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        endGameButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(gridHeight * 5)
        }
    }
    
    func onTapEndGameButton(_ target: Any?, _ handler: Selector) {
        self.endGameButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    func hide(_ onHidden: (() -> Void)?) {
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
