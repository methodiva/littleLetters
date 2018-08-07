import UIKit

fileprivate let endGameButtonFont = UIFont(name: "Montserrat-Bold", size: 30)
fileprivate let titleFont = UIFont(name: "Montserrat-Bold", size: 22)
fileprivate let scoreFont = UIFont(name: "Montserrat-Bold", size: 22)
fileprivate let timerFont = UIFont(name: "Montserrat-Bold", size: 22)
fileprivate let playerNameFont = UIFont(name: "Montserrat-Bold", size: 22)

fileprivate let playerTabImage = UIImage(named: "timerScreenPlayerTabImage")
fileprivate let scoreTabImage =  UIImage(named: "timerScreenScoreTabImage")
fileprivate let endGameButtonImage = UIImage(named: "endGameButtonImage")

class TimerScreenView: UIView, TimerScreenViewProtocol {
    weak var featureLogic: TimerScreenLogicProtocol!
    
    convenience init(_ featureLogic: FeatureLogicProtocol) {
        self.init(frame: UIScreen.main.bounds)
        guard let logic = featureLogic as? TimerScreenLogicProtocol else {
            log.error("Invalid featureLogic provided")
            return
        }
        self.featureLogic = logic
        self.isUserInteractionEnabled = false
        initUI()
        initConstraints()
    }
    
    // UI Elements
    private let backgroundImage = UIImageView(image: UIImage(named: "BackgroundImage"))
    private let screenTitleLabel = UILabel()
    private let backButton = BackButton()
    private let timerLabel = UILabel()
    // Player Tab UI
    private let playerTab = UIImageView()
    private let playerNameLabel = UILabel()
    private let playerScoreTab = UIImageView()
    private let playerScoreLabel = UILabel()
    private let playerCards = UIStackView()
    private let endGameButton = UIButton()
    
    func setTimer(to string: String) {
        timerLabel.text = string
    }
    
    func onTapBackButton(_ target: Any?, _ handler: Selector) {
        self.backButton.addTarget(target, action: handler, for: .touchUpInside)
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


// Initialising and adding constraints to all the subviews
extension TimerScreenView {
    func initUI() {
        initScreenTitleUI()
        initTimerLabelUI()
        initPlayerTabUI()
        initEndGameButtonUI()
        self.addSubview(backgroundImage)
        self.addSubview(backButton)
        self.hide{}
    }
    
    func initScreenTitleUI() {
        screenTitleLabel.text = "MY TURN"
        screenTitleLabel.textAlignment = .center
        screenTitleLabel.font = titleFont
        screenTitleLabel.textColor = appColors.white
        self.addSubview(screenTitleLabel)
    }
    
    private func initTimerLabelUI() {
        timerLabel.font = timerFont
        timerLabel.textColor = appColors.white
        timerLabel.text = "0"
        self.addSubview(timerLabel)
    }
    
    private func initPlayerTabUI() {
        self.addSubview(playerCards)
        playerTab.addSubview(playerNameLabel)
        playerTab.addSubview(playerScoreTab)
        
        // Initialising card view
        playerCards.axis = .horizontal
        playerCards.spacing = -10
        
        // Initialising score tab
        playerScoreTab.addSubview(playerScoreLabel)
        playerScoreTab.image = scoreTabImage
        
        playerScoreLabel.text = String(0)
        playerScoreLabel.font = scoreFont
        playerScoreLabel.textColor = appColors.darkPurple
        playerScoreLabel.textAlignment = .center
        
        // Initialising name tab
        playerNameLabel.font = playerNameFont
        playerNameLabel.textColor = appColors.white
        playerNameLabel.text = playerName
        self.addSubview(playerTab)
    }
    
    func initEndGameButtonUI() {
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
    
    private func initConstraints() {
        backgroundImage.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        screenTitleLabel.snp.makeConstraints { make in
            make.topMargin.equalTo(0.75 * gridHeight )
            make.centerX.equalToSuperview()
        }
        timerLabel.snp.makeConstraints { make in
            make.topMargin.equalTo(3 * gridHeight )
            make.centerX.equalToSuperview()
        }
        backButton.snp.makeConstraints { make in
            make.topMargin.equalTo(0.75 * gridHeight)
            make.leftMargin.equalTo(0.75 * gridWidth)
        }
        endGameButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(gridHeight * 5)
        }
        
        // Player Tab constraints
        playerTab.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        playerScoreTab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(7)
        }
        playerScoreLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        playerNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(10)
        }
        playerCards.snp.makeConstraints { make in
            make.left.equalTo(playerTab.snp.left).inset(10)
            make.top.equalTo(playerTab.snp.bottom).inset(10)
        }
    }
}
