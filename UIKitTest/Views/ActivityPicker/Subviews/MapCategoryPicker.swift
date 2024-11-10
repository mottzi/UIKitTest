import UIKit

extension MapCategoryPicker
{
    func setup(map: MapView)
    {
        self.map = map
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.backgroundColor = .clear
    }
    
    func constraints(activate: Bool = true)
    {
        guard let map = self.parent as? MapView else { return }
        
        self.view.leadingAnchor.constraint(equalTo: map.view.safeAreaLayoutGuide.leadingAnchor).isActive = activate
        self.view.trailingAnchor.constraint(equalTo: map.view.safeAreaLayoutGuide.trailingAnchor).isActive = activate
        self.view.topAnchor.constraint(equalTo: map.view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = activate
    }
}

class MapCategoryPicker: UIViewController
{
    public let haptics = UISelectionFeedbackGenerator()
    
    weak var map: MapView?
    
    private lazy var scrollview: UIScrollView =
    {
        let scrollview = UIScrollView()
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        scrollview.layer.masksToBounds = false
        return scrollview
    }()
    
    private lazy var stackview: UIStackView =
    {
        let stackview = UIStackView()
        stackview.axis = .horizontal
        stackview.spacing = 8
        stackview.translatesAutoresizingMaskIntoConstraints = false
        return stackview
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        loadButtons(into: stackview)
        scrollview.addSubview(stackview)
        
        self.view.addSubview(scrollview)
        
        NSLayoutConstraint.activate(controlConstraints)
    }
    
    private lazy var controlConstraints: [NSLayoutConstraint] =
    [
        scrollview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        scrollview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        scrollview.topAnchor.constraint(equalTo: view.topAnchor),
        scrollview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        
        stackview.leadingAnchor.constraint(equalTo: scrollview.contentLayoutGuide.leadingAnchor, constant: 12),
        stackview.trailingAnchor.constraint(equalTo: scrollview.contentLayoutGuide.trailingAnchor, constant: -12),
        stackview.topAnchor.constraint(equalTo: scrollview.contentLayoutGuide.topAnchor),
                
        self.view.heightAnchor.constraint(equalTo: stackview.heightAnchor, constant: 0)
    ]
    
    private func loadButtons(into view: UIStackView)
    {
        for category in MapCategory.allCategories
        {
            let button = MapCategoryButton(category: category, root: map)
            view.addArrangedSubview(button)
        }
    }
    
    public func sortButtons()
    {
        let buttons = stackview.arrangedSubviews.compactMap { $0 as? MapCategoryButton }
        let sortedButtons = buttons.sorted { $0.isSelected && !$1.isSelected }
             
        for button in sortedButtons
        {
            stackview.removeArrangedSubview(button)
            stackview.addArrangedSubview(button)
        }

        stackview.layoutIfNeeded()
    }
    
    public func getSelectedCategories() -> [MapCategory]
    {
        let selectedCategories = stackview.arrangedSubviews.compactMap { $0 as? MapCategoryButton }
            .filter { $0.isSelected }
            .map { $0.category }
        
        return selectedCategories
    }
    
    public func resetOffset()
    {
        scrollview.setContentOffset(.zero, animated: false)
    }
    
    public func sortAndReset(animated: Bool = true)
    {
        if animated
        {
            UIView.bouncyAnimation()
            {
                self.sortButtons()
                self.resetOffset()
            }
        }
        else
        {
            sortButtons()
            resetOffset()
        }
    }
    
    func isButtonSelected(category: MapCategory) -> Bool
    {
        let button = stackview.arrangedSubviews
            .compactMap { $0 as? MapCategoryButton }
            .first { $0.category == category }
        
        guard let button else { return false }
        
        return button.isSelected
    }
}

#Preview
{
    MapView()
}
