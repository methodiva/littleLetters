import Foundation

protocol HomeScreenViewProtocol: FeatureViewProtocol {
    func onTapStartGameButton(_ target: Any?, _ handler: Selector)
    func onTapJoinGameButton(_ target: Any?, _ handler: Selector)
    func onTapSettingsButton(_ target: Any?, _ handler: Selector)
    func onTapTutorialButton(_ target: Any?, _ handler: Selector)
}

protocol HomeScreenLogicProtocol: FeatureLogicProtocol {
    func show()
}

class HomeScreenLogic: HomeScreenLogicProtocol {
    private weak var view: HomeScreenViewProtocol?
    
    private weak var startGameScreenLogic: StartGameScreenLogicProtocol?
    private weak var joinGameScreenLogic: JoinGameScreenLogicProtocol?
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
            let joinGameScreenLogic = deps[.JoinGameScreen] as? JoinGameScreenLogicProtocol,
            let tutorialGameScreenLogic = deps[.TutorialScreen] as? TutorialScreenLogicProtocol,
            let settingsGameScreenLogic = deps[.SettingsScreen] as? SettingsScreenLogicProtocol else {
                log.error("Dependency unfulfilled")
                return
        }
        self.view = uiView
        self.startGameScreenLogic = startGameScreenLogic
        self.joinGameScreenLogic = joinGameScreenLogic
        self.tutorialGameScreenLogic = tutorialGameScreenLogic
        self.settingsGameScreenLogic = settingsGameScreenLogic
        
        linkFunctionsWithButtons()
    }
    
    func linkFunctionsWithButtons() {
        self.view?.onTapStartGameButton(self, #selector(showStartGameScreen))
        self.view?.onTapJoinGameButton(self, #selector(showJoinGameScreen))
        self.view?.onTapSettingsButton(self, #selector(showSettingsScreen))
        self.view?.onTapTutorialButton(self, #selector(showTutorialScreen))
    }
    
    func show() {
        log.verbose("Showing home screen")
        self.view?.show{
        }
    }
    
    
    @objc
    func showStartGameScreen() {
        log.verbose("Showing start game screen")
        self.view?.hide{
            self.startGameScreenLogic?.show()
        }
    }
    
    @objc
    func showJoinGameScreen() {
        log.verbose("Showing join game screen")
        self.view?.hide{
            self.joinGameScreenLogic?.show()
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
