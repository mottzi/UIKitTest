import UIKit
import MapKit

class MapView: UIViewController, MKMapViewDelegate
{
    let location: MapLocation
    var lastPitch: CGFloat?

    let map: MKMapView
    let picker: MapCategoryPicker
    let controls: MapControls
    let sheet: MapSheet

    init()
    {
        self.location = MapLocation()
        self.map = MKMapView.create()
        self.picker = MapCategoryPicker()
        self.controls = MapControls()
        self.sheet = MapSheet()

        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupSubViews()
        setupViews()
    }
    
    private func setupSubViews()
    {
        location.setup(map: self)
        map.setup(parent: self)
        picker.setup(map: self)
        controls.setup(map: self)
    }
    
    private func setupViews()
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
        picker.view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        picker.view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        picker.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        
        controls.view.bottomAnchor.constraint(equalTo: sheet.view.topAnchor, constant: -10).isActive = true
        controls.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

fileprivate extension MKMapView
{
    static func create() -> MKMapView
    {
        let config = MKStandardMapConfiguration()
        config.pointOfInterestFilter = .excludingAll
        
        let map = MKMapView()
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        map.preferredConfiguration = config
        map.showsUserLocation = true
        map.showsCompass = false
        
        return map
    }
    
    func setup(parent: MapView)
    {
        self.frame = parent.view.bounds
        self.delegate = parent
    }
}

#Preview
{
    MapView()
}
