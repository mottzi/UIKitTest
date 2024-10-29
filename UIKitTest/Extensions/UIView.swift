import UIKit

extension UIView
{
    func debug(_ color: UIColor = .systemOrange, _ width: CGFloat = 1)
    {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    
    func debug(_ width: CGFloat = 1)
    {
        self.debug(UIColor.systemOrange, width)
    }
}
