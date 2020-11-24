//
//  SceneDelegate.swift
//  Cats
//
//  Created by Daniela Postigo on 11/21/20.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    let navigationController = UINavigationController(rootViewController: ListTableViewController())
    navigationController.navigationBar.isTranslucent = false
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()

    guard let shortcutItem = connectionOptions.shortcutItem else { return }
    self.windowScene(windowScene, performActionFor: shortcutItem, completionHandler: { _ in })
  }

  func sceneDidDisconnect(_ scene: UIScene) { }

  func sceneDidBecomeActive(_ scene: UIScene) { }

  func sceneWillResignActive(_ scene: UIScene) { }

  func sceneWillEnterForeground(_ scene: UIScene) { }

  func sceneDidEnterBackground(_ scene: UIScene) { }

  func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> ()) {
    let vc = UINavigationController(rootViewController: RandomViewController())
    vc.view.backgroundColor = .white
    self.window?.rootViewController?.present(vc, animated: true)
  }
}

