import UIKit

class ImageToStringCoverter {

    private let imageDataCountMax = 2097152
    private let widthPixels: CGFloat = 800
    
    func toString(for image: CameraImageProtocol, compressionFactor: Int) -> String? {
        guard let uiImage = image as? UIImage else {
            log.error("Image not in the correct format, need UIImage")
            return nil
        }
        var imagedata = uiImage.pngData()
        if (imagedata?.count > imageDataCountMax/compressionFactor) {
            let oldSize: CGSize = uiImage.size
            let calculatedWidthPixels = widthPixels/CGFloat(compressionFactor)
            let calculatedHeightPixels = oldSize.height / oldSize.width * calculatedWidthPixels
            
            let newSize: CGSize = CGSize(width: calculatedWidthPixels, height: calculatedHeightPixels)
            imagedata = resizeImage(newSize, image: uiImage)
        }
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    fileprivate func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = newImage!.pngData()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}

let imageConverter = ImageToStringCoverter()

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}


fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

