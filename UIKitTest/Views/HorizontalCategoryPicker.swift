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
    
    private func loadButtons(into view: UIStackView)
    {
        for category in MapCategory.allCategories
        {
            let button = CategoryButton(title: category.title, icon: category.icon, parent: self)
            view.addArrangedSubview(button)
        }
    }
    
    public func sortButtons()
    {
        let buttons = stackview.arrangedSubviews.compactMap { $0 as? CategoryButton }
        let sortedButtons = buttons.sorted { $0.isSelected && !$1.isSelected }
             
        for button in sortedButtons
        {
            stackview.removeArrangedSubview(button)
            stackview.addArrangedSubview(button)
        }
        
        UIView.bouncyAnimation()
        {
            self.stackview.layoutIfNeeded()
        }
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
        scrollview.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
        scrollview.heightAnchor.constraint(equalTo: stackview.heightAnchor, constant: 20),
        
        // stack view constraints
        stackview.leadingAnchor.constraint(equalTo: scrollview.leadingAnchor, constant: 12),
        stackview.trailingAnchor.constraint(equalTo: scrollview.trailingAnchor, constant: -12),
        stackview.topAnchor.constraint(equalTo: scrollview.topAnchor, constant: 10),
        stackview.bottomAnchor.constraint(equalTo: scrollview.bottomAnchor),
    ]
}

#Preview
{
    HorizontalCategoryPicker()
}
