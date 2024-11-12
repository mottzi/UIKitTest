import UIKit

class MapAnnotationControl: UIViewController
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
        
        let c = self.view.bottomAnchor.constraint(lessThanOrEqualTo: map.map.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        c.priority = .required
        c.isActive = true
        
        self.view.leadingAnchor.constraint(equalTo: map.view.leadingAnchor, constant: 20).isActive = true
    }
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(annotationButton)
        return stack
    }()
    
    lazy var annotationButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.background.cornerRadius = 25
        
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 10, bottom: 8, trailing: 14)

        button.configuration?.attributedTitle = AttributedString("Add to chat", attributes: AttributeContainer([.font: UIFont.preferredFont(for: .headline, weight: .semibold)]))
        button.configuration?.baseForegroundColor = .systemBlue
        button.configuration?.baseBackgroundColor = .buttonUnselected
        
        button.layer.shadowRadius = 1.5
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowColor = UIColor.black.withAlphaComponent(0.35).cgColor
        button.layer.shadowOpacity = 1
        
        button.configuration?.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        button.configuration?.preferredSymbolConfigurationForImage = .init(pointSize: 13)
        button.configuration?.imagePadding = 4

        // Add your button action here
        button.addAction(UIAction { [weak self] _ in self?.buttonTapped() }, for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(stack)
        
        stack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stack.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
//        annotationButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
//        annotationButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        annotationButton.alpha = 0
    }
    
    func buttonTapped()
    {
        if let annotation = map?.sheet.resultPicker.getCurrentCardAnnotation()
        {
            print("MapAnnotationControl: \(annotation.title ?? "No title")")
        }
    }
    
    func updateOpacity(_ opacity: CGFloat) { annotationButton.alpha = opacity }
}

#Preview
{
    ActivityPicker()
}
