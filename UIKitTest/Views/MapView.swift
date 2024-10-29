import UIKit
import MapKit

class MapView: UIViewController, MKMapViewDelegate
{
    let location = LocationManager()
    var isCenteredOnLocation = true
       
    lazy var map: MKMapView =
    {
        let map = MKMapView()
        map.delegate = self
        map.preferredConfiguration = MKStandardMapConfiguration()
        map.showsUserLocation = true
//        map.showsCompass = false
        return map
    }()
    
    private lazy var picker: MapCategoryPicker =
    {
        let picker = MapCategoryPicker()
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
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool)
    {
        picker.sortAndReset()
        
        self.isCenteredOnLocation = false
        controls.updateIcon()
    }
    
    func centerMap(on location: CLLocation, radius: CLLocationDistance = 800, animated: Bool = true)
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
        
        // controls in bottom right corner
        controls.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        controls.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
    }
}

#Preview
{
    MapView()
}
