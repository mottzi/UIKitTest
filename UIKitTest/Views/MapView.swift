import UIKit
import MapKit

class MapView: UIViewController
{
    private let location = CLLocationManager()
        
    private lazy var map: MKMapView =
    {
        let map = MKMapView()
        map.preferredConfiguration = MKStandardMapConfiguration()
        map.showsUserLocation = true
        return map
    }()
    
    private lazy var picker: HorizontalCategoryPicker =
    {
        let picker = HorizontalCategoryPicker()
        picker.view.translatesAutoresizingMaskIntoConstraints = false
        picker.view.backgroundColor = .clear
        return picker
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupLocation()
        setupViews()
    }
    
    private func setupViews()
    {
        self.view.addSubview(map)
        self.view.addSubview(picker.view)
        
        setupConstraints()
    }
    
    private func centerMap(on location: CLLocation, radius: CLLocationDistance = 800, animated: Bool = true)
    {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
        
        map.setRegion(region, animated: animated)
    }
    
    private func setupConstraints()
    {
        // full screen map
        map.frame = self.view.bounds
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // full width picker - anchorded to top
        picker.view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        picker.view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        picker.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
    }
}

extension MapView: CLLocationManagerDelegate 
{
    // authorization callback
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        switch status
        {
            case .authorizedWhenInUse: location.requestLocation()
            case .notDetermined: location.requestWhenInUseAuthorization()
            default: break
        }
    }
    
    // location callback
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard let location = locations.last else { return }
        
        centerMap(on: location, animated: false)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) 
    {
        print("Location error: \(error.localizedDescription)")
    }
    
    private func setupLocation()
    {
        location.delegate = self
        location.desiredAccuracy = kCLLocationAccuracyBest
    }
}

#Preview
{
    MapView()
}
