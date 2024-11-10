import UIKit

enum SheetState: CGFloat
{
    case hidden = 0
    case minimized = 110
    case maximized = 190
    
    static let heightDelta: CGFloat = maximized.rawValue - minimized.rawValue
    
    static let cornerRadius: CGFloat = 0
    static let maxStretchHeight: CGFloat = 35
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
    
    let cards = MapResultPicker()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupSheet()
        setupContent()
    }
    
    private func setupContent()
    {
        addChild(cards)
        view.addSubview(cards.view)
        cards.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cards.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cards.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cards.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            cards.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        sheetHeight = view.heightAnchor.constraint(equalToConstant: sheetState.rawValue)

        cards.didMove(toParent: self)
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
        guard let root = parent as? MapView else { return }
        
        let currentHeight = sheetHeight?.constant ?? SheetState.minimized.rawValue
        let midPoint = (SheetState.maximized.rawValue + SheetState.minimized.rawValue) / 2
        
        let currentIndex = Int(cards.collection.contentOffset.x / cards.collection.bounds.width)
        
        if velocity.y > 500
        {
            animateSheet(to: .minimized)
            
            root.map.selectedAnnotations.forEach()
            {
                root.map.deselectAnnotation($0, animated: true)
            }
        }
        else if velocity.y < -500
        {
            animateSheet(to: .maximized)
            
            if cards.annotations.count > 0
            {
                if (0..<cards.annotations.count).contains(currentIndex)
                {
                    cards.selectAnnotation(cards.annotations[currentIndex], on: root.map)
                }
            }
        }
        else if currentHeight > midPoint
        {
            animateSheet(to: .maximized)
            
            if cards.annotations.count > 0
            {
                if (0..<cards.annotations.count).contains(currentIndex)
                {
                    cards.selectAnnotation(cards.annotations[currentIndex], on: root.map)
                }
            }
        }
        else
        {
            animateSheet(to: .minimized)
            
            root.map.selectedAnnotations.forEach()
            {
                root.map.deselectAnnotation($0, animated: true)
            }
        }
    }
    
    func animateSheet(to finalState: SheetState)
    {
        sheetAnimator?.stopAnimation(true)
        
        var duration = 0.5
        var damping = 0.6
        
        if self.sheetState == .minimized && finalState == .hidden
        {
            duration = 1.0
            damping = 1.0
        }
        else if self.sheetState == .maximized && finalState == .hidden
        {
            duration = 1.2
            damping = 1.0
        }
        else if self.sheetState == .hidden && finalState == .minimized
        {
            duration = 1.0
            damping = 1.0
        }
        
        self.sheetState = finalState
                
        sheetAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: damping)
        {
            self.sheetHeight?.constant = finalState.rawValue
            self.view.setNeedsLayout()
            self.parent?.view.layoutIfNeeded()
        }

        sheetAnimator?.startAnimation()
    }
}

#Preview
{
    MapView()
}
