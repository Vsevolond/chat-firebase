import UIKit


final class SidebarTableViewCell: UITableViewCell {
    private let iconImageView:  UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16)
        
        return label
    }()
    
    private let notifyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        iconImageView.image = nil
        nameLabel.text = nil
        notifyImageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupConstraints()
    }
    
    private func setup() {
        backgroundColor = UIColor(red: 32 / 255, green: 33 / 255, blue: 35 / 255, alpha: 1)
        addSubview(iconImageView)
        addSubview(notifyImageView)
        addSubview(nameLabel)
    }
    
    private func setupConstraints() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        notifyImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
            
            notifyImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            notifyImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            notifyImageView.widthAnchor.constraint(equalToConstant: 8),
            notifyImageView.heightAnchor.constraint(equalToConstant: 8),
            
            nameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: notifyImageView.leadingAnchor, constant: -5),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configure(with name: String, hasNotify: Bool) {
        iconImageView.image = UIImage(systemName: "bubble.left")
        nameLabel.text = name
        notifyImageView.image = UIImage(systemName: "circle.fill")
        notifyImageView.isHidden = !hasNotify
    }
}

