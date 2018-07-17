import ARKit
import SceneKit

protocol CameraViewNodeProtocol {
    var name: String? { get set }
    var transform: Transform { get set }
    var worldTransform: Transform { get }
    var eulerAngles: Vector { get set}
    func addChildNode(_ node: CameraViewNodeProtocol)
    func removeFromParentNode()
}

extension SCNNode: CameraViewNodeProtocol {
    func addChildNode(_ node: CameraViewNodeProtocol) {
        guard let scnNode = node as? SCNNode else {
            log.error("Node needs to be SCNNode")
            return
        }
        self.addChildNode(scnNode)
    }
}
class ARCameraView: ARSCNView, ARSCNViewDelegate, CameraTypeProtocol {
  
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        self.delegate = self as ARSCNViewDelegate
        initUI()
    }
    
    func initUI() {
        self.autoenablesDefaultLighting = true
        self.scene = SCNScene()
    }
    
    func startCameraSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        self.session.run(configuration)
        log.verbose("ARSession started")
    }
    
    func stopCameraSession() {
        log.verbose("ARSession paused")
        self.session.pause()
    }
    
    func getImage() -> CameraImageViewProtocol {
        log.verbose("Image captured from ARCamera")
        return self.snapshot()
    }
    
    func addNode(_ node: CameraViewNodeProtocol) {
        guard let sceneNode = node as? SCNNode else {
            log.error("Invalid node provided to camera view")
            return
        }
        scene.rootNode.addChildNode(sceneNode)
        log.verbose("Node added", sceneNode.debugDescription)
    }
}
