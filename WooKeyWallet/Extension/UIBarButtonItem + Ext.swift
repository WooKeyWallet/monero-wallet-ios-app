//
//  UIBarButtonItem + Ext.swift


import UIKit

extension UIBarButtonItem {
    
    class func createTitleItem(_ title: String, titleColor: UIColor = AppTheme.Color.text_dark, target: Any?, action: Selector?) -> Self {
        let titleItem = self.init(title: title, style: .plain, target: target, action: action)
        titleItem.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: titleColor,
            NSAttributedString.Key.font: AppTheme.Font.text_small.medium(),
        ], for: .normal)
        titleItem.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: titleColor.highlighted(),
            NSAttributedString.Key.font: AppTheme.Font.text_small.medium(),
        ], for: .highlighted)
        return titleItem
    }
}
