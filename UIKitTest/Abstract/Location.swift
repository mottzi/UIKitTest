import UIKit
import CoreLocation

class LocationManager: CLLocationManager
{
    var locationRequestReason: LocationRequestReason = .centerMapOnLaunch
    
    func requestLocation(reason: LocationRequestReason)
    {
        self.locationRequestReason = reason
        self.requestLocation()
    }
}

enum LocationRequestReason: String
{
    case idle
    case centerMapOnLaunch
    case centerMapAnimated
    case locationButtonTapped
}

extension MapView: CLLocationManagerDelegate
{
    // authorization callback
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        switch status
        {
            case .authorizedWhenInUse: location.requestLocation(reason: .centerMapOnLaunch)
            case .notDetermined: location.requestWhenInUseAuthorization()
            default: break
        }
    }
    
    // location callback
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard let location = locations.last else { return }
        
        switch self.location.locationRequestReason
        {
            case .idle: return
            case .centerMapOnLaunch: self.centerMap(on: location, radius: 800, animated: false)
            case .centerMapAnimated, .locationButtonTapped: self.centerMap(on: location, radius: nil, animated: true)
        }
        
//        print("LocationManager.Request for '\(self.location.locationRequestReason.rawValue)': done.")
        self.location.locationRequestReason = .idle
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Location error: \(error.localizedDescription) -> \(manager.authorizationStatus)")
    }
    
    func setupLocation()
    {
        location.delegate = self
        location.desiredAccuracy = kCLLocationAccuracyBest
    }
}
