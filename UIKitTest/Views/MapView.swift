import UIKit
import MapKit

class MapView: UIViewController, MKMapViewDelegate
{
//    private let location = CLLocationManager()
    
    private lazy var map: MKMapView =
    {
        let map = MKMapView()
        map.delegate = self
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
        
//        setupMap()
//        setupLocation()
        
        self.view.addSubview(map)
        self.view.addSubview(picker.view)
        
        setupConstraints()
    }
    
//    private func setupMap()
//    {
//        map.delegate = self
//        map.preferredConfiguration = MKStandardMapConfiguration()
//        
//        CLLocationManager().requestWhenInUseAuthorization()
//    }
    
//    private func setupLocation()
//    {
//        location.delegate = self
//        location.desiredAccuracy = kCLLocationAccuracyReduced
//        
//        location.requestWhenInUseAuthorization()
//        location.requestLocation()
//    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation)
    {
        if let location = userLocation.location { centerMap(on: location, animated: false) }
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

//extension MapView: MKMapViewDelegate
//{
//    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation)
//    {
//        if let location = userLocation.location { centerMap(on: location, animated: false) }
//    }
//}

//
//extension MapView: CLLocationManagerDelegate 
//{
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) 
//    {
//        guard let location = locations.last else { return }
//        
//        centerMap(on: location)
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) 
//    {
//        print("Location error: \(error.localizedDescription)")
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) 
//    {
//        switch status
//        {
//            case .authorizedWhenInUse, .authorizedAlways: do
//            {
//                map.showsUserLocation = true
//            }
//            case .notDetermined: do
//            {
//                location.requestWhenInUseAuthorization()
//            }
//            default: break
//        }
//    }
//}

#Preview
{
    MapView()
}
