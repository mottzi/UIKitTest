import UIKit
import MapKit

class MapView: UIViewController, MKMapViewDelegate, UISheetPresentationControllerDelegate
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
    
    lazy var sheet: MapSheet? =
    {
        return MapSheet()
    }()
    
    lazy var controls: MapControls =
    {
        let controls = MapControls(map: self)
        controls.view.translatesAutoresizingMaskIntoConstraints = false
        return controls
    }()
    
    var bottomConstraint: NSLayoutConstraint?
    
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
        
        controls.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        bottomConstraint = controls.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
        bottomConstraint?.isActive = true
    }
    
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        updateConstraints(sheetPresentationController: sheetPresentationController)
    }
    
    func updateConstraints(sheetPresentationController: UISheetPresentationController)
    {
        if let constraint = bottomConstraint
        {
            // Deactivate the constraint
            constraint.isActive = false
            // Remove the reference to the constraint
            bottomConstraint = nil
        }
        
        let val = switch sheetPresentationController.selectedDetentIdentifier?.rawValue
        {
            case "small": 60.0
            case "big": 310.0
            default: 60.0
        }
        
        bottomConstraint = controls.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -val)
        
        UIView.bouncyAnimation
        {
            self.bottomConstraint?.isActive = true
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        guard let sheet else { return }
        
        if let presentationController = sheet.sheetPresentationController
        {
            let detents: [UISheetPresentationController.Detent] =
            [
                .custom(identifier: .init("small"), resolver: { context in 50 }),
                .custom(identifier: .init("big"), resolver: { context in 300 })
            ]
            
            presentationController.detents = detents
            presentationController.prefersGrabberVisible = true
            presentationController.largestUndimmedDetentIdentifier = .init("big")
            
            presentationController.delegate = self
        }
        
        sheet.isModalInPresentation = true
        
        present(sheet, animated: true)
    }
}

class MapSheet: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBlue
        
        let label = UILabel()
        label.text = "Bottom Sheet Content"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(label)

        label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
}

#Preview
{
    MapView()
}
