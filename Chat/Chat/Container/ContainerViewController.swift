import UIKit

enum SidebarState {
    case opened
    case closed
}

enum CurrentChat {
    case newChat
    case other(chat: ChatViewObject)
}

// MARK: - To ChatViewController
protocol ContainerChatProtocol: UIViewController {
    var delegate: ChatViewControllerDelegate? { get set }
    func reload()
    func addNewChatMessage(at index: Int, type: ChatMessageViewObject.MessageType)
    func scrollChatToMessage(at index: Int)
}

// MARK: - To SidebarViewController
protocol ContainerSidebarProtocol: UIViewController {
    var delegate: SidebarViewControllerDelegate? { get set }
    func reload()
    func updateChat(at index: Int)
}

// MARK: - To ContainerModel
protocol ContainerModelInput: AnyObject {
    func loadAllChats(completion: @escaping (Result<[ChatViewObject], Error>) -> Void)
    func loadAllChatMessages(for chatID: Int, completion: @escaping (Result<[ChatMessageViewObject], Error>) -> Void)
    func sendMessage(in chat: CurrentChat, with text: String)
    func saveMessage(for chatID: Int, message: ChatMessageViewObject)
}

// MARK: - ContainerViewController
final class ContainerViewController: UIViewController {
    private let chatViewController: ContainerChatProtocol = ChatViewController()
    private let sidebarViewController: ContainerSidebarProtocol = SidebarViewController()
    private var chatNavigationController: UINavigationController?
    private lazy var settingsViewController = SettingsViewController()
    private lazy var model: ContainerModelInput = ContainerModel(output: self)
    
    private var sidebarState: SidebarState = .closed
    private var currentChat: CurrentChat = .newChat
    var allChats: [ChatViewObject] = []
    var messages: [ChatMessageViewObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        sidebarViewController.delegate = self
        addChild(sidebarViewController)
        view.addSubview(sidebarViewController.view)
        sidebarViewController.didMove(toParent: self)
        
        chatViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: chatViewController)
        chatNavigationController = navigationController
        addChild(navigationController)
        view.addSubview(navigationController.view)
        navigationController.didMove(toParent: self)
    }
    
    private func toggleSidebar() {
        switch sidebarState {
            
        case .closed:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.chatNavigationController?.view.frame.origin.x = self.chatViewController.view.frame.width - 100
            } completion: { [weak self] done in
                if done {
                    self?.sidebarState = .opened
                }
            }

        case .opened:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.chatNavigationController?.view.frame.origin.x = 0
            } completion: { [weak self] done in
                if done {
                    self?.sidebarState = .closed
                }
            }
        }
    }
    
    private func loadAllChats() {
        model.loadAllChats { [weak self] result in
            switch result {
            case .failure(let error):
                print("[DEBUG] \(error.localizedDescription)")
            case .success(let chatViewObjects):
                self?.allChats = chatViewObjects
                self?.sidebarViewController.reload()
            }
        }
    }
    
    private func loadAllChatMessages(for chat: ChatViewObject) {
        model.loadAllChatMessages(for: chat.id) { [weak self] result in
            switch result {
            case .failure(let error):
                print("[DEBUG] \(error.localizedDescription)")
            case .success(let chatMessageViewObjects):
                self?.messages = chatMessageViewObjects
                self?.allChats[chat.id].countOfMessages = chatMessageViewObjects.count
                self?.chatViewController.reload()
                self?.chatViewController.scrollChatToMessage(at: chatMessageViewObjects.count - 1)
            }
        }
    }
    
    private func addNewChatMessage(in chat: CurrentChat, with text: String, type: ChatMessageViewObject.MessageType) {
        switch chat {
        case .newChat:
            return
        case .other(let chat):
            switch currentChat {
            case .newChat:
                return
            case .other(let currentChat):
                let index = allChats[chat.id].countOfMessages
                let chatMessageViewObject = ChatMessageViewObject(id: index, text: text, type: type)
                model.saveMessage(for: chat.id, message: chatMessageViewObject)
                allChats[chat.id].countOfMessages += 1
                
                if chat.id == currentChat.id {
                    messages.append(chatMessageViewObject)
                    chatViewController.addNewChatMessage(at: index, type: type)
                } else {
                    allChats[chat.id].hasUnreadMessages = true
                    sidebarViewController.updateChat(at: chat.id)
                }
            }
        }
    }
}

// MARK: - From ContainerModel
extension ContainerViewController: ContainerModelOutput {
    func didReceiveMessage(in chat: CurrentChat, with text: String) {
        addNewChatMessage(in: chat, with: text, type: .incoming)
    }
    
    func alertError(error: String) {
        print("[DEBUG] \(error)")
    }
}

// MARK: - From ChatViewController
extension ContainerViewController: ChatViewControllerDelegate {
    func didSendMessage(with text: String) {
        addNewChatMessage(in: currentChat, with: text, type: .outcoming)
        model.sendMessage(in: currentChat, with: text)
    }
    
    func didTapSidebarButton() {
        toggleSidebar()
    }
}

// MARK: - From SidebarViewController
extension ContainerViewController: SidebarViewControllerDelegate {
    func didLoadView() {
        loadAllChats()
    }
    
    func didAddNewChat() {
        currentChat = .newChat
        messages.removeAll()
        chatViewController.reload()
        toggleSidebar()
    }
    
    func didOpenSettings() {
        chatNavigationController?.pushViewController(settingsViewController, animated: true)
        toggleSidebar()
    }
    
    func didSelectChat(at index: Int) {
        let chat: ChatViewObject = allChats[index]
        
        currentChat = .other(chat: chat)
        loadAllChatMessages(for: chat)
        toggleSidebar()
        
        allChats[index].hasUnreadMessages = false
        sidebarViewController.updateChat(at: index)
    }
    
    func deleteChat(at index: Int) {
        print(#function)
    }
}

