import UIKit

class StartGameScreenView: UIView, StartGameScreenViewProtocol {
    weak var featureLogic: StartGameScreenLogicProtocol!
    
    convenience init(_ featureLogic: FeatureLogicProtocol) {
        self.init(frame: UIScreen.main.bounds)
        guard let logic = featureLogic as? StartGameScreenLogicProtocol else {
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
    let backButton = BackButton()
    let shareKeyButton = UIButton()
    let waitingForPlayer = UILabel()
    
    let gameCodeLabel = UILabel()
    let shareKeyLabel = UILabel()
    let shareKey = "GX34"
    
    let buttonStack = UIStackView()
    let textFieldBackground = UIImageView(image: UIImage(named: "startGameTextFieldBackground"))
    
    // Loading font
    let titleFont = UIFont(name: "Montserrat-Bold", size: 22)
    let buttonsFont = UIFont(name: "Montserrat-Bold", size: 25)
    let gameCodeFont = UIFont(name: "Montserrat-Regular", size: 28)
    let codeFont = UIFont(name: "Montserrat-Bold", size: 32)
    let waitingForPlayerFont = UIFont(name: "Montserrat-Regular", size: 15)
    
    
    func initUI() {
        screenTitleLabel.text = "START GAME"
        screenTitleLabel.textAlignment = .center
        screenTitleLabel.font = titleFont
        screenTitleLabel.textColor = .white
        
        initTextField()
        initShareKeyButton()
        initBottomBar()
        
        buttonStack.addArrangedSubview(textFieldBackground)
        buttonStack.addArrangedSubview(shareKeyButton)
        buttonStack.axis = .vertical
        buttonStack.spacing = gridHeight * 2.5
        buttonStack.alignment = .center
        
        self.addSubview(backgroundImage)
        self.addSubview(backButton)
        self.addSubview(screenTitleLabel)
        
        self.addSubview(buttonStack)
        self.addSubview(gameCodeLabel)
        self.addSubview(shareKeyLabel)
        self.addSubview(waitingForPlayer)
        self.hide{}
    }
    
    func initBottomBar() {
        waitingForPlayer.font = waitingForPlayerFont
        waitingForPlayer.text = "waiting for player"
        waitingForPlayer.textColor = .white
    }
    
    func initShareKeyButton() {
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = UIColor.white
        shareKeyButton.setBackgroundImage(UIImage(named: "purpleSmallButton"), for: .normal)
        let shareKeyTitle = "Share"
        let shareKeyAttributedString = NSMutableAttributedString(string: shareKeyTitle, attributes: attributes)
        shareKeyAttributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key,
                                               value: CGFloat(5.0),
                                               range: NSRange(location: 0, length: shareKeyTitle.count-1))
        shareKeyButton.setAttributedTitle(shareKeyAttributedString, for: .normal)
        shareKeyButton.titleLabel?.font = buttonsFont
    }
    
    func initTextField() {
        gameCodeLabel.text = "Game Code"
        gameCodeLabel.font = gameCodeFont
        gameCodeLabel.textColor = .white
        
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = #colorLiteral(red: 0.1960784314, green: 0.06274509804, blue: 0.01568627451, alpha: 1)
        
        let shareCodeLabelString = NSMutableAttributedString(string: shareKey, attributes: attributes)
        shareCodeLabelString.addAttribute(kCTKernAttributeName as NSAttributedString.Key,
                                               value: CGFloat(5.0),
                                               range: NSRange(location: 0, length: shareKey.count-1))
        shareKeyLabel.attributedText = shareCodeLabelString
        shareKeyLabel.font = codeFont
    }
    
    func initConstraints() {
        backgroundImage.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        screenTitleLabel.snp.makeConstraints { make in
            make.topMargin.equalTo(0.75 * gridHeight )
            make.centerX.equalToSuperview()
        }
        backButton.snp.makeConstraints { make in
            make.topMargin.equalTo(0.75 * gridHeight)
            make.leftMargin.equalTo(0.75 * gridWidth)
        }
        gameCodeLabel.snp.makeConstraints { make in
            make.topMargin.equalTo(8.2 * gridHeight )
            make.centerX.equalToSuperview()
        }
        shareKeyLabel.snp.makeConstraints { make in
            make.topMargin.equalTo(10.5 * gridHeight )
            make.centerX.equalToSuperview()
        }
        waitingForPlayer.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(1.5 * gridHeight)
            //make.bottomMargin.equalTo(1.5 * gridHeight )
            make.centerX.equalToSuperview()
        }
        buttonStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
    }
    
    func onTapBackButton(_ target: Any?, _ handler: Selector) {
        self.backButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    func onTapShareKeyButton(_ target: Any?, _ handler: Selector) {
        self.shareKeyButton.addTarget(target, action: handler, for: .touchUpInside)
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
