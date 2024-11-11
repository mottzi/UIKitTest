import MapKit

class MapAnnotation: MKPointAnnotation
{
    var identifier: String
    
    var category: MapCategory
    var color: UIColor
    var source: String
    
    init(identifier: String, mapCategory: MapCategory, color: UIColor, source: String)
    {
        self.category = mapCategory
        self.identifier = identifier
        self.color = color
        self.source = source
    }
    
    static func == (lhs: MapAnnotation, rhs: MapAnnotation) -> Bool
    {
        return lhs.identifier == lhs.identifier
    }
}

extension ActivityPicker
{
    // annotation provider
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView?
    {
        guard let annotation = annotation as? MapAnnotation else { return nil }
        
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: "CustomPin") as? MKMarkerAnnotationView
        ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "CustomPin")
        
        view.annotation = annotation
        view.markerTintColor = annotation.color
        view.glyphImage = UIImage(systemName: annotation.category.icon)
        
        view.alpha = 0.0
        UIView.animate(withDuration: 0.5) { view.alpha = 1.0 }
        
        return view
    }
    
    // returns all visible annotations on the map
    func getVisibleAnnotations() -> [MapAnnotation]
    {
        return map.annotations(in: map.visibleMapRect).compactMap { $0 as? MapAnnotation }
    }
    
    // removes all annotations of a category
    func removeAnnotations(category: MapCategory)
    {
        let removalGroup = DispatchGroup()
        
        for annotation in category.getAnnotations(on: map)
        {
            removalGroup.enter()
            
            self.removeAnnotation(annotation, animated: true)
            {
                removalGroup.leave()
            }
        }
        
        removalGroup.notify(queue: .main)
        {
            self.sheet.resultPicker.refresh()
        }
    }

    // removes annotations with a view fade-out animation
    func removeAnnotation(_ annotation: MKAnnotation, animated: Bool, completion: (() -> Void)? = nil)
    {
        if animated, let annotationView = map.view(for: annotation)
        {
            UIView.animate(withDuration: 0.5)
            {
                annotationView.alpha = 0
            }
            completion:
            { [weak self] _ in
                self?.map.removeAnnotation(annotation)
                completion?()
            }
        }
        else
        {
            map.removeAnnotation(annotation)
            
            if !animated { completion?() }
        }
    }
    
    // adds POI from Apple to the map if not already present
    func addAnnotation(apple item: MKFilteredMapItem, category: MapCategory)
    {
        let exists = map.annotations.contains()
        { annotation in
            guard let annotation = annotation as? MapAnnotation,
                  let identifier = item.mapItem.identifier?.rawValue
            else { return false }
            
            return annotation.identifier == identifier
        }
        
        if !exists
        {
            let marker = MapAnnotation(identifier: item.mapItem.identifier?.rawValue ?? "",
                                       mapCategory: category,
                                       color: category.color,
                                       source: MapRequestSource.apple.rawValue)
            
            marker.coordinate = item.mapItem.placemark.coordinate
            marker.title = item.mapItem.name
            
            map.addAnnotation(marker)
        }
    }
    
    // adds POI from OSM to the map if not already present
    func addAnnotations(osm item: OSMFilteredMapItem, category: MapCategory)
    {
        let exists = map.annotations.contains()
        { annotation in
            guard let annotation = annotation as? MapAnnotation else { return false }
            
            return annotation.identifier == "\(item.hashValue)"
        }
        
        if !exists
        {
            let marker = MapAnnotation(identifier: "\(item.hashValue)",
                                       mapCategory: category,
                                       color: category.color,
                                       source: MapRequestSource.osm.rawValue)
            
            marker.coordinate = item.coordinate
            marker.title = item.name
            
            map.addAnnotation(marker)
        }
    }
    
    // selects the provided annotation programmatically
    func selectAnnotation(_ annotation: MapAnnotation)
    {
        if let last = sheet.resultPicker.lastSelectedAnnotation, last !== annotation
        {
            map.deselectAnnotation(last, animated: true)
        }
        
        map.selectAnnotation(annotation, animated: true)
        
        sheet.resultPicker.lastSelectedAnnotation = annotation
    }
    
    // selects the annotation that corresponds to the currently selected POI in the result picker
    func selectAnnotationOfResult()
    {
        if sheet.resultPicker.annotations.count > 0
        {
            let currentIndex = Int(sheet.resultPicker.collection.contentOffset.x / sheet.resultPicker.collection.bounds.width)
            
            if (0..<sheet.resultPicker.annotations.count).contains(currentIndex)
            {
                self.selectAnnotation(sheet.resultPicker.annotations[currentIndex])
            }
        }
    }
    
    // deselects all currently selected annotations
    func deselectAllSelectedAnnotations()
    {
        map.selectedAnnotations.forEach()
        {
            map.deselectAnnotation($0, animated: true)
        }
    }
}

// selection
extension ActivityPicker
{
    // handle user selection of an annotation
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation)
    {
        guard let annotation = annotation as? MapAnnotation else { return }
        
        guard let index = sheet.resultPicker.annotations.firstIndex(where: { $0.identifier == annotation.identifier }) else { return }
        
        let targetOffset = CGFloat(index) * sheet.resultPicker.collection.bounds.width
        sheet.resultPicker.collection.setContentOffset(CGPoint(x: targetOffset, y: 0), animated: false)
        sheet.resultPicker.lastSelectedAnnotation = annotation
        
        if sheet.state != .maximized { sheet.animateSheet(to: .maximized) }
    }
    
    // handle user deselection of an annotation
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
        {
            if self.getVisibleAnnotations().count == 0
            {
                self.sheet.animateSheet(to: .hidden)
            }
            else if self.map.selectedAnnotations.count == 0
            {
                self.sheet.animateSheet(to: .minimized)
            }
        }
    }
}

// API requests
extension ActivityPicker
{
    enum MapRequestSource: String
    {
        case apple = "Apple"
        case osm = "OpenStreetMap"
    }
    
    // loads and adds results as map annotations
    func requestAnnotations(categories: [MapCategory], from source: MapRequestSource) async
    {
        switch source
        {
            case .apple: await requestAppleAnnotations(categories: categories)
            case .osm: await requestOSMAnnotations(categories: categories)
        }
    }
    
    // convenience
    func requestAnnotations(category: MapCategory, from source: MapRequestSource) async
    {
        await requestAnnotations(categories: [category], from: source)
    }
    
    // loads POI from Apple and adds results as map annotations
    func requestAppleAnnotations(categories: [MapCategory]) async
    {
        for category in categories
        {
            let request = AppleRequest(with: category, region: map.region)
            
            guard let foundItems = await request.start() else { continue }
            
            if !categoryPicker.isCategorySelected(category: category) { continue }
            
            DispatchQueue.main.async
            {
                for item in foundItems
                {
                    self.addAnnotation(apple: item, category: category)
                }
            }
        }
    }
    
    // loads POI from OSM and adds results as map annotations
    func requestOSMAnnotations(categories: [MapCategory]) async
    {
        for category in categories
        {
            let request = OSMRequest(for: category, region: map.region)
            
            guard let foundItems = await request.start() else { continue }
            
            if !categoryPicker.isCategorySelected(category: category) { continue }
            
            DispatchQueue.main.async
            {
                for item in foundItems
                {
                    self.addAnnotations(osm: item, category: category)
                }
            }
        }
    }
}

#Preview { ActivityPicker() }
