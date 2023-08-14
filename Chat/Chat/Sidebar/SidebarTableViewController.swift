import UIKit

enum SidebarSection: String, CaseIterable {
    case allChats = "All chats"
    case savedChats = "Saved chats"
}

// MARK: - To SidebarViewController
protocol SidebarTableViewControllerDelegate: AnyObject {
    var allChats: [ChatViewObject] { get }
    func didSelectChat(at index: Int, section: SidebarSection)
    func deleteChat(at index: Int, section: SidebarSection)
}

// MARK: - SidebarTableViewController
final class SidebarTableViewController: UITableViewController {
    weak var delegate: SidebarTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        tableView.frame = view.frame
        tableView.register(SidebarTableViewCell.self, forCellReuseIdentifier: "SidebarTableViewCell")
        tableView.backgroundColor = UIColor(red: 32 / 255, green: 33 / 255, blue: 35 / 255, alpha: 1)
        tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SidebarSection.allCases[section] {
        case .allChats:
            return delegate?.allChats.count ?? 0
        case .savedChats:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SidebarTableViewCell", for: indexPath) as? SidebarTableViewCell else {
            return .init()
        }
        
        switch SidebarSection.allCases[indexPath.section] {
        case .allChats:
            guard let chat = delegate?.allChats[indexPath.row] else {
                return .init()
            }
            
            cell.configure(with: chat.name, hasNotify: chat.hasUnreadMessages)
        case .savedChats:
            return .init()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = SidebarSection.allCases[indexPath.section]
        delegate?.didSelectChat(at: indexPath.row, section: section)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return SidebarSection.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SidebarSection.allCases[section].rawValue
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else {
            return
        }
        
        headerView.textLabel?.textColor = .gray
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let section = SidebarSection.allCases[indexPath.section]
        let style: UIContextualAction.Style = (section == .allChats ? .destructive : .normal)
        
        let deleteAction = UIContextualAction(style: style, title: nil) { [weak self] _, _, completion in
            let alertController = UIAlertController(title: "Delete", message: "Are you sure?", preferredStyle: .alert)

            let yesAction = UIAlertAction(title: "YES", style: .default) { _ in
                self?.delegate?.deleteChat(at: indexPath.row, section: section)
            }
            let noAction = UIAlertAction(title: "NO", style: .destructive)

            alertController.addAction(yesAction)
            alertController.addAction(noAction)

            self?.present(alertController, animated: true)
        }
        deleteAction.image = UIImage(systemName: "trash")?.withTintColor(.white)
        
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        return swipeActionConfig
    }
}

// MARK: - From SidebarViewController
extension SidebarTableViewController: SidebarViewControllerProtocol {
    func reloadCells() {
        tableView.reloadData()
    }
    
    func addNewCell(at index: Int, in section: SidebarSection) {
        guard let indexOfSection = SidebarSection.allCases.firstIndex(of: section) else {
            return
        }
        
        let indexPath = IndexPath(row: index, section: indexOfSection)
        
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func deleteCell(at index: Int, in section: SidebarSection) {
        guard let indexOfSection = SidebarSection.allCases.firstIndex(of: section) else {
            return
        }
        
        let indexPath = IndexPath(row: index, section: indexOfSection)
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func updateCell(at index: Int, in section: SidebarSection) {
        guard let indexOfSection = SidebarSection.allCases.firstIndex(of: section) else {
            return
        }
        
        let indexPath = IndexPath(row: index, section: indexOfSection)
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

