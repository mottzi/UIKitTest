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
        scrollview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        scrollview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        scrollview.topAnchor.constraint(equalTo: view.topAnchor),
        scrollview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        
        stackview.leadingAnchor.constraint(equalTo: scrollview.contentLayoutGuide.leadingAnchor, constant: 12),
        stackview.trailingAnchor.constraint(equalTo: scrollview.contentLayoutGuide.trailingAnchor, constant: -12),
        stackview.topAnchor.constraint(equalTo: scrollview.contentLayoutGuide.topAnchor),
        stackview.bottomAnchor.constraint(equalTo: scrollview.contentLayoutGuide.bottomAnchor),
        
        stackview.heightAnchor.constraint(equalTo: scrollview.frameLayoutGuide.heightAnchor),
        
        //stackview.widthAnchor.constraint(greaterThanOrEqualTo: scrollview.frameLayoutGuide.widthAnchor, constant: -24)
    ]
}

#Preview
{
    MapView()
}
