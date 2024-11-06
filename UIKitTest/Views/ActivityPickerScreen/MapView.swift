import UIKit
import MapKit

// MARK: - init
class MapView: UIViewController, MKMapViewDelegate
{
    let location: MapLocation = MapLocation()

    let map: MKMapView = MKMapView.create()
    let picker: MapCategoryPicker = MapCategoryPicker()
    let controls: MapControls = MapControls()
    let sheet: MapSheet = MapSheet()
    
    var lastPitch: CGFloat?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupSubViews()
        setupView()
    }
}

// MARK: - setup - layout
extension MapView
{
    private func setupSubViews()
    {
        location.setup(map: self)
        map.setup(parent: self)
        picker.setup(map: self)
        controls.setup(map: self)
    }
    
    private func setupView()
    {
        self.addChild(picker)
        self.addChild(controls)
        self.addChild(sheet)
        
        self.view.addSubview(map)
        self.view.addSubview(picker.view)
        self.view.addSubview(controls.view)
        self.view.addSubview(sheet.view)
        
        setupConstraints()
        
        picker.didMove(toParent: self)
        controls.didMove(toParent: self)
        sheet.didMove(toParent: self)
    }
    
    private func setupConstraints()
    {
        map.constraints(activate: true)
        picker.constraints(activate: true)
        controls.constraints(activate: true)
    }
}

// MARK: - mapView
fileprivate extension MKMapView
{
    static func create() -> MKMapView
    {
        let config = MKStandardMapConfiguration()
        config.pointOfInterestFilter = .excludingAll
        
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.preferredConfiguration = config
        map.showsUserLocation = true
        map.showsCompass = false
        
        return map
    }
    
    func setup(parent: MapView)
    {
        self.delegate = parent
    }
    
    func constraints(activate: Bool = true)
    {
        guard let root = self.viewController as? MapView else { return }

        self.leadingAnchor.constraint(equalTo: root.view.leadingAnchor).isActive = activate
        self.trailingAnchor.constraint(equalTo: root.view.trailingAnchor).isActive = activate
        self.topAnchor.constraint(equalTo: root.view.topAnchor).isActive = activate
        self.bottomAnchor.constraint(equalTo: root.view.bottomAnchor).isActive = activate
    }
}

// MARK: - preview
#Preview
{
    MapView()
}
