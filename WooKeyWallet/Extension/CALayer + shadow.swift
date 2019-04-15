//
//  CALayer + shadow.swift

import UIKit

extension CALayer {
    
    enum ShadowPosition: Int {
        case top
        case bottom
        case left
        case right
        case exceptTop
        case all
    }
    
    func setShadow(_ position: ShadowPosition, color: UIColor, opacity: Float, pathWidth: CGFloat, cornerRadius: CGFloat) {
        self.masksToBounds = false
        self.shadowColor = color.cgColor
        self.shadowOpacity = opacity
        self.shadowOffset = CGSize(width: 0, height: pathWidth * 0.15)
        var shadowRect: CGRect = .zero
        switch position {
        case .top:
            shadowRect = CGRect(x: 0, y: -pathWidth/2, width: bounds.size.width, height: pathWidth)
        case .bottom:
            shadowRect = CGRect(x: 0, y: bounds.size.height - pathWidth/2, width: bounds.size.width, height: pathWidth)
        case .left:
            shadowRect = CGRect(x: -pathWidth/2, y: 0, width: pathWidth, height: bounds.size.height)
        case .right:
            shadowRect = CGRect(x: bounds.size.width - pathWidth/2, y: 0, width: pathWidth, height: bounds.size.height)
        case .exceptTop:
            shadowRect = CGRect(x: -pathWidth/2, y: 1, width: bounds.size.width + pathWidth, height: bounds.size.height + pathWidth/2)
        case .all:
            shadowRect = CGRect(x: -pathWidth/2, y: -pathWidth/2, width: bounds.size.width + pathWidth, height: bounds.size.height + pathWidth)
        }
        let path = UIBezierPath.init(roundedRect: shadowRect, cornerRadius: cornerRadius)
        self.shadowPath = path.cgPath
    }
    
    func setDefaultShadowStyle() {
        setShadow(.all, color: UIColor(hex: 0xC8C6C6), opacity: 0.22, pathWidth: 3, cornerRadius: 5)
    }
    
}
