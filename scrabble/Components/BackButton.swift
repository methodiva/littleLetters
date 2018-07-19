import UIKit

class BackButton: UIButton {
    convenience init() {
        self.init(frame: .zero)
        self.backgroundColor = .blue
        
        self.setTitle("B", for: .normal)
        self.snp.makeConstraints{ make in
            make.width.height.equalTo(50)
        }
    }
}
