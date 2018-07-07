import ARKit
import SceneKit

// just makes SCNNode satisfy CameraViewNodeProtocol, so that
// feature views can create SCNNodes and pass them around to
// camera feature as CameraViewNodeProtocol
extension SCNNode: CameraViewNodeProtocol {
    func addChildNode(_ node: CameraViewNodeProtocol) {
        guard let scnNode = node as? SCNNode else {
            log.error("Node needs to be SCNNode")
            return
        }
        self.addChildNode(scnNode)
    }
}


class CameraView: ARSCNView, ARSCNViewDelegate, CameraViewProtocol {

    weak var featureLogic: CameraLogicProtocol!
   
    convenience init(_ featureLogic: FeatureLogicProtocol) {
        self.init(frame: UIScreen.main.bounds)
        guard let logic = featureLogic as? CameraLogicProtocol else {
            log.error("Invalid featureLogic provided")
            return
        }
        self.featureLogic = logic
        self.isUserInteractionEnabled = false
        self.delegate = self as ARSCNViewDelegate
        initUI()
        initConstraints()
    }

    func initUI() {
        self.autoenablesDefaultLighting = true
        self.debugOptions = [
//            .showWorldOrigin,
//            .showFeaturePoints,
//            .showBoundingBoxes,
        ]
        self.scene = SCNScene()
    }

    func initConstraints() {
    }

    // MARK: - Property getters and setters
    var cameraPosition: Vector {
        get {
            if let cameraNode = self.pointOfView {
                return cameraNode.position
            }
            return Vector()
        }
        set(newCameraPosition) {
            self.pointOfView?.position = newCameraPosition
        }
    }

    var cameraTransform: Transform {
        get {
            if let cameraNode = self.pointOfView {
                return cameraNode.transform
            }
            return Transform()
        }
        set(newCameraTransform) {
            self.pointOfView?.transform = newCameraTransform
        }
    }

    // MARK: - ARSCNViewDelegate

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        self.featureLogic.onRendererUpdate()
    }

    // MARK: - CameraViewProtocol

    func startARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        self.session.run(configuration)
    }

    func stopARSession() {
        self.session.pause()
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    }

    func addNode(_ node: CameraViewNodeProtocol) {
        guard let sceneNode = node as? SCNNode else {
            log.error("Invalid scene node provided to camera view")
            return
        }
        scene.rootNode.addChildNode(sceneNode)
    }
}
