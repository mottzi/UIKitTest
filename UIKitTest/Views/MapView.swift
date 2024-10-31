import UIKit
import MapKit

class MapView: UIViewController, MKMapViewDelegate
{
    let location = LocationManager()
    
    private var lastPitch: CGFloat?

    lazy var map: MKMapView =
    {
        let config = MKStandardMapConfiguration()
        config.pointOfInterestFilter = .excludingAll
        
        let map = MKMapView(frame: self.view.bounds)
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        map.delegate = self
        map.preferredConfiguration = config
        map.showsUserLocation = true
        map.showsCompass = false
        
        return map
    }()
    
    private lazy var picker: MapCategoryPicker =
    {
        let picker = MapCategoryPicker(map: self)
        picker.view.translatesAutoresizingMaskIntoConstraints = false
        picker.view.backgroundColor = .clear
        return picker
    }()
    
    lazy var controls: MapControls =
    {
        let controls = MapControls(map: self)
        controls.view.translatesAutoresizingMaskIntoConstraints = false
        return controls
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupLocation()
        setupViews()
    }
    
    private func setupViews()
    {
        self.addChild(picker)
        self.addChild(controls)
        
        self.view.addSubview(map)
        self.view.addSubview(picker.view)
        self.view.addSubview(controls.view)

        setupConstraints()
        
        picker.didMove(toParent: self)
        controls.didMove(toParent: self)
    }
    
    func centerMap(on location: CLLocation, radius: CLLocationDistance? = nil, animated: Bool = true)
    {
        if let radius
        {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
            
            map.setRegion(region, animated: animated)
        }
        else
        {
            map.setCenter(location.coordinate, animated: animated)
        }
        
        controls.updateLocationButton(isMapCentered: true)
    }
    
    func togglePitch()
    {
        controls.pitchButton.isSelected.toggle()
        
        let camera = MKMapCamera(
            lookingAtCenter: map.centerCoordinate,
            fromDistance: map.camera.centerCoordinateDistance,
            pitch: controls.pitchButton.isSelected ? 70 : 0,
            heading: map.camera.heading
        )
        
        map.setCamera(camera, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool)
    {
        picker.sortAndReset()
        controls.updateLocationButton(isMapCentered: false)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        let currentPitch = mapView.camera.pitch
        
        if let lastPitch, lastPitch != currentPitch
        {
            controls.updatePitchButton(isPitchActive: currentPitch > 0)
        }
        
        lastPitch = currentPitch
    }
    
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
            guard let annotationView = map.view(for: annotation) else { return }
            
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
    
    private func setupConstraints()
    {
        // full width picker - anchorded to top
        picker.view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        picker.view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        picker.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        
        // controls in bottom right corner
        controls.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        controls.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
    }
}

#Preview
{
    MapView()
}
