import UIKit
import MapKit

class MapView: UIViewController, MKMapViewDelegate
{
    var lastPitch: CGFloat?
    
    lazy var location: MapLocation? =
    {
        return MapLocation(map: self)
    }()

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
    
    lazy var picker: MapCategoryPicker =
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
        location?.setupLocation()
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
