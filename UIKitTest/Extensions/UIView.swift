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

    var viewController: UIViewController?
    {
        var nextResponder: UIResponder? = self
        
        while let responder = nextResponder
        {
            if let viewController = responder as? UIViewController
            {
                return viewController
            }
            
            nextResponder = responder.next
        }
        
        return nil
    }
}
