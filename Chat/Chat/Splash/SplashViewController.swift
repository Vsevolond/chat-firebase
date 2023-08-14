import UIKit


class SplashViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    var logoIsHidden: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textLabel.text = "IOS Chat GPT"
        textLabel.textAlignment = .center
        
        logoImageView.isHidden = logoIsHidden
    }
}
