import UIKit


class UsernameScreenView: UIView, UsernameScreenViewProtocol {
    
    weak var featureLogic: UsernameScreenLogicProtocol!
    
    convenience init(_ featureLogic: FeatureLogicProtocol) {
        self.init(frame: UIScreen.main.bounds)
        guard let logic = featureLogic as? UsernameScreenLogicProtocol else {
            log.error("Invalid featureLogic provided")
            return
        }
        self.featureLogic = logic
        if UserDefaults.standard.string(forKey: "playerName") != nil {
            self.hide{}
        }
        initUI()
        initConstraints()
    }
    
    // UI elements
    
    let backgroundImage = UIImageView(image: UIImage(named: "BackgroundImage"))
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
        
        initTextField()
        initChangeNameButton()
        
        buttonStack.addArrangedSubview(textFieldBackground)
        buttonStack.addArrangedSubview(changeNameButton)
        buttonStack.axis = .vertical
        buttonStack.spacing = gridHeight * 2.5
        buttonStack.alignment = .center
        
        self.addSubview(backgroundImage)
        
        self.addSubview(buttonStack)
        self.addSubview(userName)
        self.addSubview(userNameTextField)
        addTapGesture()
        changeNameButton.isEnabled = false
    }
    
    func initChangeNameButton() {
        var attributes = [NSAttributedStringKey: AnyObject]()
        attributes[.foregroundColor] = appColors.white
        changeNameButton.setBackgroundImage(UIImage(named: "pinkSmallButton"), for: .normal)
        let doneTitle = "Let's Go"
        let doneAttributedString = NSMutableAttributedString(string: doneTitle, attributes: attributes)
        doneAttributedString.addAttribute(kCTKernAttributeName as NSAttributedStringKey,
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
        userNameTextField.autocorrectionType = .no
    }
    
    func initConstraints() {
        backgroundImage.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        userName.snp.makeConstraints { make in
            make.top.equalTo(textFieldBackground.snp.top).inset(15)
            make.centerX.equalToSuperview()
        }
        userNameTextField.snp.makeConstraints { make in
            make.bottom.equalTo(textFieldBackground.snp.bottom).inset(20)
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
        }
        buttonStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
    }
    
    func getCurrentName() -> String? {
        return userNameTextField.text
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

extension UsernameScreenView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.keyboardDismiss()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " || string == "+"{
            return false
        }
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        changeNameButton.isEnabled = newString.length >= 3
        return newString.length <= maxNameLength
    }
}

