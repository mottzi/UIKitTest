import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UIDefaultWindow
{
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)
    {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        self.window = createWindow(windowScene: windowScene, controller: HorizontalCategoryPicker())
    }
}

