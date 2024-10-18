import UIKit
import MapKit

class ViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let categoryPicker = CategoryPicker(categories: MapCategory.allCategories)
        categoryPicker.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(categoryPicker)
        
        NSLayoutConstraint.activate([
            categoryPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryPicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
//            categoryPicker.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}

#Preview
{
    ViewController()
}

class CategoryPicker: UIView
{
    var scrollView: UIScrollView
    var stackView: UIStackView
    
    // Initialize the picker with categories
    init(categories: [MapCategory])
    {
        self.scrollView = UIScrollView()
        self.stackView = UIStackView()
        
        super.init(frame: .zero)
        
        // Setup UI elements
        setupScrollView()
        setupStackView()
        addCategoryButtons(categories: categories)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Setup the scroll view
    private func setupScrollView()
    {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView)
        
        // ScrollView constraints
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    // Setup the stack view inside the scroll view
    private func setupStackView()
    {
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(stackView)
        
        // StackView constraints to enable horizontal scrolling
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    // Add category buttons to the stack view
    private func addCategoryButtons(categories: [MapCategory])
    {
        for category in categories
        {
            let button = CategoryButton(category: category)
            stackView.addArrangedSubview(button)
            
            // Set fixed width for buttons if needed
//            button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        }
    }
}

class CategoryButton: UIButton
{
    var category: MapCategory
    
    // To track selection state
    var isSelectedCategory: Bool = false 
    {
        didSet 
        {
            updateButtonAppearance()
        }
    }
    
    init(category: MapCategory)
    {
        self.category = category
        super.init(frame: .zero)
        
        // Set button properties like title and icon
        setupButton()
        
        // Add target to handle tap
        self.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) 
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Setup the button UI
    private func setupButton()
    {
        // Create a configuration for the button
        var config = UIButton.Configuration.plain()
        
        // Set title
        config.title = category.title
        config.titleAlignment = .center
        config.baseForegroundColor = .black
        
        // Set icon
        config.image = UIImage(systemName: category.icon)
        config.imagePlacement = .leading
        config.imagePadding = 6 // Padding between image and title
                
        // Set padding around the button content
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 11, bottom: 6, trailing: 11)
        
        // Assign the configuration to the button
        self.configuration = config
        
        // Update the button appearance for initial state
        updateButtonAppearance()
    }
    
    // Update button appearance based on its selection state
    private func updateButtonAppearance()
    {
        if isSelectedCategory
        {
            self.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
        }
        else
        {
            self.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
        }
        
        // Apply common styles
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 2
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    // Handle button tap
    @objc private func buttonTapped()
    {
        isSelectedCategory.toggle() // Toggle the button state
    }
}

struct MapCategory
{
    let id: UUID = UUID()
    let title: String
    let icon: String
    
    // Example of predefined categories (similar to your original SwiftUI code)
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
