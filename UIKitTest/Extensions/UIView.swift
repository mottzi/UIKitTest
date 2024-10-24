import UIKit

extension UIView
{
    func debug(_ color: UIColor = .systemOrange)
    {
        self.layer.borderWidth = 1
        self.layer.borderColor = color.cgColor
    }
}
