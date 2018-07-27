import UIKit

class BackButton: UIButton {
    convenience init() {
        self.init(frame: .zero)
        self.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        
    }
}
