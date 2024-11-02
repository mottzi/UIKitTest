import MapKit

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
    
    func removeAnnotation(_ annotation: MKAnnotation, animated: Bool)
    {
        if animated
        {
            guard let annotationView = map.view(for: annotation) else { return self.map.removeAnnotation(annotation) }
            
            UIView.animate(withDuration: 0.5)
            {
                annotationView.alpha = 0
            }
        completion:
            { _ in
                self.map.removeAnnotation(annotation)
            }
        }
        else
        {
            self.map.removeAnnotation(annotation)
        }
    }
}
