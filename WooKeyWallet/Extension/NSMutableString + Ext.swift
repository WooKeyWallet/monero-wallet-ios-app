//
//  NSMutableString + Ext.swift


import UIKit

extension NSMutableAttributedString {
    func add(_ text: String, color: UIColor? = nil, font: UIFont? = nil) {
        var attributes: [NSAttributedString.Key: Any] = [:]
        if let color = color {
            attributes[.foregroundColor] = color
        }
        if let font = font {
            attributes[.font] = font
        }
        self.append(NSAttributedString.init(string: text, attributes: attributes))
    }
}
