import UIKit

fileprivate let maxNameLength = 8

class ChangeNameScreenView: UIView, ChangeNameScreenViewProtocol {
    
    weak var featureLogic: ChangeNameScreenLogicProtocol!
    
    convenience init(_ featureLogic: FeatureLogicProtocol) {
        self.init(frame: UIScreen.main.bounds)
        guard let logic = featureLogic as? ChangeNameScreenLogicProtocol else {
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
    let changeNameButton = UIButton()
    let userNameTextField = UITextField()
    
    let userName = UILabel()
    let buttonStack = UIStackView()
    let textFieldBackground = UIImageView(image: UIImage(named: "joinGameTextFieldBackground"))
    
    // Loading font
    let titleFont = UIFont(name: "Montserrat-Bold", size: 22)
    let buttonsFont = UIFont(name: "Montserrat-Bold", size: 25)
    let enterNameFont = UIFont(name: "Montserrat-Regular", size: 28)
    let keyFont = UIFont(name: "Montserrat-Bold", size: 32)
    
    func initUI() {
        screenTitleLabel.text = "CHANGE NAME"
        screenTitleLabel.textAlignment = .center
        screenTitleLabel.font = titleFont
        screenTitleLabel.textColor = appColors.white
        
        initTextField()
        initChangeNameButton()
        
        buttonStack.addArrangedSubview(textFieldBackground)
        buttonStack.addArrangedSubview(changeNameButton)
        buttonStack.axis = .vertical
        buttonStack.spacing = gridHeight * 2.5
        buttonStack.alignment = .center
        
        self.addSubview(backgroundImage)
        self.addSubview(backButton)
        self.addSubview(screenTitleLabel)
        
        self.addSubview(buttonStack)
        self.addSubview(userName)
        self.addSubview(userNameTextField)
        addTapGesture()
        self.hide{}
    }
    
    func initChangeNameButton() {
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = appColors.white
        changeNameButton.setBackgroundImage(UIImage(named: "pinkSmallButton"), for: .normal)
        let doneTitle = "Done"
        let doneAttributedString = NSMutableAttributedString(string: doneTitle, attributes: attributes)
        doneAttributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key,
                                              value: CGFloat(5.0),
                                              range: NSRange(location: 0, length: doneTitle.count-1))
        changeNameButton.setAttributedTitle(doneAttributedString, for: .normal)
        changeNameButton.titleLabel?.font = buttonsFont
    }
    
    func addTapGesture() {
        let keyboardResignGesture = UITapGestureRecognizer(target: self, action: #selector(keyboardDismiss))
        self.addGestureRecognizer(keyboardResignGesture)
    }
    
    @objc
    func keyboardDismiss() {
        userNameTextField.resignFirstResponder()
    }
    
    func initTextField() {
        userName.text = "Username"
        userName.font = enterNameFont
        userName.textColor = appColors.white
        
        userNameTextField.delegate = self
        userNameTextField.font = keyFont
        userNameTextField.textAlignment = .center
        userNameTextField.textColor = appColors.darkPurple
        userNameTextField.tintColor = appColors.lightPurple
        userNameTextField.keyboardType = .namePhonePad
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
        userName.snp.makeConstraints { make in
            make.topMargin.equalTo(8.1 * gridHeight )
            make.centerX.equalToSuperview()
        }
        userNameTextField.snp.makeConstraints { make in
            make.topMargin.equalTo(10.5 * gridHeight )
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
        }
        buttonStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
    }
    
    func onTapBackButton(_ target: Any?, _ handler: Selector) {
        self.backButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    func onTapChangeNameButton(_ target: Any?, _ handler: Selector) {
        self.changeNameButton.addTarget(target, action: handler, for: .touchUpInside)
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

extension ChangeNameScreenView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.featureLogic.changeName()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " || string == "+"{
            return false
        }
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxNameLength
    }
}

