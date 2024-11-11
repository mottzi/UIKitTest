import UIKit
import CoreLocation

extension MapLocation
{
    enum LocationRequestReason
    {
        case idle
        case centerMapOnLaunch
        case centerMapAnimated
        case locationButtonTapped
    }
    
    func requestLocation(reason: LocationRequestReason)
    {
        self.locationRequestReason = reason
        self.requestLocation()
    }
    
    func setup(map: ActivityPicker)
    {
        self.map = map
        self.delegate = self
        self.desiredAccuracy = kCLLocationAccuracyBest
    }
}

class MapLocation: CLLocationManager, CLLocationManagerDelegate
{
    weak var map: ActivityPicker?
    var locationRequestReason: LocationRequestReason = .centerMapOnLaunch

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        switch status
        {
            case .authorizedWhenInUse: requestLocation(reason: .centerMapOnLaunch)
            case .notDetermined: requestWhenInUseAuthorization()
            default: break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard let location = locations.last else { return }
        
        switch locationRequestReason
        {
            case .idle: return
            case .centerMapOnLaunch: map?.centerMap(on: location, radius: 1200, animated: false)
            case .centerMapAnimated: map?.centerMap(on: location, radius: 1200, animated: true)
            case .locationButtonTapped: map?.centerMap(on: location, radius: nil, animated: true)
        }
        
        locationRequestReason = .idle
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Location error: \(error.localizedDescription) -> \(manager.authorizationStatus)")
    }
}
