import UIKit

class MapSheet: UIViewController
{
    enum SheetState
    {
        case minimized
        case maximized
    }
    
    private let blurEffectView: UIVisualEffectView =
    {
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        return blurEffectView
    }()
    
    private var currentState: SheetState = .minimized
    
    // sheet config
    private let minimizedHeight: CGFloat = 100
    private let maximizedHeight: CGFloat = 250
    private let cornerRadius: CGFloat = 30
    private let stretchResistance: CGFloat = 0.5
    private let maxStretchHeight: CGFloat = 30
    
    private var heightConstraint: NSLayoutConstraint?
    
    private lazy var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupView()
        view.addGestureRecognizer(panGesture)
    }
    
    private func setupView()
    {
        view.addSubview(blurEffectView)
        
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // overlay blur onto sheet (same dimensions)
        blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        blurEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    override func didMove(toParent parent: UIViewController?)
    {
        super.didMove(toParent: parent)
        
        guard let parentView = parent?.view else { return }
        
        // Setup constraints for the view itself
        view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        
        heightConstraint = view.heightAnchor.constraint(equalToConstant: minimizedHeight)
        heightConstraint?.isActive = true
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer)
    {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state
        {
            case .changed:
                let baseHeight = currentState == .maximized ? maximizedHeight : minimizedHeight
                var newHeight = baseHeight - translation.y
                
                // Apply resistance when stretching beyond maximizedHeight
                if newHeight > maximizedHeight
                {
                    let extraStretch = newHeight - maximizedHeight
                    let resistedStretch = extraStretch * stretchResistance
                    newHeight = maximizedHeight + resistedStretch
                    
                    // Limit maximum stretch
                    newHeight = min(maximizedHeight + maxStretchHeight, newHeight)
                }
                else if newHeight < minimizedHeight
                {
                    let extraCompression = minimizedHeight - newHeight
                    let resistedCompression = extraCompression * stretchResistance
                    newHeight = minimizedHeight - resistedCompression
                    
                    // Limit maximum compression
                    newHeight = max(minimizedHeight - maxStretchHeight, newHeight)
                }
                
                newHeight = max(minimizedHeight - maxStretchHeight, newHeight)
                
                heightConstraint?.constant = newHeight
                
            case .ended:
                let currentHeight = heightConstraint?.constant ?? minimizedHeight
                let midPoint = (maximizedHeight + minimizedHeight) / 2
                
                if currentHeight > maximizedHeight {
                    animateSheet(to: .maximized)
                }
                else if velocity.y > 500 {
                    animateSheet(to: .minimized)
                }
                else if currentHeight > midPoint {
                    animateSheet(to: .maximized)
                }
                else {
                    animateSheet(to: .minimized)
                }
                
            default: break
        }
    }
    
    private func animateSheet(to state: SheetState)
    {
        let height = state == .maximized ? maximizedHeight : minimizedHeight
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [.curveEaseOut])
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

#Preview
{
    MapView()
}
