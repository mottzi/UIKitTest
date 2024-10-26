import UIKit
import CoreLocation

class LocationManager: CLLocationManager
{
    var locationRequestReason: LocationRequestReason = .centerMap
    
    func requestLocation(reason: LocationRequestReason)
    {
        self.locationRequestReason = reason
        self.requestLocation()
    }
}

enum LocationRequestReason: String
{
    case idle
    case centerMap
    case centerMapAnimated
}

extension MapView: CLLocationManagerDelegate
{
    // authorization callback
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        switch status
        {
            case .authorizedWhenInUse: location.requestLocation(reason: .centerMap)
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
            case .centerMap: centerMap(on: location, animated: false)
            case .centerMapAnimated: centerMap(on: location, animated: true)
        }
        
        print("LocationManager.Request for '\(self.location.locationRequestReason.rawValue)': done.")
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
