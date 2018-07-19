import Foundation

protocol HomeScreenViewProtocol: FeatureViewProtocol {
    func onTapStartGameButton(_ target: Any?, _ handler: Selector)
    func onTapLoadGameButton(_ target: Any?, _ handler: Selector)
    func onTapSettingsButton(_ target: Any?, _ handler: Selector)
    func onTapTutorialButton(_ target: Any?, _ handler: Selector)
}

protocol HomeScreenLogicProtocol: FeatureLogicProtocol {
    func show(_ onShowing: (() -> Void)?)
}

class HomeScreenLogic: HomeScreenLogicProtocol {
    private weak var view: HomeScreenViewProtocol?
    
    private weak var startGameScreenLogic: StartGameScreenLogicProtocol?
    private weak var loadGameScreenLogic: LoadGameScreenLogicProtocol?
    private weak var tutorialGameScreenLogic: TutorialScreenLogicProtocol?
    private weak var settingsGameScreenLogic: SettingsScreenLogicProtocol?
    
    // MARK: - FeatureProtocol conformance
    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
        guard let uiView = view as? HomeScreenViewProtocol else {
            log.error("Unknown view type")
            return
        }
        guard let deps = dependencies,
            let startGameScreenLogic = deps[.StartGameScreen] as? StartGameScreenLogicProtocol,
            let loadGameScreenLogic = deps[.LoadGameScreen] as? LoadGameScreenLogicProtocol,
            let tutorialGameScreenLogic = deps[.TutorialScreen] as? TutorialScreenLogicProtocol,
            let settingsGameScreenLogic = deps[.SettingsScreen] as? SettingsScreenLogicProtocol else {
                log.error("Dependency unfulfilled")
                return
        }
        self.view = uiView
        self.startGameScreenLogic = startGameScreenLogic
        self.loadGameScreenLogic = loadGameScreenLogic
        self.tutorialGameScreenLogic = tutorialGameScreenLogic
        self.settingsGameScreenLogic = settingsGameScreenLogic
        
        linkFunctionsWithButtons()
    }
    
    func linkFunctionsWithButtons() {
        self.view?.onTapStartGameButton(self, #selector(showStartGameScreen))
        self.view?.onTapLoadGameButton(self, #selector(showLoadGameScreen))
        self.view?.onTapSettingsButton(self, #selector(showSettingsScreen))
        self.view?.onTapTutorialButton(self, #selector(showTutorialScreen))
    }
    
    @objc
    func showStartGameScreen() {
        log.verbose("Showing start game screen")
        self.view?.hide{
            self.startGameScreenLogic?.show()
        }
    }
    
    func show(_ onShowing: (() -> Void)?) {
        self.view?.show{
            onShowing?()
        }
    }
    
    @objc
    func showLoadGameScreen() {
        log.verbose("Showing load game screen")
        self.view?.hide{
            self.loadGameScreenLogic?.show()
        }
    }
    
    @objc
    func showSettingsScreen() {
        log.verbose("Showing settings screen")
        self.view?.hide{
            self.settingsGameScreenLogic?.show()
        }
    }
    
    @objc
    func showTutorialScreen() {
        log.verbose("Showing tutorial screen")
        self.view?.hide{
            self.tutorialGameScreenLogic?.show()
        }
    }
}
