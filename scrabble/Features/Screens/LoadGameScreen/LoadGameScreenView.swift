import UIKit

class LoadGameScreenView: UIView, LoadGameScreenViewProtocol {
    weak var featureLogic: LoadGameScreenLogicProtocol!
    
    convenience init(_ featureLogic: FeatureLogicProtocol) {
        self.init(frame: UIScreen.main.bounds)
        guard let logic = featureLogic as? LoadGameScreenLogicProtocol else {
            log.error("Invalid featureLogic provided")
            return
        }
        self.featureLogic = logic
        self.isUserInteractionEnabled = false
        initUI()
        initConstraints()
    }
    
    // UI elements
    
    let screenTitleLabel = UILabel()
    let backButton = BackButton()
    let playGameButton = UIButton()
    
    func initUI() {
        self.backgroundColor = .white
        screenTitleLabel.text = "Load Game"
        screenTitleLabel.textAlignment = .center
        playGameButton.titleLabel?.text = "Play Game"
        playGameButton.backgroundColor = .cyan
        self.addSubview(playGameButton)
        self.addSubview(backButton)
        self.addSubview(screenTitleLabel)
        self.hide{}
    }
    
    func initConstraints() {
        screenTitleLabel.snp.makeConstraints { make in
            make.topMargin.equalTo(80)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        backButton.snp.makeConstraints { make in
            make.topMargin.equalTo(30)
            make.leftMargin.equalTo(30)
        }
        playGameButton.snp.makeConstraints { make in
            make.topMargin.equalTo(450)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
    }
    
    func onTapBackButton(_ target: Any?, _ handler: Selector) {
        self.backButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    func onTapPlayGameButton(_ target: Any?, _ handler: Selector) {
        self.playGameButton.addTarget(target, action: handler, for: .touchUpInside)
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
