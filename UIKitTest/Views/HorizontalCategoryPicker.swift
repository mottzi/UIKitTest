import UIKit

class HorizontalCategoryPicker: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
               
        loadButtons(into: stackview)
        scrollview.addSubview(stackview)

        self.view.addSubview(scrollview)
        self.view.backgroundColor = .systemBackground

        NSLayoutConstraint.activate(controlConstraints)
    }
    
    private lazy var scrollview: UIScrollView =
    {
        let scrollview = UIScrollView()
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.translatesAutoresizingMaskIntoConstraints = false
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
    
    private lazy var controlConstraints: [NSLayoutConstraint] =
    [
        // scroll view constraints
        scrollview.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        scrollview.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        scrollview.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 33),
        scrollview.heightAnchor.constraint(equalTo: stackview.heightAnchor),
        
        // stack view constraints
        stackview.leadingAnchor.constraint(equalTo: scrollview.leadingAnchor, constant: 12),
        stackview.trailingAnchor.constraint(equalTo: scrollview.trailingAnchor, constant: -12),
        stackview.topAnchor.constraint(equalTo: scrollview.topAnchor),
        stackview.bottomAnchor.constraint(equalTo: scrollview.bottomAnchor),
    ]
    
    private func loadButtons(into view: UIStackView)
    {
        for category in MapCategory.allCategories
        {
            view.addArrangedSubview(CategoryButton(title: category.title, icon: category.icon, parent: self))
        }
    }
    
    public func sortButtons()
    {
        // Retrieve all buttons from the stack's arranged subviews
        let buttons = stackview.arrangedSubviews.compactMap { $0 as? CategoryButton }
        
        // Sort buttons with selected ones first
        let sortedButtons = buttons.sorted { $0.isSelected && !$1.isSelected }
        
        // Remove all existing arranged subviews from the stack
        for button in buttons
        {
            stackview.removeArrangedSubview(button)
        }
                
        // Add the sorted buttons back into the stack
        for button in sortedButtons
        {
            stackview.addArrangedSubview(button)
        }
        
        // animate the layout change
        UIView.animate(withDuration: 0.7,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveEaseIn)
        {
            self.stackview.layoutIfNeeded()
        }
    }
}

#Preview
{
    HorizontalCategoryPicker()
}
