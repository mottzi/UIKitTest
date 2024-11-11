import UIKit
import MapKit

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
    
    // reloads POI cards using annotations that are visible on the map
    func refresh()
    {
        guard let root = parent?.parent as? ActivityPicker else { return }
        
        let newAnnotations = root.getVisibleAnnotations()
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
        
        handleSheetAfterRefresh(sheet: root.sheet)
    }
    
    // show or hide sheet after refresh
    private func handleSheetAfterRefresh(sheet: MapSheet)
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
        guard let root = parent?.parent as? ActivityPicker else { return }
        
        if root.sheet.sheetState == .maximized
        {
            let page = Int(collection.contentOffset.x / collection.bounds.width)
            
            if (0..<annotations.count).contains(page)
            {
                root.selectAnnotation(annotations[page]/*, ignore: true*/)
            }
        }
    }
}

#Preview
{
    ActivityPicker()
}
