import UIKit
import MapKit

class MapControls: UIViewController 
{
    weak var mapView: MapView?
    
    init(map: MapView?)
    {
        super.init(nibName: nil, bundle: nil)
        mapView = map
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private lazy var stack: UIStackView =
    {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.addArrangedSubview(locationButton)
        stack.addArrangedSubview(pitchButton)
        stack.addArrangedSubview(compassButton)
        
        return stack
    }()

    lazy var locationButton: UIButton =
    {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.background.cornerRadius = 25
        
        button.configuration?.baseForegroundColor = .systemBlue
        button.configuration?.baseBackgroundColor = .buttonUnselected
        button.layer.shadowRadius = 1.5
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowColor = UIColor.black.withAlphaComponent(0.35).cgColor
        button.layer.shadowOpacity = 1
        
        button.configuration?.image = UIImage(systemName: "location.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        button.configuration?.preferredSymbolConfigurationForImage = .init(pointSize: 14)
        
        let action = UIAction 
        { [weak self] _ in
            self?.mapView?.location.requestLocation(reason: .locationButtonTapped)
            
            guard let lastLocation = self?.mapView?.location.location else { return }
            self?.mapView?.centerMap(on: lastLocation)
        }
        
        button.addAction(action, for: .touchUpInside)

        return button
    }()
    
    lazy var pitchButton: UIButton =
    {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.background.cornerRadius = 25
        
        button.configuration?.baseForegroundColor = .systemBlue
        button.configuration?.baseBackgroundColor = .buttonUnselected
        button.layer.shadowRadius = 1.5
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowColor = UIColor.black.withAlphaComponent(0.35).cgColor
        button.layer.shadowOpacity = 1
        
        button.configuration?.image = UIImage(systemName: "view.3d", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        button.configuration?.preferredSymbolConfigurationForImage = .init(pointSize: 14)
        
        button.addAction(UIAction{ [weak self] _ in self?.mapView?.togglePitch() }, for: .touchUpInside)
        
        return button
    }()
    
    lazy var compassButton: MKCompassButton =
    {
        let compass = MKCompassButton()
        compass.mapView = mapView?.map
        compass.compassVisibility = .visible
        compass.layer.shadowRadius = 1.5
        compass.layer.shadowOffset = CGSize(width: 0, height: 1)
        compass.layer.shadowColor = UIColor.black.withAlphaComponent(0.35).cgColor
        compass.layer.shadowOpacity = 1
        compass.alpha = 0.9
        compass.overrideUserInterfaceStyle = .light
        return compass
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.addSubview(stack)
    
        stack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stack.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
        locationButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        locationButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        pitchButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        pitchButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    
    func updateLocationButton(isMapCentered: Bool)
    {
        locationButton.configuration?.baseForegroundColor = isMapCentered ? .systemBlue : .systemGray
    }
    
    func updatePitchButton(isPitchActive: Bool)
    {
        pitchButton.configuration?.image = UIImage(systemName: isPitchActive ? "view.2d" : "view.3d", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
    }
}

#Preview
{
    MapView()
}
