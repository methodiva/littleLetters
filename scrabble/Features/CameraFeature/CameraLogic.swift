protocol CameraViewNodeProtocol {
    var name: String? { get set }
    var transform: Transform { get set }
    var worldTransform: Transform { get }
    var eulerAngles: Vector { get set}
    func addChildNode(_ node: CameraViewNodeProtocol)
    func removeFromParentNode()
}

protocol CameraViewProtocol: FeatureViewProtocol {
    func startARSession()
    func stopARSession()
    var cameraPosition: Vector { get }
    var cameraTransform: Transform { get }
    func addNode(_ node: CameraViewNodeProtocol)
}

protocol CameraLogicProtocol: FeatureLogicProtocol {
    var cameraTransform: Transform? { get }
    func addNode(_ node: CameraViewNodeProtocol)
    func addRendererCallback(_ callback: @escaping () -> Void)
    func onRendererUpdate()
}

class CameraLogic: CameraLogicProtocol {

    private weak var view: CameraViewProtocol?
    var rendererCallbacks: [() -> Void] = []

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
        view?.startARSession()
    }

    func willDisappear(_ animated: Bool) {
        log.verbose("Stopping AR session")
        view?.stopARSession()
    }

    var cameraTransform: Transform? {
        get {
            return self.view?.cameraTransform
        }
    }

    func addNode(_ node: CameraViewNodeProtocol) {
        guard let cameraView = self.view else {
            log.error("Camera view not initialized")
            return
        }
        log.verbose("Adding Node: \(String(describing: node))")
        cameraView.addNode(node)
    }

    func addRendererCallback(_ callback: @escaping () -> Void) {
        self.rendererCallbacks.append(callback)
    }

    func onRendererUpdate() {
        for callback in self.rendererCallbacks {
            callback()
        }
    }
}
