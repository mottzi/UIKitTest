import UIKit

enum SheetState: CGFloat
{
    case hidden = 0
    case minimized = 110
    case maximized = 190
    
    static let heightDelta: CGFloat = maximized.rawValue - minimized.rawValue
    static let midPoint: CGFloat = (maximized.rawValue + minimized.rawValue) / 2
    
    static let cornerRadius: CGFloat = 0
    static let maxStretchHeight: CGFloat = 35
    static let stretchResistance: CGFloat = 0.5
}

class MapSheet: UIViewController
{
    weak var map: ActivityPicker?

    var state: SheetState = .hidden
    var height: NSLayoutConstraint?
    var animator: UIViewPropertyAnimator?
    let gesture = UIPanGestureRecognizer()
    
    let resultPicker = MapResultPicker()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupSheet()
        setupContent()
    }
    
    private func setupSheet()
    {
        gesture.addTarget(self, action: #selector(handleSheetGesture))
        
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurEffectView)
        
        view.addGestureRecognizer(gesture)
        
        view.layer.cornerRadius = SheetState.cornerRadius
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        blurEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func setupContent()
    {
        addChild(resultPicker)
        view.addSubview(resultPicker.view)
        resultPicker.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            resultPicker.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultPicker.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultPicker.view.topAnchor.constraint(equalTo: view.topAnchor),
            resultPicker.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        height = view.heightAnchor.constraint(equalToConstant: state.rawValue)

        resultPicker.didMove(toParent: self)
    }
    
    //
    func animateSheet(to finalState: SheetState)
    {
        guard self.state != finalState else { return }
        
        animator?.stopAnimation(true)
        
        var duration = 0.5
        var damping = 0.6
        
        if self.state == .minimized && finalState == .hidden
        {
            duration = 1.0
            damping = 1.0
        }
        else if self.state == .maximized && finalState == .hidden
        {
            duration = 1.2
            damping = 1.0
        }
        else if self.state == .hidden && finalState == .minimized
        {
            duration = 1.0
            damping = 1.0
        }
        
        self.state = finalState
                
        animator = UIViewPropertyAnimator(duration: duration, dampingRatio: damping)
        {
            self.height?.constant = finalState.rawValue
            self.view.setNeedsLayout()
            self.parent?.view.layoutIfNeeded()
        }

        animator?.startAnimation()
    }
}

extension MapSheet
{
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
        animator?.stopAnimation(true)
        
        let currentHeight = height?.constant ?? SheetState.minimized.rawValue
        
        if currentHeight > (SheetState.maximized.rawValue + SheetState.minimized.rawValue) / 2
        {
            state = .maximized
        }
        else
        {
            state = .minimized
        }
    }
    
    private func handleGestureChanged(_ translation: CGPoint)
    {
        var newHeight = state.rawValue - translation.y
        
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
        
        height?.constant = newHeight
    }
    
    private func handleGestureEnded(_ velocity: CGPoint)
    {
        let height = height?.constant ?? SheetState.minimized.rawValue
        
        if velocity.y < -500 || height > SheetState.midPoint
        {
            animateSheet(to: .maximized)
            map?.selectAnnotationOfResult()
        }
        else
        {
            animateSheet(to: .minimized)
            map?.deselectAllSelectedAnnotations()
        }
    }
}

extension MapSheet
{
    func setup(map: ActivityPicker)
    {
        self.map = map
    }
    
    func constraints(active: Bool = true)
    {
        guard let map else { return }
        
        view.leadingAnchor.constraint(equalTo: map.view.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: map.view.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: map.view.bottomAnchor).isActive = true
        
        height = view.heightAnchor.constraint(equalToConstant: state.rawValue)
        height?.isActive = true
    }
}

#Preview
{
    ActivityPicker()
}
