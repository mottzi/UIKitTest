import UIKit
import MapKit

class MapCategoryButton: UIButton
{
    let category: MapCategory
    
    weak var map: ActivityPicker?
    
    init(category: MapCategory, root: ActivityPicker?)
    {
        self.category = category
        self.map = root

        super.init(frame: .zero)
        
        setupButton()
    }
    
    private func setupButton()
    {
        // shape
        self.configuration = .filled()
        self.configuration?.cornerStyle = .capsule
        self.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 10)
        
        // set background and foreground colors
        self.configuration?.baseBackgroundColor = UIColor(named: self.isSelected ? "ButtonSelected" : "ButtonUnselected")
        self.configuration?.baseForegroundColor = .buttonTextUnselected
        
        // shadow settings
        self.layer.shadowRadius = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.35).cgColor
        self.layer.shadowOpacity = 1
        
        // title
        self.configuration?.attributedTitle = AttributedString(
            category.title,
            attributes: AttributeContainer([.font: UIFont.preferredFont(for: .subheadline, weight: .medium)])
        )
        
        // icon
        let originalImage = UIImage(systemName: category.icon, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!
        let resizedIcon = originalImage.scaledToFit(height: 20)?.withRenderingMode(.alwaysTemplate)
        
        self.configuration?.image = resizedIcon
        self.configuration?.imagePadding = 4
        
        // width based on content
        self.setContentHuggingPriority(.required, for: .horizontal)
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // button handler
        self.addAction(UIAction { [weak self] _ in self?.toggleButton() }, for: .touchUpInside)
    }
    
    // loads or removes annotations, then shows or hides sheet with result picker
    private func toggleButton()
    {
        self.isSelected.toggle()
        map?.categoryPicker.haptics.selectionChanged()
        
        self.configuration?.baseBackgroundColor = self.isSelected ? .buttonSelected : .buttonUnselected
        self.configuration?.baseForegroundColor = self.isSelected ? .buttonTextSelected : .buttonTextUnselected

        if self.isSelected
        {
            Task.detached()
            {
                await self.map?.requestAnnotations(category: self.category, from: .apple)
                await self.map?.requestAnnotations(category: self.category, from: .osm)

                await self.map?.sheet.resultPicker.refresh()
            }
        }
        else
        {
            self.map?.removeAnnotations(category: self.category)
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

#Preview
{
    ActivityPicker()
}
