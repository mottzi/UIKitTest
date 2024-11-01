import UIKit
import MapKit

class MapCategoryButton: UIButton
{
    let category: MapCategory
    
    weak var map: MapView?
    weak var picker: MapCategoryPicker?
    
    init(category: MapCategory, map: MapView?, picker: MapCategoryPicker?)
    {
        self.category = category
        self.map = map
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
        self.configuration?.attributedTitle = AttributedString(category.title, attributes: AttributeContainer([.font: UIFont.preferredFont(for: .subheadline, weight: .medium)]))
        
        // icon
        let originalImage = UIImage(systemName: category.icon, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!
        let resizedIcon = originalImage.scaledToFit(height: 20)
        
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
        guard let map = map?.map else { return }
        
        self.isSelected.toggle()
        picker?.haptics.selectionChanged()
        
        self.configuration?.baseBackgroundColor = UIColor(named: self.isSelected ? "ButtonSelected" : "ButtonUnselected")
                
        if self.isSelected
        {
            Task.detached()
            {
                await self.picker?.loadPOIFromRegion(of: [self.category])
            }
        }
        else
        {
            let filtered = map.annotations.filter
            {
                guard let marker = $0 as? MapAnnotation else { return false }
                
                guard let category = marker.mapCategory, category == self.category else { return false }
                
                return true
            }
            
            filtered.forEach 
            {
                self.map?.removeAnnotation($0, animated: true)
            }
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class MapAnnotation: MKPointAnnotation
{
    var mapCategory: MapCategory?
    var identifier: String?
}

#Preview
{
    MapView()
}
