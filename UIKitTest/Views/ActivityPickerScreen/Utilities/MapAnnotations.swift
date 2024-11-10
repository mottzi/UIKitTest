import MapKit

class MapAnnotation: MKPointAnnotation
{
    var mapCategory: MapCategory?
    var identifier: String?
    var color: UIColor?
    var source: String?
    
    static func == (lhs: MapAnnotation, rhs: MapAnnotation) -> Bool
    {
        guard let lid = lhs.identifier else { return false }
        guard let rid = rhs.identifier else { return false }

        return lid == rid
    }
}

extension MapView
{
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView?
    {
        guard let annotation = annotation as? MapAnnotation else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "CustomPin") as? MKMarkerAnnotationView
        
        if annotationView == nil
        {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "CustomPin")
        }
        else
        {
            annotationView?.annotation = annotation
        }
        
        annotationView?.markerTintColor = annotation.color
        annotationView?.alpha = 0.0
        annotationView?.glyphImage = UIImage(systemName: annotation.mapCategory?.icon ?? "mappin")
        
        UIView.animate(withDuration: 0.5)
        {
            annotationView?.alpha = 1.0
        }
        
        return annotationView
    }
    
    func removeAnnotation(_ annotation: MKAnnotation, animated: Bool, completion: (() -> Void)? = nil)
    {
        if animated
        {
            guard let annotationView = map.view(for: annotation) else
            {
                removeAnnotation(annotation, animated: false, completion: completion)
                return
            }
            
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
            self.map.removeAnnotation(annotation)
            completion?()
        }
    }
}

#Preview { MapView() }
