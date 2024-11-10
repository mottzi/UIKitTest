import UIKit

class MapResultCard: UICollectionViewCell
{
    private let icon: UIImageView =
    {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()
    
    private let title: UILabel =
    {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(for: .headline, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    private let body: UILabel =
    {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(for: .subheadline, weight: .regular)
        label.numberOfLines = 3
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let container: UIView =
    {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .tertiarySystemBackground.withAlphaComponent(0.7)
        view.clipsToBounds = false
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 2
        view.layer.shadowOffset = .init(width: 0, height: -1)
        return view
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setupSubview()
        setupSubviews()
    }
    
    private func setupSubview()
    {
        contentView.addSubview(container)
        container.addSubview(icon)
        container.addSubview(title)
        container.addSubview(body)
    }
    
    private func setupSubviews()
    {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            icon.bottomAnchor.constraint(equalTo: title.bottomAnchor),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24),
            
            title.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            title.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            title.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            
            body.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            body.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            body.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            body.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with annotation: MapAnnotation)
    {
        title.text = annotation.title ?? "?"
        body.text = "Point source: \(annotation.source)"
        icon.image = UIImage(systemName: annotation.category.filledIcon)
        icon.tintColor = annotation.color
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
