import UIKit
import MapKit

class MapView: UIViewController
{
    private let location = CLLocationManager()
    
    private lazy var map: MKMapView =
    {
        let map = MKMapView()
        map.preferredConfiguration = MKStandardMapConfiguration()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.showsUserLocation = true
        
        CLLocationManager().requestWhenInUseAuthorization()

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

        self.view.addSubview(map)
        self.view.addSubview(picker.view)
        
        setupConstraints()
    }
    
    private func setupLocation()
    {
        location.delegate = self
        location.desiredAccuracy = kCLLocationAccuracyBest
        
        location.requestWhenInUseAuthorization()
    }
    
    private func centerMap(on location: CLLocation, radius: CLLocationDistance = 850, animated: Bool = true)
    {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
        
        map.setRegion(region, animated: animated)
    }
    
    private func setupConstraints()
    {
        // full screen map
        NSLayoutConstraint.activate([
            map.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            map.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            map.topAnchor.constraint(equalTo: view.topAnchor),
            map.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // full width picker - anchorded to top
        NSLayoutConstraint.activate([
            picker.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            picker.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            picker.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
        ])
    }
}

extension MapView: CLLocationManagerDelegate 
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) 
    {
        guard let location = locations.last else { return }
        
        centerMap(on: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) 
    {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) 
    {
        switch status
        {
            case .authorizedWhenInUse, .authorizedAlways: do
            {
                location.requestLocation()
            }
            case .notDetermined: do
            {
                location.requestWhenInUseAuthorization()
            }
            default: break
        }
    }
}

#Preview
{
    MapView()
}
