import UIKit

fileprivate let activePlayerNameFont = UIFont(name: "Montserrat-Bold", size: 22)
fileprivate let passivePlayerNameFont = UIFont(name: "Montserrat-Bold", size: 20)
fileprivate let scoreFont = UIFont(name: "Montserrat-Bold", size: 25)
fileprivate let timerFont = UIFont(name: "Montserrat-Bold", size: 30)
fileprivate let currentLetterFont = UIFont(name: "Baloo", size: 30)

fileprivate let activeTabImage = UIImage(named: "activePlayerTab")
fileprivate let passiveTabImage = UIImage(named: "passivePlayerTab")
fileprivate let scoreTabImage = UIImage(named: "scoreTab")

class GameScreenView: UIView, GameScreenViewProtocol {
    weak var featureLogic: GameScreenLogicProtocol!
    
    private let timerButton = UIButton()
    private let crossHair = UIImageView()
    private let triesArcs = [UIBezierPath()]
    private let currentLetterBackground = UIImageView()
    private let currentLetterLabel = UILabel()

    private let playerTab = UIImageView()
    private let playerScoreTab = UIImageView()
    private let playerScoreLabel = UILabel()
    private let playerNameLabel = UILabel()
    private let playerCards = UIStackView()

    private let enemyTab = UIImageView()
    private let enemyScoreTab = UIImageView()
    private let enemyScoreLabel = UILabel()
    private let enemyNameLabel = UILabel()
    private let enemyCards = UIStackView()
    
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
    
    func reduceOneTry() {
        guard let layers = self.layer.sublayers else { return }
        for layer in layers {
            if layer.name == String(currentTries) {
                animateArcForFailTry(for: layer)
                return
            }
        }
        log.error("Arc for animation not found")
    }
    
    func resetTries() {
        guard let layers = self.layer.sublayers else { return }
        for i in 1...maxTries {
            for layer in layers {
                if layer.name == String(i) {
                    resetArc(for: layer)
                }
            }
        }
        log.verbose("Arcs for tries reseted ")
    }
    
    func updateTabs(isPlayerTurn: Bool, score: Int, cards: Int) {
        togglePlayerView(isActive: isPlayerTurn)
        toggleEnemyView(isActive: !isPlayerTurn)
        
        if isPlayerTurn {
            playerScoreLabel.text = String(score)
            getCardsView(total: cards, in: playerCards)
        } else {
            enemyScoreLabel.text = String(score)
            getCardsView(total: cards, in: enemyCards)
        }
    }
    
    private func togglePlayerView(isActive: Bool) {
        playerScoreTab.isHidden = !isActive
        playerCards.isHidden = !isActive
        if isActive {
            playerTab.image = activeTabImage
            playerNameLabel.font = activePlayerNameFont
            playerNameLabel.textColor = appColors.white
        } else {
            playerTab.image = passiveTabImage
            playerNameLabel.font = passivePlayerNameFont
            playerNameLabel.textColor = appColors.red
        }
    }
    
    private func toggleEnemyView(isActive: Bool) {
        enemyScoreTab.isHidden = !isActive
        enemyCards.isHidden = !isActive
        if isActive {
            enemyTab.image = activeTabImage
            enemyNameLabel.font = activePlayerNameFont
            enemyNameLabel.textColor = appColors.white
        } else {
            enemyTab.image = passiveTabImage
            enemyNameLabel.font = passivePlayerNameFont
            enemyNameLabel.textColor = appColors.red
        }
    }
    
    func updateTimer(to time: String) {
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = appColors.white
        let timerAttributedString = NSMutableAttributedString(string: time, attributes: attributes)
        timerAttributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key,
                                               value: CGFloat(8.0),
                                               range: NSRange(location: 0, length: time.count-1))
        timerButton.setAttributedTitle(timerAttributedString, for: .normal)
    }
    
    func onTapScreen(_ target: Any?, _ handler: Selector) {
        let gestureRecognizer = UITapGestureRecognizer(target: target, action: handler)
        self.addGestureRecognizer(gestureRecognizer)
    }
    func onTapTimerButton(_ target: Any?, _ handler: Selector) {
        timerButton.addTarget(target, action: handler, for: .touchUpInside)
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
extension GameScreenView {
    private func initUI() {
        initTriesUI()
        initTabsUI()
        initCurrentLetterUI()
        initTimerUI()
        self.hide{}
    }
    
    private func initTabsUI() {
        initPlayerTab()
        initEnemyTab()
    }
    
    private func initPlayerTab() {
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
        playerNameLabel.font = activePlayerNameFont
        playerNameLabel.textColor = appColors.white
        playerNameLabel.text = playerName
        self.addSubview(playerTab)
    }
    
    private func initEnemyTab() {
        
        self.addSubview(enemyCards)
        enemyTab.addSubview(enemyNameLabel)
        enemyTab.addSubview(enemyScoreTab)
   
        // Flipping the enemy tab
        self.enemyTab.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.enemyScoreLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.enemyNameLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
   
        // Initialising card view
        enemyCards.axis = .horizontal
        enemyCards.spacing = -10
        
        // Initialising score tab
        enemyScoreTab.addSubview(enemyScoreLabel)
        enemyScoreTab.image = scoreTabImage
        
        enemyScoreLabel.text = String(0)
        enemyScoreLabel.font = scoreFont
        enemyScoreLabel.textColor = appColors.darkPurple
        enemyScoreLabel.textAlignment = .center
        
        // Initialising name tab
        enemyNameLabel.font = activePlayerNameFont
        enemyNameLabel.textColor = appColors.white
        enemyNameLabel.text = enemyName
        self.addSubview(enemyTab)
    }
    
    private func initCurrentLetterUI() {
        currentLetterBackground.image = UIImage(named: "letterTilePurple")
        currentLetterLabel.text = currentLetter
        currentLetterLabel.font = currentLetterFont
        currentLetterLabel.textColor = appColors.mediumPurple
        self.currentLetterBackground.addSubview(currentLetterLabel)
        self.addSubview(currentLetterBackground)
    }
    
    private func initTimerUI() {
        timerButton.setBackgroundImage(UIImage(named: "timerTab"), for: .normal)
        timerButton.titleLabel?.font = timerFont
        self.addSubview(timerButton)
    }
    
    private func initTriesUI() {
        crossHair.image = UIImage(named: "crosshair")
        drawCenterCircle()
        drawTries(for: maxTries)
        self.addSubview(crossHair)
    }
    
    private func drawCenterCircle() {
        let shape = CAShapeLayer()
        let path = UIBezierPath(arcCenter: self.center, radius: gridHeight * 5, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        shape.lineWidth = 6
        shape.opacity = 0.5
        shape.path = path.cgPath
        shape.strokeColor = appColors.white.cgColor
        shape.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(shape)
    }
    
    private func drawTries(for maxTries: Int) {
        let gapBetweenArcRationToArcAngle: CGFloat = 0.08
        let anglePerArc = 2 * CGFloat.pi / (( gapBetweenArcRationToArcAngle + 1) * CGFloat(maxTries))
        let gapAngle = gapBetweenArcRationToArcAngle * anglePerArc
        var startAngle = -CGFloat.pi/2 + gapAngle / 2
        
        for i in 1...maxTries {
            let shape = CAShapeLayer()
            let path = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: gridHeight * 6, startAngle: startAngle, endAngle: startAngle + anglePerArc, clockwise: true)
            shape.lineWidth = 2
            shape.opacity = 1
            shape.path = path.cgPath
            shape.strokeColor = appColors.white.cgColor
            shape.fillColor = UIColor.clear.cgColor
            shape.name = String(i)
            shape.position = self.center
            self.layer.addSublayer(shape)
            startAngle = startAngle + gapAngle + anglePerArc
        }
    }
    
    private func initConstraints() {
        currentLetterBackground.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(gridHeight * 4)
        }
        currentLetterLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        timerButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        crossHair.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // Player Tab constraints
        playerTab.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
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
            make.left.equalToSuperview().inset(4)
            make.top.equalTo(playerTab.snp.bottom).inset(10)
        }
        
        // Enemy tab constraints
        enemyTab.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
        }
        enemyScoreTab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(7)
        }
        enemyScoreLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        enemyNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(10)
        }
        enemyCards.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(4)
            make.top.equalTo(enemyTab.snp.bottom).inset(10)
        }
    }
}

func getCardsView(total: Int, in stackView: UIStackView) {
    for card in stackView.arrangedSubviews {
        card.removeFromSuperview()
    }
    guard total > 0 else {
        log.verbose("No cards to display")
        return
    }
    for i in 1...total {
        let cardImage = chooseCardFor(number: i)
        let view = UIImageView(image: cardImage)
        stackView.addArrangedSubview(view)
    }
}


func chooseCardFor(number : Int) -> UIImage? {
    // For now repeating the cards in a cyclic manner
    
    let yellowCard = UIImage(named: "wildCardYellow")
    let pinkCard = UIImage(named: "wildCardPink")
    let purpleCard = UIImage(named: "wildCardPurple")
    
    switch number % 3 {
    case 0:
        return purpleCard
    case 1:
        return yellowCard
    case 2:
        return pinkCard
    default:
        return nil
    }
}


fileprivate func animateArcForFailTry(for layer: CALayer) {
    // Changing the color without any animation here, for now atleast
    if let shapeLayer = layer as? CAShapeLayer {
        shapeLayer.strokeColor = appColors.red.cgColor
    }
    let animationDuration: Double = 1
    
    // Animation to move the arc away from the center
    layer.transform = CATransform3DMakeScale(1.5, 1.5, 1)
    let scaleAnimation = CABasicAnimation(keyPath: "transform")
    scaleAnimation.fromValue = CATransform3DIdentity
    scaleAnimation.toValue = CATransform3DMakeScale(1.5, 1.5, 1)
    scaleAnimation.duration = animationDuration
    layer.add(scaleAnimation, forKey: "transform")
    
    // Animation to make the arcs disappear
    layer.opacity = 0
    let opacityAnimation = CABasicAnimation(keyPath: "opacity")
    opacityAnimation.duration = animationDuration
    opacityAnimation.fromValue = 1
    opacityAnimation.toValue = 0
    layer.add(opacityAnimation, forKey: "opacity")
}

fileprivate func resetArc(for layer: CALayer) {
    if let shapeLayer = layer as? CAShapeLayer {
        shapeLayer.strokeColor = appColors.white.cgColor
    }
    layer.transform = CATransform3DIdentity
    layer.opacity = 1
}
