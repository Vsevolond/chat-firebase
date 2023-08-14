import UIKit


protocol SplashPresenterDescription {
    func present()
    func dismiss(completion: (() -> Void)?)
}

final class SplashPresenter: SplashPresenterDescription {
    
    private lazy var animator: SplashAnimatorDescription = SplashAnimator(foregroundSplashWindow: foregroundSplashWindow, backgroundSplashWindow: backgroundSplashWindow)
    
    private lazy var foregroundSplashWindow: UIWindow = {
        let splashViewController = splashViewController(logoIsHidden: false)
        
        return splashWindow(level: .normal + 1, rootViewController: splashViewController)
    }()
    
    private lazy var backgroundSplashWindow: UIWindow = {
        let splashViewController = splashViewController(logoIsHidden: true)
        
        return splashWindow(level: .normal - 1, rootViewController: splashViewController)
    }()
    
    private func splashViewController(logoIsHidden: Bool) -> SplashViewController? {
        let storyboard = UIStoryboard(name: "Splash", bundle: nil)
        let splashViewController = storyboard.instantiateViewController(withIdentifier: "SplashViewController") as? SplashViewController
        splashViewController?.logoIsHidden = logoIsHidden
        
        return splashViewController
    }
    
    private func splashWindow(level: UIWindow.Level, rootViewController: SplashViewController?) -> UIWindow {
        let splashWindow = UIWindow()
        splashWindow.windowLevel = level
        
        splashWindow.rootViewController = rootViewController
        
        return splashWindow
    }
    
    func present() {
        animator.animateAppearance()
    }
    
    func dismiss(completion: (() -> Void)?) {
        animator.animateDisappearance(completion: completion)
    }
}

