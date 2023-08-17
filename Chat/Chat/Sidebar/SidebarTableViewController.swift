import UIKit


// MARK: - To SidebarViewController
protocol SidebarTableViewControllerDelegate: AnyObject {
    var allChats: [ChatViewObject] { get }
    func didSelectChat(at index: Int)
    func deleteChat(at index: Int)
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
        return delegate?.allChats.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "SidebarTableViewCell", for: indexPath) as? SidebarTableViewCell,
            let chat = delegate?.allChats[indexPath.row]
        else {
            return .init()
        }
        
        cell.configure(with: chat.name, hasNotify: chat.hasUnreadMessages)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelectChat(at: indexPath.row)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "All chats"
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

        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            let alertController = UIAlertController(title: "Delete", message: "Are you sure?", preferredStyle: .alert)

            let yesAction = UIAlertAction(title: "YES", style: .default) { _ in
                self?.delegate?.deleteChat(at: indexPath.row)
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
    
    func addNewCell(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func deleteCell(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func updateCell(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

