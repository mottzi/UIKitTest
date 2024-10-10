import UIKit

protocol UIDefaultWindow
{
    var window: UIWindow? { get set }
    
    func createWindow(windowScene: UIWindowScene, controller: UIViewController) -> UIWindow
}

extension UIDefaultWindow
{
    func createWindow(windowScene: UIWindowScene, controller: UIViewController) -> UIWindow
    {
        let window = UIWindow(windowScene: windowScene)
        
        window.rootViewController = controller
        window.makeKeyAndVisible()
        
        return window
    }
}
