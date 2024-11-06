import UIKit

extension MapCategoryPicker
{
    func constraints(activate: Bool = true)
    {
        guard let map = self.parent as? MapView else { return }
        
        self.view.leadingAnchor.constraint(equalTo: map.view.safeAreaLayoutGuide.leadingAnchor).isActive = activate
        self.view.trailingAnchor.constraint(equalTo: map.view.safeAreaLayoutGuide.trailingAnchor).isActive = activate
        self.view.topAnchor.constraint(equalTo: map.view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = activate
    }
}
class MapCategoryPicker: UIViewController
{
    public let haptics = UISelectionFeedbackGenerator()
    
    weak var map: MapView?
    
    func setup(map: MapView)
    {
        self.map = map
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.backgroundColor = .clear
    }
    
//    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private lazy var scrollview: UIScrollView =
    {
        let scrollview = UIScrollView()
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        scrollview.layer.masksToBounds = false
        return scrollview
    }()
    
    private lazy var stackview: UIStackView =
    {
        let stackview = UIStackView()
        stackview.axis = .horizontal
        stackview.spacing = 8
        stackview.translatesAutoresizingMaskIntoConstraints = false
        return stackview
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        loadButtons(into: stackview)
        scrollview.addSubview(stackview)
        
        self.view.addSubview(scrollview)
        
        NSLayoutConstraint.activate(controlConstraints)
    }
    
    private lazy var controlConstraints: [NSLayoutConstraint] =
    [
        scrollview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        scrollview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        scrollview.topAnchor.constraint(equalTo: view.topAnchor),
        scrollview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        
        stackview.leadingAnchor.constraint(equalTo: scrollview.contentLayoutGuide.leadingAnchor, constant: 12),
        stackview.trailingAnchor.constraint(equalTo: scrollview.contentLayoutGuide.trailingAnchor, constant: -12),
        stackview.topAnchor.constraint(equalTo: scrollview.contentLayoutGuide.topAnchor),
                
        self.view.heightAnchor.constraint(equalTo: stackview.heightAnchor, constant: 0)
    ]
    
    private func loadButtons(into view: UIStackView)
    {
        for category in MapCategory.allCategories
        {
            let button = MapCategoryButton(category: category, picker: self)
            view.addArrangedSubview(button)
        }
    }
    
    public func sortButtons()
    {
        let buttons = stackview.arrangedSubviews.compactMap { $0 as? MapCategoryButton }
        let sortedButtons = buttons.sorted { $0.isSelected && !$1.isSelected }
             
        for button in sortedButtons
        {
            stackview.removeArrangedSubview(button)
            stackview.addArrangedSubview(button)
        }

        stackview.layoutIfNeeded()
    }
    
    public func getSelectedCategories() -> [MapCategory]
    {
        let selectedCategories = stackview.arrangedSubviews.compactMap { $0 as? MapCategoryButton }
            .filter { $0.isSelected }
            .map { $0.category }
        
        return selectedCategories
    }
    
    public func resetPickerScroll()
    {
        scrollview.setContentOffset(.zero, animated: false)
    }
    
    public func sortAndReset(animated: Bool = true)
    {
        if animated
        {
            UIView.bouncyAnimation()
            {
                self.sortButtons()
                self.resetPickerScroll()
            }
        }
        else
        {
            sortButtons()
            resetPickerScroll()
        }
    }
    
    public func loadApplePOIFromRegion(categories: [MapCategory]) async
    {
        guard let map = map?.map else { return }
        
        for category in categories
        {
            let request = AppleRequest(with: category, region: map.region)
            
            guard let foundItems = await request.start() else { continue }
            
            let button = stackview.arrangedSubviews
                .compactMap { $0 as? MapCategoryButton }
                .first { $0.category == category }
            
            guard let button else { continue }

            if button.isSelected == false { continue }
            
            DispatchQueue.main.async
            {
                foundItems.forEach
                { poi in
                    let exists = map.annotations.contains()
                    { annotation in
                        guard let existing = annotation as? MapAnnotation,
                              let identifier = poi.mapItem.identifier?.rawValue
                        else { return false }
                        
                        return existing.identifier == identifier
                    }
                    
                    if !exists
                    {
                        let marker = MapAnnotation()
                        marker.identifier = poi.mapItem.identifier?.rawValue
                        marker.mapCategory = category
                        marker.coordinate = poi.mapItem.placemark.coordinate
                        marker.title = poi.mapItem.name
                        marker.color = category.color
                        
                        map.addAnnotation(marker)                        
                    }
                }
            }
        }
    }
    
    public func removePOI(category: MapCategory)
    {
        guard let map = map?.map else { return }

        let mapAnnotations = map.annotations.filter()
        {
            guard let marker = $0 as? MapAnnotation else { return false }
            
            guard let itemCategory = marker.mapCategory, itemCategory == category else { return false }
            
            return true
        }
        
        for (index, annotation) in mapAnnotations.enumerated()
        {
            var completion: (() -> ())? = nil
            
            if index == mapAnnotations.count - 1
            {
                completion =
                { [weak self] in
                    if index == mapAnnotations.count - 1
                    {
                        self?.map?.handleVisibleAnnotationsChanged()
                    }
                }
            }
            
            self.map?.removeAnnotation(annotation, animated: true, completion: completion)
        }
    }
    
    public func loadOSMPOIFromRegion(categories: [MapCategory]) async
    {
        guard let map = map?.map else { return }
        
        for category in categories
        {
            let request = OSMRequest(for: category, region: map.region)
            
            guard let foundItems = await request.start() else { continue }
            
            let button = stackview.arrangedSubviews
                .compactMap { $0 as? MapCategoryButton }
                .first { $0.category == category }
            
            guard let button else { continue }
            
            if button.isSelected == false { continue }
            
            DispatchQueue.main.async
            {
                foundItems.forEach
                { poi in
                    let exists = map.annotations.contains()
                    { annotation in
                        guard let existing = annotation as? MapAnnotation
                        else { return false }
                        
                        return existing.identifier == "\(poi.hashValue)"
                    }
                    
                    if !exists
                    {
                        let marker = MapAnnotation()
                        marker.identifier = "\(poi.hashValue)"
                        marker.mapCategory = category
                        marker.coordinate = poi.coordinate
                        marker.title = poi.name
                        marker.color = category.color
                        
                        map.addAnnotation(marker)
                    }
                }
            }
        }
    }
}

#Preview
{
    MapView()
}
