import UIKit

class HorizontalCategoryPicker: UIViewController
{
    override func viewDidLoad() 
    {
        super.viewDidLoad()
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        
        stack.addArrangedSubview(CustomButton(title: "Category", icon: "bolt.fill"))
        stack.addArrangedSubview(CustomButton(title: "Category", icon: "tree"))

        stack.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
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
        self.configuration = .filled()
        self.configuration?.cornerStyle = .capsule
        self.configuration?.attributedTitle = AttributedString(self.title, attributes: AttributeContainer([.font: UIFont.boldSystemFont(ofSize: 16)]))
        self.configuration?.image = UIImage(systemName: self.icon)
        self.configuration?.imagePadding = 4
        self.configuration?.preferredSymbolConfigurationForImage = .init(font: .boldSystemFont(ofSize: 14))
        self.configuration?.baseForegroundColor = .darkText
        self.configuration?.baseBackgroundColor = self.isSelected ? .systemBlue.withAlphaComponent(0.8) : .systemBlue.withAlphaComponent(0.3)

        self.addTarget(self, action: #selector(onButtonTap), for: .touchUpInside)
    }
    
    @objc func onButtonTap()
    {
        self.isSelected.toggle()
        
        self.configuration?.baseBackgroundColor = self.isSelected ? .systemBlue.withAlphaComponent(0.8) : .systemBlue.withAlphaComponent(0.3)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

#Preview
{
    HorizontalCategoryPicker()
}
