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
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(locationButton)
        return stack
    }()
    
    lazy var locationButton: UIButton =
    {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.background.cornerRadius = 25
        
        button.configuration?.baseForegroundColor = .systemBlue
        button.configuration?.baseBackgroundColor = UIColor(named: button.isSelected ? "ButtonSelected" : "ButtonUnselected")
        button.layer.shadowRadius = 1.5
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowColor = UIColor.black.withAlphaComponent(0.35).cgColor
        button.layer.shadowOpacity = 1
        
        button.configuration?.image = UIImage(systemName: "location.fill")
        
        button.addAction(UIAction { [weak self] _ in self?.mapView?.location.requestLocation(reason: .locationButtonTapped) }, for: .touchUpInside)

        return button
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.addSubview(stack)
    
    
        stack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stack.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    
        locationButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        locationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func updateIcon()
    {
        guard let map = mapView else { return }
        
        locationButton.configuration?.baseForegroundColor = map.isCenteredOnLocation ? .systemBlue : .systemGray
    }
}
