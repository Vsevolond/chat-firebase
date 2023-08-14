import UIKit

// MARK: - To ChatViewController
protocol ChatInputViewControllerDelegate: AnyObject {
    func didSendMessage(with text: String)
}

// MARK: - ChatInputViewController
final class ChatInputViewController: UIViewController {
    weak var delegate: ChatInputViewControllerDelegate?
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.clipsToBounds = false
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.layer.shadowColor = UIColor.lightGray.cgColor
        textView.layer.shadowOffset = .zero
        textView.layer.shadowOpacity = 0.8
        textView.layer.shadowRadius = 2
        
        return textView
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.isEnabled = false
        
        let sendDisableImage = UIImage(systemName: "arrow.up.square.fill")?.withTintColor(.systemGray4, renderingMode: .alwaysOriginal)
        button.setImage(sendDisableImage, for: .disabled)
        button.setImage(sendDisableImage, for: .highlighted)
        
        let enableColor = UIColor(red: 91 / 255, green: 192 / 255, blue: 131 / 255, alpha: 1)
        let sendNormalImage = UIImage(systemName: "arrow.up.square.fill")?.withTintColor(enableColor, renderingMode: .alwaysOriginal)
        button.setImage(sendNormalImage, for: .normal)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.backgroundColor = .white
        
        textView.delegate = self
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        
        textView.frame = .init(x: 10, y: 10, width: view.bounds.width - 60, height: 30)
        view.addSubview(textView)
        
        sendButton.frame = .init(x: textView.frame.maxX + 5, y: 10, width: 40, height: 30)
        view.addSubview(sendButton)
    }
    
    @objc private func didTapSendButton() {
        guard let text = textView.text else {
            return
        }
        
        textView.text = ""
        sendButton.isEnabled = false
        
        delegate?.didSendMessage(with: text)
    }
}

// MARK: - From TextView
extension ChatInputViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text, !text.isEmpty else {
            sendButton.isEnabled = false
            return
        }
        
        sendButton.isEnabled = true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
}

// MARK: - From ChatViewController
extension ChatInputViewController: ChatViewControllerInputProtocol {
    func disableSendButton() {
        sendButton.isEnabled = false
    }
    
    func enableSendButton() {
        sendButton.isEnabled = true
    }
}

