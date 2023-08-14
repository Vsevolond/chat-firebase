import UIKit


final class ChatIncomingCell: UITableViewCell {
    private let messageView = UIView()
    private let messageLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        messageView.backgroundColor = nil
        messageLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        messageView.backgroundColor = .white
    }
    
    private func setup() {
        backgroundColor = .clear
        
        messageView.layer.cornerRadius = 8
        addSubview(messageView)
        
        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: 16)
        addSubview(messageLabel)
    }
    
    private func setupConstraints() {
        messageView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 32),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            
            messageView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -16),
            messageView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -16),
            messageView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16),
            messageView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16)
        ])
    }
    
    func configure(with text: String) {
        messageLabel.text = text
    }
}

