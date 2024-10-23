import UIKit

class CategoryButton: UIButton
{
    let title: String
    let icon: String
    
    weak var parent: HorizontalCategoryPicker?
    
    init(title: String, icon: String, parent: HorizontalCategoryPicker?)
    {
        self.title = title
        self.icon = icon
        self.parent = parent
        
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
        
        parent?.sortButtons()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
