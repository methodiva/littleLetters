//import ARKit
//import SceneKit
//
protocol CameraViewNodeProtocol {
    var name: String? { get set }
    var transform: Transform { get set }
    var worldTransform: Transform { get }
    var eulerAngles: Vector { get set}
    func addChildNode(_ node: CameraViewNodeProtocol)
    func removeFromParentNode()
}

//extension SCNNode: CameraViewNodeProtocol {
//    func addChildNode(_ node: CameraViewNodeProtocol) {
//        guard let scnNode = node as? SCNNode else {
//            log.error("Node needs to be of data type SCNNode")
//            return
//        }
//        self.addChildNode(scnNode)
//    }
//}
//class ARCameraView: ARSCNView, ARSCNViewDelegate, CameraTypeProtocol {
//
//    convenience init() {
//        self.init(frame: UIScreen.main.bounds)
//        self.delegate = self as ARSCNViewDelegate
//        initScene()
//    }
//
//    private func initScene() {
//        self.autoenablesDefaultLighting = true
//        self.scene = SCNScene()
//    }
//
//    func startCameraSession() {
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.isLightEstimationEnabled = true
//        self.session.run(configuration)
//        log.verbose("AR Session started")
//    }
//
//    func stopCameraSession() {
//        log.verbose("AR Session paused")
//        self.session.pause()
//    }
//
//    func captureImage(_ imageCaptureCallback: ((CameraImageProtocol) -> Void)?) {
//        let image = self.snapshot()
//        log.verbose("Image captured from AR Camera")
//        imageCaptureCallback?(image)
//    }
//
//    func addNode(_ node: CameraViewNodeProtocol) {
//        guard let sceneNode = node as? SCNNode else {
//            log.error("Invalid node provided to camera view")
//            return
//        }
//        scene.rootNode.addChildNode(sceneNode)
//        log.verbose("Node added: \(String(describing: node))")
//    }
//}
