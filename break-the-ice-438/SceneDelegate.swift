//
//  SceneDelegate.swift
//  break-the-ice-438
//


import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
//        guard let _ = (scene as? UIWindowScene) else { return }
        self.setupWindow(with: scene)
        self.checkAuthentication()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    private func setupWindow(with scene: UIScene){
        guard let windowScene = (scene as? UIWindowScene) else {return}
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let window = UIWindow(windowScene: windowScene)
        
        window.rootViewController = storyboard.instantiateInitialViewController()
        self.window = window
        self.window?.makeKeyAndVisible()
    }
    
    public func checkAuthentication(){
        if Auth.auth().currentUser == nil {
            self.goToController(ofType: LoginViewController.self, with: "LoginViewController")
        }
        else{
            self.goToController(ofType: UITabBarController.self, with: "TabController")
            
        }
    }
    
    private func goToController<T: UIViewController>(ofType type: T.Type, with identifier: String){
        guard let window = self.window else { return }
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: identifier) as? T {
                UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = vc
                }, completion: nil)
            } else {
                print("ViewController with identifier \(identifier) could not be instantiated.")
            }
        }
    }

}
