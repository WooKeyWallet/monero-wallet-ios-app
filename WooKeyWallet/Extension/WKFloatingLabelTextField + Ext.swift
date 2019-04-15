//
//  SkyFloatingLabelTextField + Ext.swift


import Foundation

public extension WKFloatingLabelTextField {
    
    public static func createTextField() -> WKFloatingLabelTextField {
        let field = WKFloatingLabelTextField.init(frame: .zero)
        field.font = AppTheme.Font.text_normal
        field.lineColor = AppTheme.Color.cell_line
        field.selectedLineColor = AppTheme.Color.main_green_light
        field.selectedTitleColor = AppTheme.Color.main_green_light
        field.placeholderColor = AppTheme.Color.text_light
        field.textErrorColor = AppTheme.Color.text_warning
        field.lineErrorColor = AppTheme.Color.text_warning
        field.titleErrorColor = AppTheme.Color.text_warning
        field.titleFont = AppTheme.Font.text_smaller
        return field
    }
}

