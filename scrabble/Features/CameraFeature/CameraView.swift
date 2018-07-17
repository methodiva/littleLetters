import UIKit

extension UIImage: CameraImageViewProtocol {}

enum CameraType: String {
    case ARCamera = "ARCamera"
    case AVFoundationCamera = "AVFoundationCamera"
}

protocol CameraTypeProtocol {
    func getImage() -> CameraImageViewProtocol
    func startCameraSession()
    func stopCameraSession()
}

class CameraView: UIView, CameraViewProtocol {
    weak var featureLogic: CameraLogicProtocol!
    let gameCameraType = CameraType.AVFoundationCamera
    var cameraView: CameraTypeProtocol?
   
    convenience init(_ featureLogic: FeatureLogicProtocol) {
        self.init(frame: UIScreen.main.bounds)
        guard let logic = featureLogic as? CameraLogicProtocol else {
            log.error("Invalid featureLogic provided")
            return
        }
        self.featureLogic = logic
        self.isUserInteractionEnabled = false
        initUI()
    }

    func initUI() {
        switch gameCameraType {
        case .ARCamera:
            cameraView = ARCameraView()
        case .AVFoundationCamera:
            cameraView = ARFoundationCameraView()
        }
        if let view = cameraView as? UIView {
            log.verbose("Added camera view of type: ", gameCameraType.rawValue)
            self.addSubview(view)
        }
    }
   
    func startCameraSession() {
        self.cameraView?.startCameraSession()
    }

    func stopCameraSession() {
        self.cameraView?.stopCameraSession()
    }
    
    func captureImage() -> CameraImageViewProtocol? {
        return self.cameraView?.getImage()
    }

    func addNode(_ node: CameraViewNodeProtocol) {
        if let arCamera = cameraView as? ARCameraView {
            arCamera.addNode(node)
        } else {
            log.warning("Not Using ARCamera Currently")
        }
    }
}
