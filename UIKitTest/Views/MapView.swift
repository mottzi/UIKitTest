import UIKit
import MapKit

class MapView: UIViewController
{
    let location = LocationManager()
    var enteredForeground = 0
       
    private lazy var map: MKMapView =
    {
        let map = MKMapView()
        map.delegate = self
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(onEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    @objc private func onEnterForeground()
    {
        if enteredForeground > 0
        {
            print("App has entered the foreground.")
            location.requestLocation(reason: .centerMapAnimated)
        }
        else
        {
            print("App has launched.")
        }
        
        enteredForeground += 1
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    private func setupViews()
    {
        self.addChild(picker)
        
        self.view.addSubview(map)
        self.view.addSubview(picker.view)
                
        setupConstraints()
        picker.didMove(toParent: self)
    }
    
    public func centerMap(on location: CLLocation, radius: CLLocationDistance = 800, animated: Bool = true)
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

extension MapView: MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool)
    {
        UIView.bouncyAnimation()
        {
            self.picker.sortButtons()
            self.picker.resetPickerScroll()
        }
    }
}

#Preview
{
    MapView()
}
