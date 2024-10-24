import UIKit

extension UIView
{
    static func bouncyAnimation(animations: @escaping () -> Void)
    {
        UIView.animate(withDuration: 0.7,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: [.curveEaseIn, .allowUserInteraction],
                       animations: animations)
    }
}
