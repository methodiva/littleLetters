protocol CameraViewProtocol: FeatureViewProtocol {
    func startCameraSession()
    func stopCameraSession()
    func captureImage(_ imageCallBack: ((_ image: CameraImageProtocol) -> Void)?)
    func addNode(_ node: CameraViewNodeProtocol)
}

protocol CameraImageProtocol {}

protocol CameraLogicProtocol: FeatureLogicProtocol {
    func addNode(_ node: CameraViewNodeProtocol)
    func captureImage(_ imageCallBack: ((_ image: CameraImageProtocol) -> Void)?)
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
        log.verbose("Starting camera session")
        view?.startCameraSession()
    }

    func willDisappear(_ animated: Bool) {
        log.verbose("Stopping camera session")
        view?.stopCameraSession()
    }
    
    func addNode(_ node: CameraViewNodeProtocol) {
        guard let cameraView = self.view else {
            log.error("Camera view not initialized")
            return
        }
        cameraView.addNode(node)
    }
    
    func captureImage(_ imageCaptureCallback: ((CameraImageProtocol) -> Void)?) {
        self.view?.captureImage(imageCaptureCallback)
    }
}
