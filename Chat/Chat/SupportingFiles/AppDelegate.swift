//
//  AppDelegate.swift
//  Chat
//
//  Created by Vsevolod Donchenko on 14.08.2023.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var splashPresenter: SplashPresenterDescription? = SplashPresenter()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.overrideUserInterfaceStyle = .light
        window?.rootViewController = ContainerViewController()
        window?.makeKeyAndVisible()
        
        self.splashPresenter?.present()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.splashPresenter?.dismiss(completion: { [weak self] in
                self?.splashPresenter = nil
            })
        }
        
        return true
    }
}

