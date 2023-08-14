import UIKit

// MARK: - To ChatViewController
protocol ChatTableViewControllerDelegate: AnyObject {
    var messages: [ChatMessageViewObject] { get }
    func hideKeyboard()
}

// MARK: - ChatTableViewController
final class ChatTableViewController: UITableViewController {
    weak var delegate: ChatTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.frame = view.frame
        tableView.register(ChatOutcomingCell.self, forCellReuseIdentifier: "ChatOutcomingCell")
        tableView.register(ChatIncomingCell.self, forCellReuseIdentifier: "ChatIncomingCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .init(white: 0.95, alpha: 1)
        tableView.allowsSelection = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.messages.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let message = delegate?.messages[indexPath.row] else {
            return UITableViewCell()
        }
        
        switch message.type {
            
        case .outcoming:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatOutcomingCell", for: indexPath) as? ChatOutcomingCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: message.text)
            return cell
            
        case .incoming:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatIncomingCell", for: indexPath) as? ChatIncomingCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: message.text)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc private func hideKeyboard() {
        delegate?.hideKeyboard()
    }
}

// MARK: - From ChatViewController
extension ChatTableViewController: ChatViewControllerTableProtocol {
    func scrollContentDown(to index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
    
    func scrollContentUp(offset: CGFloat) {
        tableView.contentOffset.y += offset
    }

    func addNewCell(to index: Int, type: ChatMessageViewObject.MessageType) {
        let indexPath = IndexPath(row: index, section: 0)
        
        tableView.beginUpdates()
        switch type {
        case .incoming:
            tableView.insertRows(at: [indexPath], with: .left)
        case .outcoming:
            tableView.insertRows(at: [indexPath], with: .right)
        }
        tableView.endUpdates()
        
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func reloadCells() {
        tableView.reloadData()
    }
}

