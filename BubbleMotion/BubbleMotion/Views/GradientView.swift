import Foundation
import UIKit

@IBDesignable
final class GradientView: UIView {
    @IBInspectable var startColor: UIColor = UIColor.clear
    @IBInspectable var endColor: UIColor = UIColor.clear
    
    override func draw(_ rect: CGRect) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRect(x: CGFloat(-100),
                                y: CGFloat(-100),
                                width: superview!.frame.size.width + 200,
                                height: superview!.frame.size.height + 200)
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        layer.addSublayer(gradient)
        ViewUtils.addParallaxToView(vw: self)
    }
}
