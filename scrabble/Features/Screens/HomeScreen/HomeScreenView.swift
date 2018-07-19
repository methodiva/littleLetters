import UIKit
import SnapKit

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
    
    let gameTitleLabel = UILabel()
    let startGameButton = UIButton()
    let loadGameButton = UIButton()
    let tutorialButton = UIButton()
    let settingsButton = UIButton()
    
    func initUI() {
        self.backgroundColor = .white
        gameTitleLabel.text = "littleLetters"
        gameTitleLabel.textAlignment = .center
        
        startGameButton.backgroundColor = .red
        loadGameButton.backgroundColor = .blue
        tutorialButton.backgroundColor = .green
        settingsButton.backgroundColor = .yellow
        
        startGameButton.titleLabel?.text = "Start Button"
        loadGameButton.titleLabel?.text = "Load Button"
        tutorialButton.titleLabel?.text = "Tutorial Button"
        settingsButton.titleLabel?.text = "Settings Button"
        
        startGameButton.titleLabel?.textColor = .black
        loadGameButton.titleLabel?.textColor = .black
        tutorialButton.titleLabel?.textColor = .black
        settingsButton.titleLabel?.textColor = .black
        
        self.addSubview(gameTitleLabel)
        self.addSubview(startGameButton)
        self.addSubview(loadGameButton)
        self.addSubview(tutorialButton)
        self.addSubview(settingsButton)
        
     }
    
    func initConstraints() {
        gameTitleLabel.snp.makeConstraints { make in
            make.topMargin.equalTo(80)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        startGameButton.snp.makeConstraints { make in
            make.topMargin.equalTo(200)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        loadGameButton.snp.makeConstraints { make in
            make.topMargin.equalTo(300)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        tutorialButton.snp.makeConstraints { make in
            make.topMargin.equalTo(400)
            make.centerX.equalToSuperview().inset(-50)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        settingsButton.snp.makeConstraints { make in
            make.topMargin.equalTo(400)
            make.centerX.equalToSuperview().inset(50)
            make.width.equalTo(50)
            make.height.equalTo(50)
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
    }
    
    func onTapStartGameButton(_ target: Any?, _ handler: Selector) {
        self.startGameButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    func onTapLoadGameButton(_ target: Any?, _ handler: Selector) {
        self.loadGameButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    func onTapSettingsButton(_ target: Any?, _ handler: Selector) {
        self.tutorialButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    func onTapTutorialButton(_ target: Any?, _ handler: Selector) {
        self.settingsButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    
}
