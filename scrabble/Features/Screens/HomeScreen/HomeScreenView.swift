import UIKit
import SnapKit

let gridWidth = UIScreen.main.bounds.width/15
let gridHeight = UIScreen.main.bounds.height/27

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
        playButtonStack.axis = .vertical
        playButtonStack.spacing = gridHeight
        playButtonStack.addArrangedSubview(startGameButton)
        playButtonStack.addArrangedSubview(joinGameButton)
        
        subMenuButtonStack.axis = .horizontal
        subMenuButtonStack.spacing = gridWidth
        subMenuButtonStack.addArrangedSubview(settingsButton)
        subMenuButtonStack.addArrangedSubview(tutorialButton)
        
        startGameButton.setBackgroundImage(startGameImage, for: .normal)
        joinGameButton.setBackgroundImage(joinGameImage, for: .normal)
        tutorialButton.setImage(tutorialImage, for: .normal)
        settingsButton.setImage(settingsImage, for: .normal)
        
        startGameButton.setTitle("Start", for: .normal)
        joinGameButton.setTitle("Join", for: .normal)
    }
    
    func initConstraints() {
        backgroundImage.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        gameTitleImageView.snp.makeConstraints { make in
            make.topMargin.equalTo(2 * gridHeight)
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
