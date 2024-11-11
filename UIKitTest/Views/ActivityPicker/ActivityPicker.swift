import UIKit
import MapKit

class ActivityPicker: UIViewController, MKMapViewDelegate
{
    let map: MKMapView = MKMapView()
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
        sheet.setup(map: self)
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
    func setup(parent: ActivityPicker)
    {
        self.delegate = parent
        
        let config = MKStandardMapConfiguration()
        config.pointOfInterestFilter = .excludingAll

        self.translatesAutoresizingMaskIntoConstraints = false
        self.preferredConfiguration = config
        self.showsUserLocation = true
        self.showsCompass = false
    }
    
    func constraints(activate: Bool = true)
    {
        guard let root = self.viewController as? ActivityPicker else { return }

        self.leadingAnchor.constraint(equalTo: root.view.leadingAnchor).isActive = activate
        self.trailingAnchor.constraint(equalTo: root.view.trailingAnchor).isActive = activate
        self.topAnchor.constraint(equalTo: root.view.topAnchor).isActive = activate
        self.bottomAnchor.constraint(equalTo: root.view.bottomAnchor).isActive = activate
    }
}

#Preview
{
    ActivityPicker()
}
