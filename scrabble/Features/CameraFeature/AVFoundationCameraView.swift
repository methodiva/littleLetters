import UIKit
import Foundation
import AVKit

class ARFoundationCameraView: UIView, CameraTypeProtocol, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        initUI()
    }
    
    func initUI() {
    }
    
    func getImage() -> CameraImageViewProtocol {
        return UIImage()
    }
    
    func startCameraSession() {
        
    }
    
    func stopCameraSession() {
        
    }
    
    
}
