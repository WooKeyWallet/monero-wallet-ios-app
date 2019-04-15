//
//  NSAttributedString + Ext.swift


import UIKit

extension NSAttributedString {
    
    func esay_append(_ attrString: NSAttributedString) -> NSMutableAttributedString {
        let attributedMutableString = NSMutableAttributedString.init(attributedString: self)
        attributedMutableString.append(attrString)
        return attributedMutableString
    }
    
    func addLineSpace(_ space: CGFloat) -> NSAttributedString {
        let attriM = NSMutableAttributedString.init(attributedString: self)
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.lineSpacing = space
        attriM.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange.init(location: 0, length: self.length))
        return attriM
    }
}
