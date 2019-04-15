//
//  UIColor + Ext.swift


import UIKit

extension UIColor {
    
    typealias RGBAlpha = (r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat)
    typealias RGB = (r: CGFloat, g: CGFloat, b: CGFloat)
    
    public convenience init(hex: UInt, alpha: CGFloat = 1) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / CGFloat(255)
        let green = CGFloat((hex & 0x00FF00) >> 8) / CGFloat(255)
        let blue = CGFloat(hex & 0x0000FF) / CGFloat(255)
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public static var randomColor: UIColor {
        return UIColor(red: CGFloat(arc4random_uniform(256)) / CGFloat(255), green: CGFloat(arc4random_uniform(256)) / CGFloat(255), blue: CGFloat(arc4random_uniform(256)) / CGFloat(255), alpha: 1);
    }
    
    public func highlighted() -> UIColor {
        let rgbAlpha: RGBAlpha = self.getRGBAlpha()
        return UIColor.init(red: rgbAlpha.r, green: rgbAlpha.g, blue: rgbAlpha.b, alpha: rgbAlpha.alpha * 0.5)
    }
    
    public func getRGBAlpha() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var r: CGFloat = 1
        var g: CGFloat = 1
        var b: CGFloat = 1
        var a: CGFloat = 1
        if self.cgColor.numberOfComponents == 4 {
            r = self.cgColor.components![0]
            g = self.cgColor.components![1]
            b = self.cgColor.components![2]
            a = self.cgColor.components![3]
        }
        return (r, g, b, a)
    }
}

