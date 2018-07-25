import Foundation

protocol FiddleScreenLogicProtocol: FeatureLogicProtocol {
    func showMenu()
    func hideMenu()
}

protocol FiddleScreenViewProtocol: FeatureViewProtocol {
}

class FiddleScreenLogic: FiddleScreenLogicProtocol {
    private weak var view: FiddleScreenViewProtocol?

    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
        guard let uiView = view as? FiddleScreenViewProtocol else {
            log.error("Unknown view type")
            return
        }
       self.view = uiView
    }
    
    func showMenu() {
        self.view?.show {}
    }
    
    func hideMenu() {
        self.view?.hide{}
    }
}
