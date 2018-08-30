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
    
    // UI Elements
    let screenTitleLabel = UILabel()
    let backButton = BackButton()
    
    let backgroundImage = UIImageView(image: UIImage(named: "BackgroundImage"))
    let playButtonStack = UIStackView()
    let changeNameButton = UIButton()
    let rateUsButton = UIButton()
    
    let buttonsFont = UIFont(name: "Montserrat-Bold", size: 30)
    let titleFont = UIFont(name: "Montserrat-Bold", size: 22)
    
    // UIimages for buttons
    let changeGameImage = UIImage(named: "pinkButton")
    let rateUsImage = UIImage(named: "purpleButton")
    
    func initUI() {
        screenTitleLabel.text = "SETTINGS"
        screenTitleLabel.textAlignment = .center
        screenTitleLabel.font = titleFont
        screenTitleLabel.textColor = appColors.white
        
        initUIConfiguration()
        self.addSubview(backgroundImage)
        self.addSubview(backButton)
        self.addSubview(screenTitleLabel)
        self.addSubview(playButtonStack)
        self.hide{}
    }
    
    func initUIConfiguration() {
        playButtonStack.axis = .vertical
        playButtonStack.spacing = gridHeight
        playButtonStack.addArrangedSubview(changeNameButton)
        playButtonStack.addArrangedSubview(rateUsButton)
        playButtonStack.alignment = .center
        
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = appColors.white
        
        let changeNameTitle = "Username"
        changeNameButton.setBackgroundImage(changeGameImage, for: .normal)
        let changeNameAttributedString = NSMutableAttributedString(string: changeNameTitle, attributes: attributes)
        changeNameAttributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key,
                                               value: CGFloat(5.0),
                                               range: NSRange(location: 0, length: changeNameTitle.count-1))
        changeNameButton.setAttributedTitle(changeNameAttributedString, for: .normal)
        changeNameButton.titleLabel?.font = buttonsFont
        
        let rateUsTitle = "Rate Us"
        rateUsButton.setBackgroundImage(rateUsImage, for: .normal)
        let rateUsAttributedString = NSMutableAttributedString(string: rateUsTitle, attributes: attributes)
        rateUsAttributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key,
                                              value: CGFloat(5.0),
                                              range: NSRange(location: 0, length: rateUsTitle.count-1))
        rateUsButton.setAttributedTitle(rateUsAttributedString, for: .normal)
        rateUsButton.titleLabel?.font = buttonsFont
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
        playButtonStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        changeNameButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
        }
        rateUsButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
        }
    }
    
    func onTapBackButton(_ target: Any?, _ handler: Selector) {
        self.backButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    func onTapChangeNameButton(_ target: Any?, _ handler: Selector) {
        self.changeNameButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    func onTapRateUsButton() {
        self.rateUsButton.addTarget(self, action: #selector(openAppstoreLinkToRate), for: .touchUpInside)
    }
    
    @objc
    func openAppstoreLinkToRate() {
        UIApplication.shared.open(URL(string : "itms-apps://itunes.apple.com/app/id\(appId)")!)
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
