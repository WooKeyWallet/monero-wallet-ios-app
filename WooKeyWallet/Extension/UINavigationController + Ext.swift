//
//  UINavigationController+Extension.swift


import UIKit

extension UINavigationController {
    
    func popTo(_ offset:Int) {
        let count = self.viewControllers.count
        if count > 2 && count - offset >= 1 {
            self.popToViewController(viewControllers[count-offset-1], animated: true)
        }
    }
}


