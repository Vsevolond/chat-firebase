import UIKit

// MARK: - To Container
protocol SidebarViewControllerDelegate: AnyObject {
    var allChats: [ChatViewObject] { get }
    func didLoadView()
    func didAddNewChat()
    func didOpenSettings()
    func didSelectChat(at index: Int, section: SidebarSection)
    func deleteChat(at index: Int, section: SidebarSection)
}

// MARK: - To SidebarTableViewController
protocol SidebarViewControllerProtocol: UIViewController {
    var delegate: SidebarTableViewControllerDelegate? { get set }
    func reloadCells()
    func addNewCell(at index: Int, in section: SidebarSection)
    func deleteCell(at index: Int, in section: SidebarSection)
    func updateCell(at index: Int, in section: SidebarSection)
}

// MARK: - SidebarViewController
final class SidebarViewController: UIViewController {
    weak var delegate: SidebarViewControllerDelegate?
    
    private let sidebarTableViewController: SidebarViewControllerProtocol = SidebarTableViewController()
    private let addButton = UIButton()
    private let settingsButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate?.didLoadView()
        
        view.backgroundColor = UIColor(red: 32 / 255, green: 33 / 255, blue: 35 / 255, alpha: 1)
        
        configureButton(button: addButton, with: "New chat", imageName: "plus.square.dashed")
        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        view.addSubview(addButton)
        
        configureButton(button: settingsButton, with: "Settings", imageName: "gearshape")
        settingsButton.addTarget(self, action: #selector(didTapSettingsButton), for: .touchUpInside)
        view.addSubview(settingsButton)
        
        sidebarTableViewController.delegate = self
        addChild(sidebarTableViewController)
        view.addSubview(sidebarTableViewController.view)
        sidebarTableViewController.didMove(toParent: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        sidebarTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            addButton.widthAnchor.constraint(equalToConstant: 200),
            addButton.heightAnchor.constraint(equalToConstant: 32),
            
            settingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            settingsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            settingsButton.widthAnchor.constraint(equalToConstant: 200),
            settingsButton.heightAnchor.constraint(equalToConstant: 32),
            
            sidebarTableViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sidebarTableViewController.view.topAnchor.constraint(equalTo: addButton.bottomAnchor),
            sidebarTableViewController.view.bottomAnchor.constraint(equalTo: settingsButton.topAnchor),
            sidebarTableViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100)
        ])
    }
    
    private func configureButton(button: UIButton, with title: String, imageName: String) {
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .white
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
    }
    
    @objc private func didTapAddButton() {
        delegate?.didAddNewChat()
    }
    
    @objc private func didTapSettingsButton() {
        delegate?.didOpenSettings()
    }
}

// MARK: - From SidebarTableViewController
extension SidebarViewController: SidebarTableViewControllerDelegate {
    var allChats: [ChatViewObject] {
        delegate?.allChats ?? []
    }
    
    func didSelectChat(at index: Int, section: SidebarSection) {
        delegate?.didSelectChat(at: index, section: section)
    }
    
    func deleteChat(at index: Int, section: SidebarSection) {
        delegate?.deleteChat(at: index, section: section)
    }
}

// MARK: - From Container
extension SidebarViewController: ContainerSidebarProtocol {
    func reload() {
        sidebarTableViewController.reloadCells()
    }
    
    func updateChat(at index: Int, section: SidebarSection) {
        sidebarTableViewController.updateCell(at: index, in: section)
    }
}

