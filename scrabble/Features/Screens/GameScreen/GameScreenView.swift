import UIKit

fileprivate let activePlayerNameFont = UIFont(name: "Montserrat-Bold", size: 22)
fileprivate let passivePlayerNameFont = UIFont(name: "Montserrat-Bold", size: 20)
fileprivate let scoreFont = UIFont(name: "Montserrat-Bold", size: 25)
fileprivate let timerFont = UIFont(name: "Montserrat-Bold", size: 30)
fileprivate let scanAnythingFont = UIFont(name: "Montserrat-regular", size: 15)
fileprivate let currentLetterFont = UIFont(name: "Baloo", size: 30)

fileprivate let activeTabImage = UIImage(named: "activePlayerTab")
fileprivate let passiveTabImage = UIImage(named: "passivePlayerTab")
fileprivate let scoreTabImage = UIImage(named: "scoreTab")
fileprivate let tileBack = UIImage(named: "letterTileBack")
fileprivate let tileMediumPurple = UIImage(named: "letterTileMediumPurple")
fileprivate let tileDarkPurple = UIImage(named: "letterTileDarkPurple")

fileprivate let yellowCard = UIImage(named: "wildCardYellow")
fileprivate let pinkCard = UIImage(named: "wildCardPink")
fileprivate let darkPurpleCard = UIImage(named: "wildCardPurple")

fileprivate let letterTileSpacing: CGFloat = 10
// Tiles animation parameters
fileprivate let animatingInDuration: Double = 1
fileprivate let wordWaitDuration: Double = 2.5
fileprivate let animatingOutDuration: Double = 1
fileprivate let loadingWordRotationAnimationKey = "rotation"



class GameScreenView: UIView, GameScreenViewProtocol {
    
    weak var featureLogic: GameScreenLogicProtocol!
    
    private let timerButton = UIButton()
    private let scanAnythingLabel = UILabel()
    private let crossHair = UIImageView()
    private let triesArcs = [UIBezierPath()]
    private let triesView = UIView()
    private var currentLetterBackground = UIImageView()
    private var currentTileColor = appColors.mediumPurple
    private let loadingTile = UIImageView(image: tileBack)

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
    
    private let currentLetterLabel = UILabel()
    
    private var currentTries = 3
    
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
                currentTries -= 1
                return
            }
        }
        log.error("Arc for animation not found")
    }
    
    func reduceOneWildCard(isPlayerTurn: Bool, from currentWildCardCount: Int, onCompelteCallback: (() -> Void)?) {
        let cardsView = isPlayerTurn ? playerCards : enemyCards
        for card in cardsView.arrangedSubviews {
            if card.tag == currentWildCardCount {
                animateWildCardOut(card: card)  {
                    self.animateCurrentLetterOut {
                        self.currentLetterLabel.text = ""
                        self.currentLetterBackground.image = chooseCardFor(number: card.tag)
                        self.currentLetterBackground.center = CGPoint(x: UIScreen.main.bounds.width + 3 * gridWidth, y: self.currentLetterBackground.center.y)
                        for subview in self.currentLetterBackground.subviews {
                            subview.removeFromSuperview()
                        }
                        self.animateCurrentLetterIn {
                            onCompelteCallback?()
                        }
                    }
                }
            }
        }
    }
    
    func animateWildCardOut(card: UIView, onCompelteCallback: (() -> Void)?) {
        UIView.animate(withDuration: 0.50,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
            card.transform = card.transform.translatedBy(x: 0, y: -card.frame.height + 5)
        }) { (isCompelte) in
            card.removeFromSuperview()
            onCompelteCallback?()
        }
    }
    
    func setScanLabelTo(isHidden: Bool) {
        scanAnythingLabel.isHidden = isHidden
    }
    
    func animateCurrentLetterIn(onCompelteCallback: (() -> Void)?) {
        UIView.animate(withDuration: animatingOutDuration,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.currentLetterBackground.center = CGPoint(x: UIScreen.main.bounds.width/2, y: self.currentLetterBackground.center.y)
        }, completion: { (isComplete) in
            if !isComplete {
                log.warning("Word animating in animation couldnt complete")
            } else {
                onCompelteCallback?()
            }
        })
    }
    
    func animateCurrentLetterOut(onCompelteCallback: (() -> Void)?) {
        UIView.animate(withDuration: animatingOutDuration,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                self.currentLetterBackground.center = CGPoint(x:  -3 * gridWidth, y: self.currentLetterBackground.center.y)
        }, completion: { (isComplete) in
            if !isComplete {
                log.warning("Word animating in animation couldnt complete")
            } else {
                onCompelteCallback?()
            }
        })
    }
    
    func resetTries() {
        currentTries = 3
        guard let layers = self.layer.sublayers else { return }
        for i in 1...3 {
            for layer in layers {
                if layer.name == String(i) {
                    resetArc(for: layer)
                }
            }
        }
        log.verbose("Arcs for tries reseted ")
    }
    
    func updateTabs(isPlayerTurn: Bool, playerScore: Int, playerWildCards: Int, enemyScore: Int, enemyWildCards: Int) {
        togglePlayerView(isActive: isPlayerTurn)
        toggleEnemyView(isActive: !isPlayerTurn)
        
        if isPlayerTurn {
            playerScoreLabel.text = String(playerScore)
            getCardsView(total: playerWildCards, in: playerCards, isReverse: false)
        } else {
            enemyScoreLabel.text = String(enemyScore)
            getCardsView(total: enemyWildCards, in: enemyCards, isReverse: true)
        }
    }
    
    func setUserInteractionEnabled(to isUserInteractionEnabled: Bool) {
        self.isUserInteractionEnabled = isUserInteractionEnabled
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
    
    func showSuccess(with word: String, isTurn: Bool, score: Int, cardPosition: Int?, isWildCardModeOn: Bool, showSuccessCallback: (() -> Void)?) {
        let wordToShow = isWildCardModeOn ? word : String(word.dropFirst())
        let tilesToShow = getTiles(for: wordToShow)
        if isTurn {
            playerScoreLabel.text = String(score)
        } else {
            enemyScoreLabel.text = String(score)
        }
        guard let lastTile = tilesToShow.last else {
            log.error("No last letter found")
            return
        }
        positionOnScene(for: tilesToShow)
        if let wildCardPosition = cardPosition {
            showWildCard(on: tilesToShow[wildCardPosition], color: appColors.yellow)
        }
        animateWordIn(from: tilesToShow, isWildCardMode: isWildCardModeOn) {}
        self.animateWordOut(from: tilesToShow, wordAnimatedOutCallBack: {
            self.currentLetterBackground = lastTile
            showSuccessCallback?()
        })
    }
    
    func showWildCard(on imageView: UIImageView, color: UIColor) {
        let cardImage = UIImageView()
        cardImage.transform = cardImage.transform.rotated(by: 0.15 * CGFloat.pi)
        switch color {
        case appColors.yellow:
            cardImage.image = yellowCard
        case appColors.darkPurple:
            cardImage.image = darkPurpleCard
        case appColors.pink:
            cardImage.image = pinkCard
        default:
            log.warning("Wild card image for color not found")
        }
        imageView.addSubview(cardImage)
        self.bringSubview(toFront: imageView)
        cardImage.snp.makeConstraints { make in
            make.center.equalToSuperview().offset(20)
        }
    }
    
    func resetGameUI() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        initUI()
        initConstraints()
        currentTries = 3
    }
    
    func updateTimer(to seconds: Int) {
        let time = seconds == -1 ? "Wild card" : getTimeInString(from: seconds)
        let spacing = seconds == -1 ? CGFloat(3) : CGFloat(8)
        var attributes = [NSAttributedStringKey: AnyObject]()
        attributes[.foregroundColor] = getTimerColor(from: seconds)
        let timerAttributedString = NSMutableAttributedString(string: time, attributes: attributes)
        timerAttributedString.addAttribute(kCTKernAttributeName as NSAttributedStringKey,
                                               value: spacing,
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
        mainView?.backgroundColor = .clear
        onHidden?()
    }
    
    func show(_ onShowing: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.alpha = 1
        currentLetterLabel.text = String(gameState.currentLetter)
        setViewConstraintsUnderStatusBar(for: self)
        mainView?.backgroundColor = appColors.white
        onShowing?()
    }
    
    func setNames(playerName: String, enemyName: String) {
        self.playerNameLabel.text = playerName
        self.enemyNameLabel.text = enemyName
    }
}


// Word Animations
extension GameScreenView {
    func showLoadingWordAnimation() {
        loadingTile.isHidden = false
        let animate = CABasicAnimation(keyPath: "transform.rotation")
        animate.fromValue = 0.0
        animate.toValue = Float.pi * 2
        animate.repeatCount = Float.infinity
        animate.duration = 0.75
        loadingTile.layer.add(animate, forKey: loadingWordRotationAnimationKey)
    }
    
    func hideLoadingWordAnimation() {
        if loadingTile.layer.animation(forKey: loadingWordRotationAnimationKey) != nil {
            layer.removeAnimation(forKey: loadingWordRotationAnimationKey)
        }
        loadingTile.isHidden = true
    }
    
    func animateWordOut(from tiles: [UIImageView], wordAnimatedOutCallBack: (() -> Void)?) {
        guard let lastTile = tiles.last else {
            log.error("No last letter found")
            return
        }
        var tileXPosition = -3 * gridWidth * CGFloat(tiles.count)
        let animateWord = [currentLetterBackground] + tiles
        
        for tile in animateWord.dropLast() {
            UIView.animate(withDuration: animatingOutDuration,
                           delay: animatingInDuration + wordWaitDuration,
                           options: UIViewAnimationOptions.curveEaseInOut,
                           animations: {
                            tile.center = CGPoint(x: tileXPosition, y: tile.center.y)
            }, completion: { (isComplete) in
                if !isComplete {
                    log.warning("Word animating in animation couldnt complete")
                } else {
                    tile.removeFromSuperview()
                }
            })
            tileXPosition = tileXPosition + 3 * gridWidth
        }
        UIView.animate(withDuration: animatingOutDuration,
                       delay: animatingInDuration + wordWaitDuration,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        lastTile.center = CGPoint(x: UIScreen.main.bounds.width/2, y: lastTile.center.y)
        }, completion: { (isComplete) in
            if !isComplete {
                log.warning("Word animating in animation couldnt complete")
            } else {
                wordAnimatedOutCallBack?()
            }
        })
    }
    
    func animateWordIn(from tiles: [UIImageView], isWildCardMode: Bool, wordAnimatedInCallback: (() -> Void)?) {
        guard let tileWidth = currentLetterBackground.image?.size.width  else {
            log.error("Image for current letter not found")
            return
        }
        let tilesCount = isWildCardMode ? tiles.count + 2: tiles.count + 1
        let wordWidth = calculateWordWidth(for: tilesCount)
        
        let currentLetterFinalXPosition = isWildCardMode ? -gridWidth : (UIScreen.main.bounds.width - wordWidth + tileWidth)/2
        
        UIView.animate(withDuration: animatingInDuration,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.currentLetterBackground.center = CGPoint(x: currentLetterFinalXPosition, y: self.currentLetterBackground.center.y)
        })
        
        var tileXPosition = (UIScreen.main.bounds.width - wordWidth + tileWidth)/2
        tiles.forEach { (tile) in
            tileXPosition = tileXPosition + tileWidth + letterTileSpacing
            UIView.animate(withDuration: animatingInDuration,
                           delay: 0,
                           options: UIViewAnimationOptions.curveEaseInOut,
                           animations: {
                            tile.center = CGPoint(x: tileXPosition, y: tile.center.y)
            }, completion: { (isComplete) in
                if !isComplete {
                    log.warning("Word animating in animation couldnt complete")
                }
                wordAnimatedInCallback?()
            })
        }
    }
    
    func positionOnScene(for tiles: [UIImageView]) {
        guard let imageHeight = currentLetterBackground.image?.size.height  else {
            log.error("Image for current letter not found")
            return
        }
        for (index, view) in tiles.enumerated() {
            self.addSubview(view)
            view.center = CGPoint(x: UIScreen.main.bounds.width + CGFloat(index + 1) * 3 * gridWidth, y: gridHeight * 4 + imageHeight/2)
        }
    }
    func calculateWordWidth(for letterCount: Int) -> CGFloat {
        guard let imageWidth = currentLetterBackground.image?.size.width  else {
            log.error("Image for current letter not found")
            return 0
        }
        return imageWidth * CGFloat(letterCount) + CGFloat(letterCount - 1) *  letterTileSpacing
    }
    
    
    func getTiles(for word: String) -> [UIImageView] {
        var imageTiles = [UIImageView]()
        for character in word {
            let letterBackground = UIImageView(image: tileMediumPurple)
            letterBackground.contentMode = .center
            let letterLabel = UILabel()
            letterLabel.text = String(character)
            letterLabel.font = currentLetterFont
            
            // Set colors
            currentTileColor = currentTileColor == appColors.mediumPurple ? appColors.darkPurple : appColors.mediumPurple
            if currentTileColor == appColors.mediumPurple {
                letterBackground.image = tileMediumPurple
            } else {
                letterBackground.image = tileDarkPurple
            }
            letterLabel.textColor = currentTileColor
            
            letterBackground.addSubview(letterLabel)
            imageTiles.append(letterBackground)
            
            letterLabel.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
        return imageTiles
    }
}



// Initialising and adding constraints to all the subviews
extension GameScreenView {
    private func initUI() {
        initTriesUI()
        initTabsUI()
        initCurrentLetterUI()
        initTimerUI()
        initLoadingWordAnimation()
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
        self.addSubview(enemyTab)
    }
    
    private func initCurrentLetterUI() {
        currentLetterBackground.image = tileMediumPurple
        currentLetterBackground.contentMode = .center
        currentLetterLabel.font = currentLetterFont
        currentLetterLabel.textColor = appColors.mediumPurple
        
        if let imageHeight = currentLetterBackground.image?.size.height  {
            self.currentLetterBackground.center = CGPoint(x: UIScreen.main.bounds.width/2, y: gridHeight * 4 + imageHeight/2 )
        }
        self.currentLetterBackground.addSubview(currentLetterLabel)
        self.addSubview(currentLetterBackground)
        
        currentLetterLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
    }
    
    private func initTimerUI() {
        timerButton.setBackgroundImage(UIImage(named: "timerTab"), for: .normal)
        timerButton.titleLabel?.font = timerFont
        timerButton.titleEdgeInsets = UIEdgeInsets(top: 15,left: 0,bottom: 0,right: 0)
        scanAnythingLabel.text = "Scan anything"
        scanAnythingLabel.font = scanAnythingFont
        scanAnythingLabel.textColor = appColors.lightPurple
        scanAnythingLabel.isHidden = true
        self.addSubview(timerButton)
        self.addSubview(scanAnythingLabel)
    }
    
    private func initTriesUI() {
        crossHair.image = UIImage(named: "crosshair")
        drawCenterCircle()
        drawTries(for: 3)
        self.addSubview(triesView)
        triesView.addSubview(crossHair)
    }
    
    private func initLoadingWordAnimation() {
        loadingTile.isHidden = true
        self.addSubview(loadingTile)
    }
    
    private func drawCenterCircle() {
        let shape = CAShapeLayer()
        let path = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: gridHeight * 5, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        shape.lineWidth = 6
        shape.opacity = 0.5
        shape.path = path.cgPath
        shape.strokeColor = appColors.white.cgColor
        shape.fillColor = UIColor.clear.cgColor
        triesView.layer.addSublayer(shape)
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
            shape.position = CGPoint(x: 0, y: 0)
            triesView.layer.addSublayer(shape)
            startAngle = startAngle + gapAngle + anglePerArc
        }
    }
    
    private func initConstraints() {
        timerButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        scanAnythingLabel.snp.makeConstraints { make in
            make.top.equalTo(timerButton.snp.top).inset(6)
            make.centerX.equalToSuperview()
        }
        triesView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        crossHair.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        loadingTile.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(loadingTile.frame.width * 0.25)
            make.top.equalToSuperview().inset(gridHeight * 4)
        }
        
        // Player Tab constraints
        playerTab.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
        }
        playerScoreTab.snp.makeConstraints { make in
            make.centerY.equalToSuperview().inset(loserCenterOffset)
            make.right.equalToSuperview().inset(7)
        }
        playerScoreLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        playerNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().inset(loserCenterOffset)
            make.left.equalToSuperview().inset(10)
        }
        playerCards.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(9)
            make.top.equalTo(playerTab.snp.bottom).inset(10)
        }
        
        // Enemy tab constraints
        enemyTab.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
        }
        enemyScoreTab.snp.makeConstraints { make in
            make.centerY.equalToSuperview().inset(loserCenterOffset)
            make.right.equalToSuperview().inset(7)
        }
        enemyScoreLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        enemyNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().inset(loserCenterOffset)
            make.left.equalToSuperview().inset(10)
        }
        enemyCards.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(9)
            make.top.equalTo(enemyTab.snp.bottom).inset(10)
        }
    }
}

func getCardsView(total: Int, in stackView: UIStackView, isReverse: Bool) {
    for card in stackView.arrangedSubviews {
        card.removeFromSuperview()
    }
    guard total > 0 else {
        log.verbose("No cards to display")
        return
    }
    for i in 1...total {
        let cardNumber = isReverse ? total - i + 1 : i
        let cardImage = chooseCardFor(number: cardNumber)
        let view = UIImageView(image: cardImage)
        view.tag = cardNumber
        stackView.addArrangedSubview(view)
    }
}


func chooseCardFor(number : Int) -> UIImage? {
    // For now repeating the cards in a cyclic manner
    switch number % 3 {
    case 0:
        return darkPurpleCard
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

func getTimerColor(from seconds: Int) -> UIColor {
    if seconds > 5 || seconds == -1 {
        return appColors.white
    }
    return appColors.red
}
