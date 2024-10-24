import UIKit

class CategoryButton: UIButton
{
    let title: String
    let icon: String
    
    weak var picker: HorizontalCategoryPicker?
    
    init(title: String, icon: String, picker: HorizontalCategoryPicker?)
    {
        self.title = title
        self.icon = icon
        self.picker = picker
        
        super.init(frame: .zero)
        
        setupButton()
    }
    
    private func setupButton()
    {
        // shape
        self.configuration = .filled()
        self.configuration?.cornerStyle = .capsule
        self.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 10)

        self.configuration?.baseForegroundColor = .darkText
        self.configuration?.baseBackgroundColor = UIColor(named: self.isSelected ? "ButtonSelected" : "ButtonUnselected")
        self.layer.shadowRadius = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.35).cgColor
        self.layer.shadowOpacity = 1
        
        // title
        self.configuration?.attributedTitle = AttributedString(self.title, attributes: AttributeContainer([.font: UIFont.preferredFont(for: .subheadline, weight: .medium)]))
        
        // icon
        let originalImage = UIImage(systemName: self.icon, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!
        let resizedIcon = originalImage.scaledToFit(height: 18)
        
        self.configuration?.image = resizedIcon
        self.configuration?.imagePadding = 4

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
        
        picker?.sortButtons()
        picker?.haptics.selectionChanged()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

#Preview
{
    MapView()
}
