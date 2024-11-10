import UIKit

class MapCategoryPicker: UIViewController
{
    public let haptics = UISelectionFeedbackGenerator()
    
    weak var map: MapView?
    
    let scrollview: UIScrollView = UIScrollView()
    let stackview: UIStackView = UIStackView()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupSubViews()
    }
    
    private func setupSubViews()
    {
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        scrollview.layer.masksToBounds = false
        
        stackview.axis = .horizontal
        stackview.spacing = 8
        stackview.translatesAutoresizingMaskIntoConstraints = false
        
        loadButtons(into: stackview)
        scrollview.addSubview(stackview)
        
        view.addSubview(scrollview)
        setupConstraints()
    }
    
    private func setupConstraints()
    {
        NSLayoutConstraint.activate([
            scrollview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollview.topAnchor.constraint(equalTo: view.topAnchor),
            scrollview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackview.leadingAnchor.constraint(equalTo: scrollview.contentLayoutGuide.leadingAnchor, constant: 12),
            stackview.trailingAnchor.constraint(equalTo: scrollview.contentLayoutGuide.trailingAnchor, constant: -12),
            stackview.topAnchor.constraint(equalTo: scrollview.contentLayoutGuide.topAnchor),
            
            self.view.heightAnchor.constraint(equalTo: stackview.heightAnchor, constant: 0)
        ])
    }
    
    // adds all category buttons to the stack
    private func loadButtons(into view: UIStackView)
    {
        for category in MapCategory.allCategories
        {
            let button = MapCategoryButton(category: category, root: map)
            view.addArrangedSubview(button)
        }
    }
}

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

extension MapCategoryPicker
{
    // returns an array of selected category buttons
    func getSelectedCategories() -> [MapCategory]
    {
        let selectedCategories = stackview.arrangedSubviews.compactMap { $0 as? MapCategoryButton }
            .filter { $0.isSelected }
            .map { $0.category }
        
        return selectedCategories
    }
    
    // sorts the category buttons inside the stack based on selection status
    func sortButtons()
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
    
    // scrolls to the start of the button stack
    func resetOffset()
    {
        scrollview.setContentOffset(.zero, animated: false)
    }
    
    // sort buttons and scroll to start
    func reset(animated: Bool = true)
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
    
    // returns true if the category button has been selected
    func isCategorySelected(category: MapCategory) -> Bool
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
