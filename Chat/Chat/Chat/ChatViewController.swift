import UIKit

// MARK: - To Container
protocol ChatViewControllerDelegate: AnyObject {
    var messages: [ChatMessageViewObject] { get }
    func didTapSidebarButton()
    func didSendMessage(with text: String)
}

// MARK: - To ChatTableViewController
protocol ChatViewControllerTableProtocol: UIViewController {
    var delegate: ChatTableViewControllerDelegate? { get set }
    func addNewCell(to index: Int, type: ChatMessageViewObject.MessageType)
    func reloadCells()
    func scrollContentUp(offset: CGFloat)
    func scrollContentDown(to index: Int)
}

// MARK: - To ChatInputViewController
protocol ChatViewControllerInputProtocol: UIViewController {
    var delegate: ChatInputViewControllerDelegate? { get set }
    func disableSendButton()
    func enableSendButton()
}

// MARK: - ChatViewController
final class ChatViewController: UIViewController {
    weak var delegate: ChatViewControllerDelegate?
    
    private let chatTableViewController: ChatViewControllerTableProtocol = ChatTableViewController()
    private let chatInputViewController: ChatViewControllerInputProtocol = ChatInputViewController()
    
    private var keyboardHeight: CGFloat?
    private var isTextViewEditing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setup()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didTapSidebarButton))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(didTapSidebarButton))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupFrames()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupNavBar() {
        guard let navBar = navigationController?.navigationBar else {
            return
        }

        let navBarHeight: CGFloat = 44
        navigationController?.navigationBar.frame = .init(x: 0, y: view.safeAreaInsets.top - navBarHeight, width: view.frame.width, height: navBarHeight)
        navigationController?.navigationBar.barTintColor = .white

        let bottomBorder = CALayer()
        bottomBorder.frame = .init(x: 0, y: navBar.bounds.height - 1, width: navBar.bounds.width, height: 1)
        bottomBorder.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        navigationController?.navigationBar.layer.addSublayer(bottomBorder)

        let sidebarImage = UIImage(systemName: "list.bullet")
        let sidebarButton = UIBarButtonItem(image: sidebarImage, style: .plain, target: self, action: #selector(didTapSidebarButton))
        navigationItem.leftBarButtonItem = sidebarButton
        navigationController?.navigationBar.tintColor = .black

        navigationItem.title = "New Chat"
    }
    
    private func setup() {
        
        chatInputViewController.delegate = self
        addChild(chatInputViewController)
        view.addSubview(chatInputViewController.view)
        chatInputViewController.didMove(toParent: self)
        
        chatTableViewController.delegate = self
        addChild(chatTableViewController)
        view.addSubview(chatTableViewController.view)
        chatTableViewController.didMove(toParent: self)
    }
    
    private func setupFrames() {
        chatInputViewController.view.frame = .init(x: 0, y: view.frame.height - 80, width: view.frame.width, height: 80)
        
        chatTableViewController.view.frame = .init(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top - 80)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if isTextViewEditing {
            return
        } else {
            isTextViewEditing.toggle()
        }
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            fatalError("[DEBUG] Can't get keyboard size")
        }
        
        keyboardHeight = keyboardSize.height
        let offset = keyboardSize.height / 1.1
        
        chatTableViewController.scrollContentUp(offset: offset)
        chatTableViewController.view.frame.size.height -= offset // view ? tableview
        chatInputViewController.view.frame.origin.y -= offset
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if isTextViewEditing {
            isTextViewEditing.toggle()
        } else {
            return
        }
        
        guard let keyboardHeight else {
            fatalError("[DEBUG] There isn't keyboard height")
        }
        
        let offset = keyboardHeight / 1.1

        chatInputViewController.view.frame.origin.y += offset // ????????
        chatTableViewController.view.frame.size.height += offset // view ? tableview
    }

    @objc private func didTapSidebarButton() {
        delegate?.didTapSidebarButton()
    }
}

// MARK: - From ChatTableViewController
extension ChatViewController: ChatTableViewControllerDelegate {
    var messages: [ChatMessageViewObject] {
        return delegate?.messages ?? []
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - From ChatInputViewController
extension ChatViewController: ChatInputViewControllerDelegate {
    func didSendMessage(with text: String) {
        delegate?.didSendMessage(with: text)
    }
}

// MARK: - From Container
extension ChatViewController: ContainerChatProtocol {
    func scrollChatToMessage(at index: Int) {
        chatTableViewController.scrollContentDown(to: index)
    }
    
    func addNewChatMessage(at index: Int, type: ChatMessageViewObject.MessageType) {
        chatTableViewController.addNewCell(to: index, type: type)
    }
    
    func reload() {
        chatTableViewController.reloadCells()
    }
}

