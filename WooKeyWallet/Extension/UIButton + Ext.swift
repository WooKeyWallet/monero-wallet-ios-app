//
//  UIButton + Ext.swift


import UIKit

extension UIButton {
    
    public struct TitleAttributes {
        let title: String
        let titleColor: UIColor
        let state: State
        
        init(_ title: String, titleColor: UIColor, state: State) {
            self.title = title
            self.titleColor = titleColor
            self.state = state
        }
    }
    
    public class func create(_ title: String? = nil,
                             titleColor: UIColor? = nil,
                             image: UIImage? = nil,
                             backgroundImage: UIImage?) -> Self {
        let btn = self.init()
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(titleColor, for: .normal)
        btn.setImage(image, for: .normal)
        btn.setBackgroundImage(image, for: .normal)
        return btn
    }
    
    class func createCommon(_ titleAttributes: [TitleAttributes], backgroundColor: UIColor = AppTheme.Color.button_bg) -> Self {
        let commonBtn = self.create(nil, titleColor: nil, image: nil, backgroundImage: UIImage(named: ""))
        titleAttributes.forEach { titleAttributes in
            commonBtn.setTitle(titleAttributes.title, for: titleAttributes.state)
            commonBtn.setTitleColor(titleAttributes.titleColor, for: titleAttributes.state)
        }
        commonBtn.layer.cornerRadius = 25
        commonBtn.layer.masksToBounds = true
        commonBtn.titleLabel?.font = AppTheme.Font.text_normal
        commonBtn.setBackgroundImage(UIImage.colorImage(backgroundColor, size: CGSize(width: 10, height: 10)), for: .normal)
        commonBtn.setBackgroundImage(UIImage.colorImage(backgroundColor.highlighted(), size: CGSize(width: 10, height: 10)), for: .highlighted)
        commonBtn.setBackgroundImage(UIImage.colorImage(AppTheme.Color.button_disable, size: CGSize(width: 10, height: 10)), for: .disabled)
        return commonBtn
    }
}
