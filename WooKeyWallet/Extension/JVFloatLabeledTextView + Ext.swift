//
//  JVFloatLabeledTextView + Ext.swift


import UIKit

extension JVFloatLabeledTextView {
    
    static func createTextView() -> JVFloatLabeledTextView {
        let textView = JVFloatLabeledTextView.init()
        textView.isScrollEnabled = false
        textView.tintColor = AppTheme.Color.main_green
        // text label
        textView.textColor = AppTheme.Color.text_dark
        textView.font = AppTheme.Font.text_normal
        // float label
        textView.floatingLabelTextColor = AppTheme.Color.text_light
        textView.floatingLabelActiveTextColor = AppTheme.Color.text_light
        textView.floatingLabel.font = AppTheme.Font.text_smaller
        // placeholderLabel
        textView.placeholderLabel.textColor = AppTheme.Color.text_light
        textView.placeholderLabel.font = AppTheme.Font.text_normal
        // bottom line
        textView.bottomLineColor = UIColor(hex: 0xC3C7CB)
        
        return textView
    }
}

