import UIKit
import MapKit

class MapControls: UIViewController 
{
    weak var map: ActivityPicker?
    
    func setup(map: ActivityPicker)
    {
        self.map = map
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func constraints(activate: Bool = true)
    {
        guard let map else { return }
        
        let a = self.view.bottomAnchor.constraint(equalTo: map.sheet.view.topAnchor, constant: -10)
        a.priority = .defaultLow
        a.isActive = activate
        
        let c = self.view.bottomAnchor.constraint(lessThanOrEqualTo: map.map.safeAreaLayoutGuide.bottomAnchor, constant: -6)
        c.priority = .required
        c.isActive = true
        
        self.view.trailingAnchor.constraint(equalTo: map.view.trailingAnchor, constant: -10).isActive = true
    }
    
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
        
        button.configuration?.baseForegroundColor = .systemGray
        button.configuration?.baseBackgroundColor = .buttonUnselected
        button.layer.shadowRadius = 1.5
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowColor = UIColor.black.withAlphaComponent(0.35).cgColor
        button.layer.shadowOpacity = 1
        
        button.configuration?.image = UIImage(systemName: "location.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        button.configuration?.preferredSymbolConfigurationForImage = .init(pointSize: 14)
        
        let action = UIAction 
        { [weak self] _ in
            if let lastLocation = self?.map?.location.location
            {
                if Date().timeIntervalSince(lastLocation.timestamp) <= 15
                {
                    self?.map?.centerMap(on: lastLocation)
                }
            }
            else
            {
                self?.map?.location.requestLocation(reason: .locationButtonTapped)
            }
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
        
        button.addAction(UIAction{ [weak self] _ in self?.map?.togglePitch() }, for: .touchUpInside)
        
        return button
    }()
    
    lazy var compassButton: MKCompassButton =
    {
        let compass = MKCompassButton()
        compass.mapView = map?.map
        compass.compassVisibility = .visible
        compass.layer.shadowRadius = 1.5
        compass.layer.shadowOffset = CGSize(width: 0, height: 1)
        compass.layer.shadowColor = UIColor.black.withAlphaComponent(0.35).cgColor
        compass.layer.shadowOpacity = 1
        compass.alpha = 0.9
        
        compass.backgroundColor = .systemBlue
        compass.layer.cornerRadius = 45 / 2
        compass.layer.masksToBounds = true
        compass.clipsToBounds = true
        compass.tintColor = .red
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
    ActivityPicker()
}
