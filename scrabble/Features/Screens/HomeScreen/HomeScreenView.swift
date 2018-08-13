import UIKit
import SnapKit

// The below variables are to be put in the config file, which is in another branch
let gridWidth = UIScreen.main.bounds.width/15
let gridHeight = UIScreen.main.bounds.height/27

let appId = "1316361894"

let playerName = "Divya"
let enemyName = "Jyoti"
let currentLetter = "T"
let maxTries = 3
var currentTries = 3

struct appColors {
    static let darkPurple = #colorLiteral(red: 0.2431372549, green: 0.06666666667, blue: 0.3176470588, alpha: 1)
    static let mediumPurple  = #colorLiteral(red: 0.4588235294, green: 0.1843137255, blue: 0.5411764706, alpha: 1)
    static let lightPurple = #colorLiteral(red: 0.6431372549, green: 0.4235294118, blue: 0.8784313725, alpha: 1)
    static let white = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let yellow = #colorLiteral(red: 0.9098039216, green: 0.7725490196, blue: 0.1098039216, alpha: 1)
    static let pink = #colorLiteral(red: 0.9215686275, green: 0.3647058824, blue: 0.7450980392, alpha: 1)
    static let red = #colorLiteral(red: 1, green: 0.2862745098, blue: 0.3607843137, alpha: 1)
}


class HomeScreenView: UIView, HomeScreenViewProtocol {
    weak var featureLogic: HomeScreenLogicProtocol!
    
    convenience init(_ featureLogic: FeatureLogicProtocol) {
        self.init(frame: UIScreen.main.bounds)
        guard let logic = featureLogic as? HomeScreenLogicProtocol else {
            log.error("Invalid featureLogic provided")
            return
        }
        self.featureLogic = logic
        self.isUserInteractionEnabled = true
        initUI()
        initConstraints()
    }
    
    // UI Elements
    let gameTitleImageView = UIImageView(image: UIImage(named: "gameTitle"))
    let backgroundImage = UIImageView(image: UIImage(named: "BackgroundImage"))
    let playButtonStack = UIStackView()
    let subMenuButtonStack = UIStackView()
    let startGameButton = UIButton()
    let joinGameButton = UIButton()
    let tutorialButton = UIButton()
    let settingsButton = UIButton()
    
    let buttonsFont = UIFont(name: "Montserrat-Bold", size: 30)
    
    // UIimages for buttons
    let startGameImage = UIImage(named: "purpleButton")
    let joinGameImage = UIImage(named: "pinkButton")
    let tutorialImage = UIImage(named: "tutorialButton")
    let settingsImage = UIImage(named: "settingsButton")
    
    func initUI() {
        initUIConfiguration()
        self.addSubview(backgroundImage)
        self.addSubview(gameTitleImageView)
        self.addSubview(playButtonStack)
        self.addSubview(subMenuButtonStack)
    }
    
    func initUIConfiguration() {
        initPlayButtons()
        
        subMenuButtonStack.axis = .horizontal
        subMenuButtonStack.spacing = gridWidth
        subMenuButtonStack.addArrangedSubview(settingsButton)
        subMenuButtonStack.addArrangedSubview(tutorialButton)
        
        tutorialButton.setImage(tutorialImage, for: .normal)
        settingsButton.setImage(settingsImage, for: .normal)
    }
    
    func initPlayButtons() {
        playButtonStack.axis = .vertical
        playButtonStack.spacing = gridHeight
        playButtonStack.addArrangedSubview(startGameButton)
        playButtonStack.addArrangedSubview(joinGameButton)
        
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = appColors.white
        
        let startGameTitle = "Start"
        startGameButton.setBackgroundImage(startGameImage, for: .normal)
        let startGameAttributedString = NSMutableAttributedString(string: startGameTitle, attributes: attributes)
        startGameAttributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key,
                                               value: CGFloat(10.0),
                                               range: NSRange(location: 0, length: startGameTitle.count-1))
        startGameButton.setAttributedTitle(startGameAttributedString, for: .normal)
        startGameButton.titleLabel?.font = buttonsFont
        
        let joinGameTitle = "Join"
        joinGameButton.setBackgroundImage(joinGameImage, for: .normal)
        let joinGameAttributedString = NSMutableAttributedString(string: joinGameTitle, attributes: attributes)
        joinGameAttributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key,
                                              value: CGFloat(10.0),
                                              range: NSRange(location: 0, length: joinGameTitle.count-1))
        joinGameButton.setAttributedTitle(joinGameAttributedString, for: .normal)
        joinGameButton.titleLabel?.font = buttonsFont
    }
    
    func initConstraints() {
        backgroundImage.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        gameTitleImageView.snp.makeConstraints { make in
            make.topMargin.equalTo(1.2 * gridHeight)
            make.centerX.equalToSuperview()
        }
        playButtonStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        startGameButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
        }
        joinGameButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
        }
        subMenuButtonStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(3 * gridHeight)
        }
        tutorialButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
        }
        settingsButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
        }
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
    
    func onTapStartGameButton(_ target: Any?, _ handler: Selector) {
        self.startGameButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    func onTapJoinGameButton(_ target: Any?, _ handler: Selector) {
        self.joinGameButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    func onTapSettingsButton(_ target: Any?, _ handler: Selector) {
        self.settingsButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    func onTapTutorialButton(_ target: Any?, _ handler: Selector) {
        self.tutorialButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    
}
