import UIKit

extension UIImage 
{
    func scaledToFit(height: CGFloat) -> UIImage?
    {
        let aspectRatio = self.size.width / self.size.height
        let newSize = CGSize(width: height * aspectRatio, height: height)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        let newImage = renderer.image
        { context in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return newImage
    }
}
