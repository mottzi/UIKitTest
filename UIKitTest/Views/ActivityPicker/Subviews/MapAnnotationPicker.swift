import UIKit
import MapKit

class MapAnnotationPicker: UIViewController
{
    weak var map: ActivityPicker?

    var annotations: [MapAnnotation] = []
    var annotationIds: Set<String> = []

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
        collection.register(MapAnnotationCard.self, forCellWithReuseIdentifier: "POICardCell")
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
    
    // reloads annotation cards using annotations that are visible on the map
    func refresh()
    {
        guard let map else { return }
        
        let newAnnotations = map.getVisibleAnnotations()
        let newAnnotationIds = Set(newAnnotations.compactMap { $0.identifier })
        
        if newAnnotationIds != annotationIds
        {           
            let currentAnnotation = getCurrentCardAnnotation()
        
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
            
            annotationIds = newAnnotationIds
            
            // Reload and scroll to beginning
            collection.reloadData()
            collection.setContentOffset(.zero, animated: false)
        }
        
        handleSheetAfterRefresh(sheet: map.sheet)
    }
    
    // returns the index of the currently selected card
    func getCurrentCardIndex() -> Int?
    {
        let index = Int(collection.contentOffset.x / collection.bounds.width)
        
        if (0..<annotations.count).contains(index)
        {
            return index
        }
        
        return nil
    }
    
    // returns the annotation associated with the currently selected card
    func getCurrentCardAnnotation() -> MapAnnotation?
    {
        if let currentIndex = getCurrentCardIndex()
        {
            return annotations[currentIndex]
        }
        
        return nil
    }
    
    // show or hide sheet after refresh
    private func handleSheetAfterRefresh(sheet: MapSheet)
    {
        if self.annotations.isEmpty
        {
            sheet.animateSheet(to: .hidden)
        }
        else if sheet.state == .hidden
        {
            sheet.animateSheet(to: .minimized)
        }
    }
}

extension MapAnnotationPicker
{
    func setup(map: ActivityPicker?)
    {
        self.map = map
    }
}

extension MapAnnotationPicker: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return annotations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "POICardCell", for: indexPath) as! MapAnnotationCard
        cell.configure(with: annotations[indexPath.item])
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        map?.selectAnotationOfCurrentCard()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        if !decelerate
        {
            map?.selectAnotationOfCurrentCard()
        }
    }
}

#Preview
{
    ActivityPicker()
}
