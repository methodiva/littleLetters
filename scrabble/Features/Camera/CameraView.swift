import UIKit

extension UIImage: CameraImageProtocol {}

enum CameraType: String {
    case ARCamera = "ARCamera"
    case AVFoundationCamera = "AVFoundationCamera"
}

protocol CameraTypeProtocol {
    func startCameraSession()
    func stopCameraSession()
    func captureImage(_ imageCaptureCallback: ((CameraImageProtocol) -> Void)?)
}

class CameraView: UIView, CameraViewProtocol {
    weak var featureLogic: CameraLogicProtocol!
    let gameCameraType = CameraType.ARCamera
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
    
    private func initUI() {
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
        self.hide{}
    }
    
    func hide(_ onHidden: (() -> Void)?) {
        self.isUserInteractionEnabled = false
        self.alpha = 0
        onHidden?()
    }
    
    func show(_ onShowing: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.alpha = 1
        onShowing?()
    }
   
    func startCameraSession() {
        self.cameraView?.startCameraSession()
    }

    func stopCameraSession() {
        self.cameraView?.stopCameraSession()
    }
    
    func captureImage(_ imageCaptureCallback: ((CameraImageProtocol) -> Void)?) {
        self.cameraView?.captureImage(imageCaptureCallback)
    }

    func addNode(_ node: CameraViewNodeProtocol) {
        if let arCamera = cameraView as? ARCameraView {
            arCamera.addNode(node)
        } else {
            log.warning("Not Using ARCamera Currently")
        }
    }
}
