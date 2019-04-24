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
    
    func push(_ from: CATransitionSubtype, viewController: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = .push
        transition.subtype = from
        transition.isRemovedOnCompletion = true
        view.layer.add(transition, forKey: nil)
        pushViewController(viewController, animated: false)
    }
}


