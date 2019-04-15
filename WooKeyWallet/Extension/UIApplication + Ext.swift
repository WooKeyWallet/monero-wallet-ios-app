//
//  UIApplication + Ext.swift


import UIKit

public extension UIApplication {
    
    var statusBarBackgroundColor: UIColor? {
        get { return (value(forKey: "statusBar") as? UIView)?.backgroundColor }
        set {
            (value(forKey: "statusBar") as? UIView)?.backgroundColor = newValue
        }
    }
}
