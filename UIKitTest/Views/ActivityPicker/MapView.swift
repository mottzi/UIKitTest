import UIKit
import MapKit

class MapView: UIViewController, MKMapViewDelegate
{
    let map: MKMapView = MKMapView.create()
    let categoryPicker: MapCategoryPicker = MapCategoryPicker()
    let controls: MapControls = MapControls()
    let sheet: MapSheet = MapSheet()
    
    let location: MapLocation = MapLocation()

    var lastPitch: CGFloat?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupSubViews()
        setupView()
    }
    
    private func setupSubViews()
    {
        location.setup(map: self)
        map.setup(parent: self)
        categoryPicker.setup(map: self)
        controls.setup(map: self)
    }
    
    private func setupView()
    {
        self.addChild(categoryPicker)
        self.addChild(controls)
        self.addChild(sheet)
        
        self.view.addSubview(map)
        self.view.addSubview(categoryPicker.view)
        self.view.addSubview(controls.view)
        self.view.addSubview(sheet.view)
        
        map.constraints()
        categoryPicker.constraints()
        controls.constraints()
        sheet.constraints()
        
        categoryPicker.didMove(toParent: self)
        controls.didMove(toParent: self)
        sheet.didMove(toParent: self)
    }
}

extension MKMapView
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

#Preview
{
    MapView()
}
