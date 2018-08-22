import UIKit

class JoinGameScreenView: UIView, JoinGameScreenViewProtocol {
    
    weak var featureLogic: JoinGameScreenLogicProtocol!
    
    convenience init(_ featureLogic: FeatureLogicProtocol) {
        self.init(frame: UIScreen.main.bounds)
        guard let logic = featureLogic as? JoinGameScreenLogicProtocol else {
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
    let joinGameButton = UIButton()
    let keyTextField = UITextField()
    let loadingActivityIndicatior = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorView.Style.whiteLarge)
    let errorMessageLabel = UILabel()
    
    let enterCodeLabel = UILabel()
    let buttonStack = UIStackView()
    let textFieldBackground = UIImageView(image: UIImage(named: "joinGameTextFieldBackground"))
    
    let gameJoinKeyLength = 4
    
    // Loading font
    let titleFont = UIFont(name: "Montserrat-Bold", size: 22)
    let buttonsFont = UIFont(name: "Montserrat-Bold", size: 25)
    let enterCodeFont = UIFont(name: "Montserrat-Regular", size: 28)
    let keyFont = UIFont(name: "Montserrat-Bold", size: 32)
    let errorMessageFont = UIFont(name: "Montserrat-Regular", size: 15)
    
    func initUI() {
        screenTitleLabel.text = "JOIN GAME"
        screenTitleLabel.textAlignment = .center
        screenTitleLabel.font = titleFont
        screenTitleLabel.textColor = appColors.white
        
        initTextField()
        initShareKeyButton()
        initErrorMessageUI()
        
        buttonStack.addArrangedSubview(textFieldBackground)
        buttonStack.addArrangedSubview(joinGameButton)
        buttonStack.axis = .vertical
        buttonStack.spacing = gridHeight * 2.5
        buttonStack.alignment = .center
        
        loadingActivityIndicatior.isHidden = true
        
        self.addSubview(backgroundImage)
        self.addSubview(backButton)
        self.addSubview(screenTitleLabel)
        self.addSubview(loadingActivityIndicatior)
        self.addSubview(errorMessageLabel)
        
        self.addSubview(buttonStack)
        self.addSubview(enterCodeLabel)
        self.addSubview(keyTextField)
        addTapGesture()
        self.hide{}
    }
    
    func initShareKeyButton() {
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = appColors.white
        joinGameButton.setBackgroundImage(UIImage(named: "pinkSmallButton"), for: .normal)
        let shareKeyTitle = "Join"
        let shareKeyAttributedString = NSMutableAttributedString(string: shareKeyTitle, attributes: attributes)
        shareKeyAttributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key,
                                              value: CGFloat(5.0),
                                              range: NSRange(location: 0, length: shareKeyTitle.count-1))
        joinGameButton.setAttributedTitle(shareKeyAttributedString, for: .normal)
        joinGameButton.titleLabel?.font = buttonsFont
        joinGameButton.isEnabled = false
    }
    
    func addTapGesture() {
        let keyboardResignGesture = UITapGestureRecognizer(target: self, action: #selector(keyboardDismiss))
        self.addGestureRecognizer(keyboardResignGesture)
    }
    
    func initErrorMessageUI() {
        errorMessageLabel.font = errorMessageFont
        errorMessageLabel.textColor = appColors.white
    }
    
    @objc
    func keyboardDismiss() {
        keyTextField.resignFirstResponder()
    }
    
    func initTextField() {
        enterCodeLabel.text = "Enter Code"
        enterCodeLabel.font = enterCodeFont
        enterCodeLabel.textColor = appColors.white
        
        keyTextField.delegate = self
        keyTextField.font = keyFont
        keyTextField.textColor = appColors.darkPurple
        keyTextField.tintColor = appColors.lightPurple
        keyTextField.keyboardType = .asciiCapableNumberPad
        keyTextField.textAlignment = .center
        
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
        enterCodeLabel.snp.makeConstraints { make in
            make.topMargin.equalTo(8.1 * gridHeight )
            make.centerX.equalToSuperview()
        }
        keyTextField.snp.makeConstraints { make in
            make.topMargin.equalTo(10.5 * gridHeight)
            make.width.equalTo(gridWidth * 4)
            make.centerX.equalToSuperview()
        }
        buttonStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        loadingActivityIndicatior.snp.makeConstraints { (make) in
            make.top.equalTo(buttonStack.snp.bottom).offset(gridHeight)
            make.centerX.equalToSuperview()
        }
        errorMessageLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(screenTitleLabel.snp.bottom).offset(gridHeight * 4)
        }
    }
    
    func onTapBackButton(_ target: Any?, _ handler: Selector) {
        self.backButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    func onTapJoinGameButton(_ target: Any?, _ handler: Selector) {
        self.joinGameButton.addTarget(target, action: handler, for: .touchUpInside)
    }
    
    func hide(_ onHidden: (() -> Void)?) {
        self.keyboardDismiss()
        self.isUserInteractionEnabled = false
        self.alpha = 0
        onHidden?()
    }
    
    func show(_ onShowing: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.keyTextField.text = ""
        self.alpha = 1
        onShowing?()
    }
    
    func showWaitingForGame() {
        loadingActivityIndicatior.startAnimating()
        joinGameButton.isEnabled = false
    }
    
    func stopWaitingForGame() {
        loadingActivityIndicatior.stopAnimating()
        joinGameButton.isEnabled = true
    }
    
    func showFail(with message: String) {
        errorMessageLabel.text = message
    }
    
    func isKeyValid(key: Int?) -> Bool {
        guard let key = key else {
            return false
        }
        if key > 999 && key < 10000 {
            return true
        }
        return false
    }
    
    func getGameKey() -> Int? {
        if let text = self.keyTextField.text {
            return Int(text)
        }
        return nil
    }
}

extension JoinGameScreenView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length >= gameJoinKeyLength {
            joinGameButton.isEnabled = true
        } else {
            joinGameButton.isEnabled = false
        }
        return newString.length <= gameJoinKeyLength
    }
}
