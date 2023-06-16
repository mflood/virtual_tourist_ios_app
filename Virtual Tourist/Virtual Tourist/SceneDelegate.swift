//
//  SceneDelegate.swift
//  Virtual Tourist
//
//  Created by Matthew Flood on 5/14/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let dataController = DataController(modelName: "Virtual_Tourist")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    
        dataController.load(completion: nil)
        
        // Inject Data Controller into tab controller views
        if let window = self.window,
           let tabController = window.rootViewController as? UITabBarController {
        
            
            if  let navigationController = (tabController.children[0] as? UINavigationController),
                let mapViewController = navigationController.topViewController as? MapViewController {
                mapViewController.dataController = dataController
                
            }
            if  let settingsViewController = (tabController.children[1] as? SettingsViewController) {
                settingsViewController.dataController = dataController
            }
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

