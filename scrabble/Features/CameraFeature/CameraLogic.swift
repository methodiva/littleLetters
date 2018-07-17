protocol CameraViewProtocol: FeatureViewProtocol {
    func startCameraSession()
    func stopCameraSession()
    func captureImage() -> CameraImageViewProtocol?
    func addNode(_ node: CameraViewNodeProtocol)
}

protocol CameraImageViewProtocol {}

protocol CameraLogicProtocol: FeatureLogicProtocol {
    func addNode(_ node: CameraViewNodeProtocol)
}

class CameraLogic: CameraLogicProtocol {

    private weak var view: CameraViewProtocol?
    
    // MARK: - FeatureProtocol conformance
    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
        guard let uiView = view as? CameraViewProtocol else {
            log.error("Unknown view type")
            return
        }
        self.view = uiView
    }

    func willAppear(_ animated: Bool) {
        log.verbose("Starting AR session")
        view?.startCameraSession()
    }

    func willDisappear(_ animated: Bool) {
        log.verbose("Stopping AR session")
        view?.stopCameraSession()
    }
    
    func addNode(_ node: CameraViewNodeProtocol) {
        guard let cameraView = self.view else {
            log.error("Camera view not initialized")
            return
        }
        log.verbose("Adding Node: \(String(describing: node))")
        cameraView.addNode(node)
    }
}
