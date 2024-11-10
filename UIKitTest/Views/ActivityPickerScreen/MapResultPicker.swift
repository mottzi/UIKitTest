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
        view.backgroundColor = .tertiarySystemBackground.withAlphaComponent(0.7)
        view.clipsToBounds = false
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 2
        view.layer.shadowOffset = .init(width: 0, height: -1)
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
        body.text = "Point source: \(annotation.source ?? "?")"
        
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
    var annotations: [MapAnnotation] = []
    
    private var currentAnnotationIds: Set<String> = []
    var lastSelectedAnnotation: MapAnnotation?

    lazy var collection: UICollectionView =
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews()
    {
        view.addSubview(collection)
        
        NSLayoutConstraint.activate([
            collection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collection.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            collection.heightAnchor.constraint(equalToConstant: 140)
        ])
    }
    
    // Reloads collection data after fetching currently visible POI.
    // * is called when category is toggled or map region did changed
    func update()
    {
        guard let root = parent?.parent as? MapView else { return }
        
        let newAnnotations = getVisibleAnnotations(map: root.map)
        let newAnnotationIds = Set(newAnnotations.compactMap { $0.identifier })
        
        if newAnnotationIds != currentAnnotationIds
        {
            let cardIndex = Int(collection.contentOffset.x / collection.bounds.width)
            var currentAnnotation: MapAnnotation?
            
            if (0..<annotations.count).contains(cardIndex)
            {
                currentAnnotation = annotations[cardIndex]
            }
            
            // Sort new annotations, but prioritize current annotation if it exists
            self.annotations = newAnnotations.sorted()
            {
                // If a1 is the current annotation, it should come first
                if $0.identifier == currentAnnotation?.identifier { return true }
                // If a2 is the current annotation, it should come first
                if $1.identifier == currentAnnotation?.identifier { return false }
                
                guard let id1 = $0.title, let id2 = $1.title else { return false }
                // Otherwise sort by title as before
                return id1 < id2
            }
            
            currentAnnotationIds = newAnnotationIds
            
            // Reload and scroll to beginning
            collection.reloadData()
            collection.setContentOffset(.zero, animated: false)
        }
        
        handleSheetAfterUpdate(sheet: root.sheet)
    }
    
    func selectAnnotation(_ annotation: MapAnnotation, on mapView: MKMapView, ignore ignoreDelegate: Bool = false)
    {
        if let last = lastSelectedAnnotation, last !== annotation
        {
            mapView.deselectAnnotation(last, animated: true)
        }
        
        if ignoreDelegate
        {
            if let root = parent?.parent as? MapView
            {
                root.ignoreDelegate = true
                mapView.selectAnnotation(annotation, animated: true)
            }
        }
        else
        {
            mapView.selectAnnotation(annotation, animated: true)
        }
        
        lastSelectedAnnotation = annotation
    }
    
    func handleSheetAfterUpdate(sheet: MapSheet)
    {
        if self.annotations.isEmpty
        {
            sheet.animateSheet(to: .hidden)
        }
        else
        {
            if sheet.sheetState == .hidden
            {
                sheet.animateSheet(to: .minimized)
            }
        }
    }
    
    func getVisibleAnnotations(map: MKMapView) -> [MapAnnotation]
    {
        return map.annotations(in: map.visibleMapRect).compactMap { $0 as? MapAnnotation }
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleScrollEnd()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate
        {
            handleScrollEnd()
        }
    }
    
    func handleScrollEnd()
    {
        guard let root = parent?.parent as? MapView else { return }
        
        if root.sheet.sheetState == .maximized
        {
            let page = Int(collection.contentOffset.x / collection.bounds.width)
            
            if (0..<annotations.count).contains(page)
            {
                print("selecting")
                selectAnnotation(annotations[page], on: root.map, ignore: true)
            }
        }
    }
}

#Preview
{
    MapView()
}
