import UIKit

class HorizontalCategoryPicker: UIViewController
{
    let scrollview = UIScrollView()
    let stack = UIStackView()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        for category in MapCategory.allCategories
        {
            stack.addArrangedSubview(CustomButton(title: category.title, icon: category.icon))
        }
        
        scrollview.addSubview(stack)

        self.view.addSubview(scrollview)

        NSLayoutConstraint.activate(controlConstraints)
    }
    
    lazy var controlConstraints: [NSLayoutConstraint] =
    [
        // scroll view constraints
        scrollview.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        scrollview.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        scrollview.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
        scrollview.heightAnchor.constraint(equalTo: stack.heightAnchor),
        
        // stack view constraints
        stack.leadingAnchor.constraint(equalTo: scrollview.leadingAnchor, constant: 12),
        stack.trailingAnchor.constraint(equalTo: scrollview.trailingAnchor, constant: -12),
        stack.topAnchor.constraint(equalTo: scrollview.topAnchor),
        stack.bottomAnchor.constraint(equalTo: scrollview.bottomAnchor),
    ]
}

class CustomButton: UIButton
{
    let title: String
    let icon: String
        
    init(title: String, icon: String)
    {
        self.title = title
        self.icon = icon
        
        super.init(frame: .zero)
        
        setupButton()
    }
        
    private func setupButton()
    {
        // shape
        self.configuration = .filled()
        self.configuration?.cornerStyle = .capsule
        self.configuration?.baseForegroundColor = .darkText
        self.configuration?.baseBackgroundColor = UIColor(named: self.isSelected ? "ButtonSelected" : "ButtonUnselected")
        
        // title
        self.configuration?.attributedTitle = AttributedString(self.title, attributes: AttributeContainer([.font: UIFont.boldSystemFont(ofSize: 16)]))
        
        // icon
        self.configuration?.image = UIImage(systemName: self.icon)
        self.configuration?.imagePadding = 4
        self.configuration?.preferredSymbolConfigurationForImage = .init(font: .boldSystemFont(ofSize: 14))
        
        // width based on content
        self.setContentHuggingPriority(.required, for: .horizontal)
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // button handler
        self.addAction(UIAction { [weak self] _ in self?.toggleButton() }, for: .touchUpInside)
    }
        
    private func toggleButton()
    {
        self.isSelected.toggle()
        
        self.configuration?.baseBackgroundColor = UIColor(named: self.isSelected ? "ButtonSelected" : "ButtonUnselected")

        if self.isSelected
        {
            if let stack = self.superview as? UIStackView
            {
                var index = 0
                for view in stack.arrangedSubviews
                {
                    if let button = view as? CustomButton, button.isSelected, button != self
                    {
                        index += 1
                    }
                }
                
                UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseInOut)
                {
                    stack.removeArrangedSubview(self)
                    self.removeFromSuperview()
                    
                    stack.insertArrangedSubview(self, at: index)
                    
                    stack.layoutIfNeeded()
                }
            }
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

struct MapCategory
{
    let title: String
    let icon: String
        
    static let allCategories: [MapCategory] =
    [
        MapCategory(title: "Movies", icon: "film"),
        MapCategory(title: "Park", icon: "leaf"),
        MapCategory(title: "Eat", icon: "fork.knife"),
        MapCategory(title: "Sport", icon: "sportscourt"),
        MapCategory(title: "Museum", icon: "building.columns"),
        MapCategory(title: "Zoo", icon: "tortoise"),
        MapCategory(title: "Amusement", icon: "sparkles")
    ]
}

#Preview
{
    HorizontalCategoryPicker()
}
