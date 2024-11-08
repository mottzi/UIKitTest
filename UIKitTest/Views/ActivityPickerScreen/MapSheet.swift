import UIKit

enum SheetState: CGFloat
{
    case hidden = 0
    case minimized = 110
    case maximized = 190
    
    static let heightDelta: CGFloat = maximized.rawValue - minimized.rawValue
    
    static let cornerRadius: CGFloat = 0
    static let maxStretchHeight: CGFloat = 30
    static let stretchResistance: CGFloat = 0.5
}

class MapSheet: UIViewController
{
    var sheetState: SheetState = .hidden
    var sheetHeight: NSLayoutConstraint?
    var sheetAnimator: UIViewPropertyAnimator?
    lazy var sheetGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSheetGesture))

    let sheetBlur: UIVisualEffectView =
    {
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        return blurEffectView
    }()
    
    let content = MapResultPicker()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupSheet()
        setupContent()
    }
    
    private func setupContent()
    {
        addChild(content)
        view.addSubview(content.view)
        content.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            content.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            content.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            content.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            content.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        sheetHeight = view.heightAnchor.constraint(equalToConstant: sheetState.rawValue)

        content.didMove(toParent: self)
    }

    private func setupSheet()
    {
        view.addSubview(sheetBlur)
        view.addGestureRecognizer(sheetGesture)

        view.layer.cornerRadius = SheetState.cornerRadius
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        sheetBlur.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        sheetBlur.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        sheetBlur.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        sheetBlur.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func constraints(active: Bool = true)
    {
        guard let parentView = parent?.view else { return }
        
        view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        
        sheetHeight = view.heightAnchor.constraint(equalToConstant: sheetState.rawValue)
        sheetHeight?.isActive = true
    }
    
    @objc private func handleSheetGesture(_ gesture: UIPanGestureRecognizer)
    {
        let translation = gesture.translation(in: self.view)
        let velocity = gesture.velocity(in: self.view)
        
        switch gesture.state
        {
            case .began: handleGestureBegan()
            case .changed: handleGestureChanged(translation)
            case .ended: handleGestureEnded(velocity)
                
            default: break
        }
    }
    
    private func handleGestureBegan()
    {
        sheetAnimator?.stopAnimation(true)
        
        let currentHeight = sheetHeight?.constant ?? SheetState.minimized.rawValue
        
        if currentHeight > (SheetState.maximized.rawValue + SheetState.minimized.rawValue) / 2
        {
            sheetState = .maximized
        }
        else
        {
            sheetState = .minimized
        }
    }
    
    private func handleGestureChanged(_ translation: CGPoint)
    {
        var newHeight = sheetState.rawValue - translation.y
        
        if newHeight > SheetState.maximized.rawValue
        {
            let extraStretch = newHeight - SheetState.maximized.rawValue
            let resistedStretch = extraStretch * SheetState.stretchResistance
            newHeight = SheetState.maximized.rawValue + resistedStretch
            newHeight = min(SheetState.maximized.rawValue + SheetState.maxStretchHeight, newHeight)
        }
        else if newHeight < SheetState.minimized.rawValue
        {
            let extraCompression = SheetState.minimized.rawValue - newHeight
            let resistedCompression = extraCompression * SheetState.stretchResistance
            newHeight = SheetState.minimized.rawValue - resistedCompression
            newHeight = max(SheetState.minimized.rawValue - SheetState.maxStretchHeight, newHeight)
        }
        
        sheetHeight?.constant = newHeight
    }
    
    private func handleGestureEnded(_ velocity: CGPoint)
    {
        let currentHeight = sheetHeight?.constant ?? SheetState.minimized.rawValue
        let midPoint = (SheetState.maximized.rawValue + SheetState.minimized.rawValue) / 2
        
        if velocity.y > 500
        {
            animateSheet(to: .minimized)
        }
        else if velocity.y < -500
        {
            animateSheet(to: .maximized)
        }
        else if currentHeight > midPoint
        {
            animateSheet(to: .maximized)
        }
        else
        {
            animateSheet(to: .minimized)
        }
    }
    
    func animateSheet(to finalState: SheetState)
    {
        sheetAnimator?.stopAnimation(true)
                
        sheetAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.6)
        {
            self.sheetHeight?.constant = finalState.rawValue
            self.view.setNeedsLayout()
            self.parent?.view.layoutIfNeeded()
        }
        
        sheetAnimator?.addCompletion()
        { [weak self] _ in
            guard let self else { return }
            guard sheetState != finalState else { return }
            
            self.sheetState = finalState
//            self.updateSheetStateLabel()
        }
        
        sheetAnimator?.startAnimation()
    }
}

#Preview
{
    MapView()
}
