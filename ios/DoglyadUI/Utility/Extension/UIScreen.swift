import UIKit

extension UIScreen {
    public var cornerRadius: CGFloat {
        self.value(forKey:"_displayCornerRadius") as? CGFloat ?? 16.0
     }
}
