//
//  UIViewController + Ext.swift


import UIKit

extension UIViewController {
    
    func getTopViewController() -> UIViewController? {
        if let _presentedViewController = presentedViewController {
            return _presentedViewController.getTopViewController()
        }
        if let NVC = self as? UINavigationController {
            return NVC.topViewController?.getTopViewController()
        } else if let TBVC = self as? UITabBarController {
            return TBVC.selectedViewController?.getTopViewController()
        }
        return self
    }
}
