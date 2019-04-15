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
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setBorderColor(UIColor.init(white: 0.95, alpha: 0.618))
        SVProgressHUD.setBorderWidth(px(1))
        SVProgressHUD.setMaximumDismissTimeInterval(3)
    }
    
    static func showSuccess(_ text: String) {
        SVProgressHUD.showSuccess(withStatus: text)
    }
    static func showError(_ text: String) {
        SVProgressHUD.showError(withStatus: text)
    }
    static func showHUD() {
        SVProgressHUD.show()
    }
    static func hideHUD() {
        SVProgressHUD.dismiss()
    }
}
