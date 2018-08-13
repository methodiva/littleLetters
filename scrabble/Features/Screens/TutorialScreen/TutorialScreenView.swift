import UIKit

class TutorialScreenView: UIView, TutorialScreenViewProtocol {
    weak var featureLogic: TutorialScreenLogicProtocol!
    
    convenience init(_ featureLogic: FeatureLogicProtocol) {
        self.init(frame: UIScreen.main.bounds)
        guard let logic = featureLogic as? TutorialScreenLogicProtocol else {
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
    
    let cellReuseIdentifier = "cell"
    let tableView = UITableView()
    let scrollView = UIScrollView()
    
    let tutorialImages = [
        UIImage(named: "tutorialComicTemp"),
        UIImage(named: "tutorialComicTemp"),
        UIImage(named: "tutorialComicTemp"),
        UIImage(named: "tutorialComicTemp"),
        UIImage(named: "tutorialComicTemp"),
        UIImage(named: "tutorialComicTemp")
    ]
    
    
    let titleFont = UIFont(name: "Montserrat-Bold", size: 22)
    
    
    func initUI() {
        screenTitleLabel.text = "TUTORIAL"
        screenTitleLabel.textAlignment = .center
        screenTitleLabel.font = titleFont
        screenTitleLabel.textColor = appColors.white
        
        self.addSubview(backgroundImage)
        self.addSubview(backButton)
        self.addSubview(screenTitleLabel)
        self.addSubview(scrollView)
        //self.addSubview(tableView)
        addScrollView()
        self.hide{}
    }
    
    func addScrollView() {
        var i = 0
        for image in tutorialImages {
            let view = UIImageView(image: image)
            scrollView.addSubview(view)
            view.frame = CGRect(x: 0, y: i, width: 500, height: 400)
            i = i + 400
        }
        scrollView.isScrollEnabled = true
        scrollView.clipsToBounds = true
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
        scrollView.snp.makeConstraints { make in
            make.topMargin.equalTo(5.0 * gridHeight)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(2)
        }
//        tableView.snp.makeConstraints{ make in
//            make.centerX.equalToSuperview()
//            make.topMargin.equalTo(2 * gridHeight)
//            make.width.equalToSuperview().inset(2 * gridWidth)
//
//        }
    }
    
    func onTapBackButton(_ target: Any?, _ handler: Selector) {
        self.backButton.addTarget(target, action: handler, for: .touchUpInside)
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


extension TutorialScreenView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tutorialImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentImage = tutorialImages[indexPath.row]
        let cell : ImageCell = (tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ImageCell?)!
        cell.imageView?.image = currentImage
        return cell
    }
}

class ImageCell: UITableViewCell {
    
    let uiImage = UIImageView()
    
    func setupView() {
        self.addSubview(uiImage)
    }
    override init(style: UITableViewCellStyle , reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8 , height: 40).insetBy(dx: 20, dy: 10)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
