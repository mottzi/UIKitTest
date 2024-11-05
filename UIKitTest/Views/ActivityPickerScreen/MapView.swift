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
    
    lazy var sheet: MapSheet = MapSheet()
    
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
        self.addChild(sheet)
        
        self.view.addSubview(map)
        self.view.addSubview(sheet.view)
        self.view.addSubview(picker.view)
        self.view.addSubview(controls.view)
                
        setupConstraints()
        
        picker.didMove(toParent: self)
        controls.didMove(toParent: self)
        sheet.didMove(toParent: self)
    }
    
    private func setupConstraints()
    {
        // full width picker - anchorded to top
        picker.view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        picker.view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        picker.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        
        // constrain controls to sheet
        controls.view.bottomAnchor.constraint(equalTo: sheet.sheetContainer.topAnchor, constant: -10).isActive = true
        controls.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
    }
}

class MapSheet: UIViewController
{
    enum SheetState
    {
        case minimized
        case maximized
    }
    
    private let blurEffectView: UIVisualEffectView =
    {
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)  // Apply thin material blur
        return UIVisualEffectView(effect: blurEffect)
    }()
    
    let sheetContainer = UIView()
    private var currentState: SheetState = .minimized
    
    // Constants for sheet positioning
    private let minimizedHeight: CGFloat = 100
    private let maximizedHeight: CGFloat = 250
    private let cornerRadius: CGFloat = 30
    
    private var heightConstraint: NSLayoutConstraint?
    
    private lazy var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupSheetContainer()
        sheetContainer.addGestureRecognizer(panGesture)
    }
    
    private func setupSheetContainer()
    {
        view.backgroundColor = .clear
        
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        sheetContainer.addSubview(blurEffectView) // Add blur view to the sheet container
        NSLayoutConstraint.activate([
            blurEffectView.leadingAnchor.constraint(equalTo: sheetContainer.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: sheetContainer.trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: sheetContainer.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: sheetContainer.bottomAnchor)
        ])
        
        // Configure sheet container
        sheetContainer.translatesAutoresizingMaskIntoConstraints = false
        sheetContainer.backgroundColor = .clear
        sheetContainer.layer.cornerRadius = cornerRadius
        sheetContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetContainer.clipsToBounds = true
        
        view.addSubview(sheetContainer)
        
        // sheet max width
        sheetContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        sheetContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        // sheet stick to bottom
        sheetContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // dynamic height contraint
        heightConstraint = sheetContainer.heightAnchor.constraint(equalToConstant: minimizedHeight)
        heightConstraint?.isActive = true
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer)
    {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state
        {
            // Update height based on drag
            case .changed:
                let newHeight = currentState == .maximized ?
                maximizedHeight - translation.y :
                minimizedHeight - translation.y
                
                // Constrain height between min and max
                let constrainedHeight = min(maximizedHeight, max(minimizedHeight, newHeight))
                heightConstraint?.constant = constrainedHeight
                
            // Determine final state based on velocity and position
            case .ended:
                let currentHeight = heightConstraint?.constant ?? minimizedHeight
                let midPoint = (maximizedHeight + minimizedHeight) / 2
                
                // Fast downward swipe - minimize
                if velocity.y > 500
                {
                    animateSheet(to: .minimized)
                }
                // Fast upward swipe - maximize
                else if velocity.y < -500
                {
                    animateSheet(to: .maximized)
                }
                // Above midpoint - maximize
                else if currentHeight > midPoint
                {
                    animateSheet(to: .maximized)
                }
                // Below midpoint - minimize
                else
                {
                    animateSheet(to: .minimized)
                }
                
            default: break
        }
    }
    
    private func animateSheet(to state: SheetState)
    {
        let height = state == .maximized ? maximizedHeight : minimizedHeight
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut)
        {
            self.heightConstraint?.constant = height
            self.parent?.view.layoutIfNeeded()
        }
        completion:
        { [weak self] _ in
            self?.currentState = state
        }
    }
}

#Preview {
    MapView()
}
