import UIKit


protocol SplashAnimatorDescription {
    func animateAppearance()
    func animateDisappearance(completion: (() -> Void)?)
}

final class SplashAnimator: SplashAnimatorDescription {
    
    private unowned let backgroundSplashWindow: UIWindow
    private unowned let backgroundSplashViewController: SplashViewController
    
    private unowned let foregroundSplashWindow: UIWindow
    private unowned let foregroundSplashViewController: SplashViewController
    
    
    init(foregroundSplashWindow: UIWindow, backgroundSplashWindow: UIWindow) {
        self.foregroundSplashWindow = foregroundSplashWindow
        self.backgroundSplashWindow = backgroundSplashWindow
        
        guard
            let foregroundSplashViewController = foregroundSplashWindow.rootViewController as? SplashViewController,
            let backgroundSplashViewController = backgroundSplashWindow.rootViewController as? SplashViewController
        else {
            fatalError("Splash Window does not have root view controller")
        }
        
        self.foregroundSplashViewController = foregroundSplashViewController
        self.backgroundSplashViewController = backgroundSplashViewController
    }
    
    
    func animateAppearance() {
        foregroundSplashWindow.isHidden = false
        
        foregroundSplashViewController.textLabel.isHidden = true
        foregroundSplashViewController.textLabel.alpha = 0
        foregroundSplashViewController.textLabel.transform = CGAffineTransform(translationX: 0, y: 30)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.foregroundSplashViewController.textLabel.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self?.foregroundSplashViewController.textLabel.alpha = 1
                self?.foregroundSplashViewController.textLabel.transform = .identity
                self?.foregroundSplashViewController.logoImageView.transform = CGAffineTransform(scaleX: 25 / 20, y: 25 / 20)
            }
        }
    }
    
    func animateDisappearance(completion: (() -> Void)?) {
        guard let window = UIApplication.shared.delegate?.window, let mainWindow = window else {
            fatalError("App delegate does not have window")
        }
        
        backgroundSplashWindow.isHidden = false
        UIView.animate(withDuration: 0.05) {
            self.foregroundSplashWindow.alpha = 0
        }
        
        let mask = CALayer()
        mask.frame = foregroundSplashViewController.logoImageView.frame
        mask.contents = UIImage(named: "logofill")?.cgImage
        mask.contentsGravity = .resizeAspect
        mainWindow.layer.mask = mask
        
        let maskImageView = UIImageView(image: UIImage(named: "logofill"))
        maskImageView.frame = mask.frame
        maskImageView.alpha = 0
        mainWindow.addSubview(maskImageView)
        mainWindow.bringSubviewToFront(maskImageView)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.foregroundSplashWindow.isHidden = true
            self.backgroundSplashWindow.isHidden = true
            completion?()
        }
        
        mainWindow.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        UIView.animate(withDuration: 0.6) {
            mainWindow.transform = .identity
        }
        
        [mask, maskImageView.layer].forEach { layer in
            addRotationAnimation(to: layer, duration: 0.6)
            addScalingAnimation(to: layer, duration: 0.6)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.backgroundSplashViewController.textLabel.alpha = 0
        } completion: { _ in
            maskImageView.removeFromSuperview()
        }
        
        CATransaction.commit()
    }
    
    private func addRotationAnimation(to layer: CALayer, duration: TimeInterval) {
        let animation = CABasicAnimation()
        
        let tangent = layer.position.y / layer.position.x
        let angle = atan(tangent)
        
        animation.beginTime = CACurrentMediaTime()
        animation.duration = duration
        animation.valueFunction = CAValueFunction(name: .rotateZ)
        animation.fromValue = 0
        animation.toValue = -angle
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        layer.add(animation, forKey: "transform")
    }
    
    private func addScalingAnimation(to layer: CALayer, duration: TimeInterval) {
        let animation = CAKeyframeAnimation(keyPath: "bounds")
        
        let width = layer.frame.width
        let height = layer.frame.height
        
        let ratio: CGFloat = 18 / 667
        let finalScale = ratio * UIScreen.main.bounds.height
        let scales: [CGFloat] = [1, 0.85, finalScale]
        
        animation.beginTime = CACurrentMediaTime()
        animation.duration = duration
        animation.values = scales.map { NSValue(cgRect: CGRect(x: 0, y: 0, width: width * $0, height: height * $0))}
        animation.timingFunctions = [CAMediaTimingFunction(name: .easeInEaseOut), CAMediaTimingFunction(name: .easeOut)]
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        layer.add(animation, forKey: "bounds")
        
    }
}

