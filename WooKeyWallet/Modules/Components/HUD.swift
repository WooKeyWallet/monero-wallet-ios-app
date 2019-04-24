//
//  HUD.swift


import Foundation
import SVProgressHUD

struct HUD {
    
    /**
     *  HUD
     **/
    static func setupAppearence() {
        SVProgressHUD.setDefaultStyle(.light)
        SVProgressHUD.setBorderColor(UIColor.init(white: 0.95, alpha: 0.618))
        SVProgressHUD.setBorderWidth(px(1))
        SVProgressHUD.setMaximumDismissTimeInterval(5)
        SVProgressHUD.setMinimumDismissTimeInterval(2)
        SVProgressHUD.setRingThickness(px(5))
    }
    
    static func showSuccess(_ text: String) {
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.showSuccess(withStatus: text)
    }
    static func showError(_ text: String) {
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.showError(withStatus: text)
    }
    static func showHUD() {
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
    }
    static func hideHUD() {
        SVProgressHUD.dismiss()
    }
}
