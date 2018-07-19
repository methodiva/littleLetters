import UIKit

class GameScreenView: UIView, GameScreenViewProtocol {
    weak var featureLogic: GameScreenLogicProtocol!
    
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
    
    
    let screenTitleLabel = UILabel()
    let backButton = BackButton()
    let endGameButton = UIButton()
    
    func initUI() {
        screenTitleLabel.text = "Game Screen"
        screenTitleLabel.textAlignment = .center
        endGameButton.backgroundColor = .green
        self.addSubview(backButton)
        self.addSubview(screenTitleLabel)
        self.addSubview(endGameButton)
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
        endGameButton.snp.makeConstraints { make in
            make.topMargin.equalTo(300)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
    }
    
    func onTapBackButton(_ target: Any?, _ handler: Selector) {
        self.backButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    func onTapGameOverButton(_ target: Any?, _ handler: Selector) {
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
    }
}
