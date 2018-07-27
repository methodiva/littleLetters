import UIKit

class SettingsScreenView: UIView, SettingsScreenViewProtocol {
    weak var featureLogic: SettingsScreenLogicProtocol!
    
    convenience init(_ featureLogic: FeatureLogicProtocol) {
        self.init(frame: UIScreen.main.bounds)
        guard let logic = featureLogic as? SettingsScreenLogicProtocol else {
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
    let changeNameButton = UIButton()
    let rateUsButton = UIButton()
    
    func initUI() {
        self.backgroundColor = .white
        initUIConfiguration()
        self.addSubview(backButton)
        self.addSubview(screenTitleLabel)
        self.addSubview(changeNameButton)
        self.addSubview(rateUsButton)
        self.hide{}
    }
    
    func initUIConfiguration() {
        screenTitleLabel.text = "Settings"
        screenTitleLabel.textAlignment = .center
        changeNameButton.setTitle("Change Name", for: .normal)
        changeNameButton.backgroundColor = .red
        rateUsButton.backgroundColor = .purple
        rateUsButton.setTitle("Rate Us", for: .normal)
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
        changeNameButton.snp.makeConstraints { make in
            make.topMargin.equalTo(280)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        rateUsButton.snp.makeConstraints { make in
            make.topMargin.equalTo(480)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
    }
    
    func onTapBackButton(_ target: Any?, _ handler: Selector) {
        self.backButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    func onTapChangeNameButton(_ target: Any?, _ handler: Selector) {
        self.changeNameButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    func onTapRateUsButton(_ target: Any?, _ handler: Selector) {
        self.rateUsButton.addTarget(target, action: handler, for: .touchUpInside)
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
