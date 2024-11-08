import UIKit
import MapKit

// MARK: - Item
class MapResultCard: UICollectionViewCell
{
    // MARK: - Item - Subviews
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
        view.backgroundColor = .tertiarySystemBackground
        view.clipsToBounds = false
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 5
        return view
    }()
    
    // MARK: - Setup
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
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            icon.centerYAnchor.constraint(equalTo: title.centerYAnchor),
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
        title.text = annotation.title ?? "Unknown Location"
        body.text = annotation.subtitle ?? "No description available"
        
        if let category = annotation.mapCategory
        {
            icon.image = UIImage(systemName: category.filledIcon)
            icon.tintColor = annotation.color
        }
        else
        {
            icon.image = UIImage(systemName: "mappin")
            icon.tintColor = .label
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - HStack
class MapResultPicker: UIViewController
{
    private var annotations: [MapAnnotation] = []
    
    private lazy var container: UICollectionView =
    {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 140)
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.register(MapResultCard.self, forCellWithReuseIdentifier: "POICardCell")
        return collection
    }()
    
//    private let pageControl: UIPageControl =
//    {
//        let pageControl = UIPageControl()
//        pageControl.translatesAutoresizingMaskIntoConstraints = false
//        pageControl.currentPageIndicatorTintColor = .label
//        pageControl.pageIndicatorTintColor = .tertiaryLabel
//        return pageControl
//    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews()
    {
//        view.addSubview(pageControl)
        view.addSubview(container)
        
        NSLayoutConstraint.activate([
//            pageControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 2),
//            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            pageControl.heightAnchor.constraint(equalToConstant: 14),
            
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.topAnchor.constraint(equalTo: view.topAnchor, constant: 3),
            container.heightAnchor.constraint(equalToConstant: 140)
        ])
    }
    
    func updateResultPicker()
    {
        guard let root = parent?.parent as? MapView else { return }
        
        let visibleAnnotations = root.map.annotations(in: root.map.visibleMapRect).compactMap { $0 as? MapAnnotation }

        self.annotations = visibleAnnotations
        
        container.reloadData()

        if self.annotations.isEmpty
        {
            root.sheet.animateSheet(to: .hidden)
//            if root.sheet.sheetState != .minimized
//            {
//                root.sheet.animateSheet(to: .minimized)
//            }
        }
        else
        {
            if root.sheet.sheetState == .hidden
            {
                root.sheet.animateSheet(to: .minimized)
            }
        }
    }
}

// MARK: - Collection View Delegate & DataSource
extension MapResultPicker: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return annotations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "POICardCell", for: indexPath) as! MapResultCard
        cell.configure(with: annotations[indexPath.item])
        return cell
    }
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
//    {
//        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
//        pageControl.currentPage = page
//    }
}

#Preview
{
    MapView()
}
