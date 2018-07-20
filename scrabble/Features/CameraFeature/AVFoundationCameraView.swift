import UIKit
import Foundation
import AVKit

class ARFoundationCameraView: UIView, CameraTypeProtocol {
    
    let captureSession = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    var capturedImageCallback: ((CameraImageProtocol) -> Void)?
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        initCaptureSession()
        initUI()
    }
    
    private func initCaptureSession() {
        captureSession.sessionPreset = .photo
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.addOutput(photoOutput)
    }
    
    private func initUI() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.layer.addSublayer(previewLayer)
        previewLayer.frame = self.frame
    }
    
    func captureImage(_ imageCaptureCallback: ((CameraImageProtocol) -> Void)?) {
        let photoSettings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
        capturedImageCallback = imageCaptureCallback
    }
    
    func startCameraSession() {
        captureSession.startRunning()
        log.verbose("AV Foundation camera session started")
        
    }
    
    func stopCameraSession() {
        captureSession.stopRunning()
        log.verbose("AV Foundation camera session stopped")
        
    }
}
extension ARFoundationCameraView: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let data = photo.fileDataRepresentation(),
            let image =  UIImage(data: data)  else {
                return
        }
        log.verbose("Image captured from AV Foundation camera")
        capturedImageCallback?(image)
        capturedImageCallback = nil
    }
}
