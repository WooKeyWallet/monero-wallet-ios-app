//
//  Character + Ext.swift


import Foundation

extension Character {
    
    func isUpperCase() -> Bool {
        for scaler in unicodeScalars {
            if scaler.value <= 90 && scaler.value >= 65 {
                return true
            }
        }
        return false
    }
    
    func isLowerCase() -> Bool {
        for scaler in unicodeScalars {
            if scaler.value <= 122 && scaler.value >= 97 {
                return true
            }
        }
        return false
    }
    
    func isNumberCase() -> Bool {
        for scaler in unicodeScalars {
            if scaler.value <= 57 && scaler.value >= 48 {
                return true
            }
        }
        return false
    }
}
