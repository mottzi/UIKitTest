import UIKit
import MapKit


/// A view that view that displayes category filtered POI on a map.
///
/// ### Subviews
/// - `map (MKMapView)`: The map view (`MapKit`).
/// - `categories`: The category picker view. Categories can be selected using the `MapCategoryPicker`.
/// - `controls`: The map configuration can be controlled through `MapControls`.
/// - `sheet`: The sheet that dynamically presents onscreen POI results and allows their selection.
class MapView: UIViewController, MKMapViewDelegate
{
    let map: MKMapView = MKMapView.create()
    let categories: MapCategoryPicker = MapCategoryPicker()
    let controls: MapControls = MapControls()
    let sheet: MapSheet = MapSheet()
    
    let location: MapLocation = MapLocation()

    var lastPitch: CGFloat?
    var ignoreMinimizeSheet: Bool? = true
    var ignoreDelegate: Bool? = false
    
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
        categories.setup(map: self)
        controls.setup(map: self)
    }
    
    private func setupView()
    {
        self.addChild(categories)
        self.addChild(controls)
        self.addChild(sheet)
        
        self.view.addSubview(map)
        self.view.addSubview(categories.view)
        self.view.addSubview(controls.view)
        self.view.addSubview(sheet.view)
        
        map.constraints()
        categories.constraints()
        controls.constraints()
        sheet.constraints()
        
        categories.didMove(toParent: self)
        controls.didMove(toParent: self)
        sheet.didMove(toParent: self)
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
