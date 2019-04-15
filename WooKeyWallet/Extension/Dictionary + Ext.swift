//
//  Dictionary + Ext.swift


import Foundation

extension Dictionary {
    mutating func appendFrom(_ dict: [Key: Value]) {
        dict.forEach({ self[$0.key] = $0.value })
    }
}
