//
//  UIFont + Ext.swift


import UIKit

extension UIFont {
    
    func bold() -> UIFont {
        return UIFont.boldSystemFont(ofSize: self.pointSize)
    }
    
    func light() -> UIFont {
        return UIFont.systemFont(ofSize: pointSize, weight: .light)
    }
    
    func medium() -> UIFont {
        return UIFont.systemFont(ofSize: pointSize, weight: .medium)
    }
    
    func regular() -> UIFont {
        return UIFont.systemFont(ofSize: pointSize, weight: .regular)
    }
    
    func heavy() -> UIFont {
        return UIFont.systemFont(ofSize: pointSize, weight: .heavy)
    }
}
