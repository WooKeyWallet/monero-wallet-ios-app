//
//  Array + Ext.swift


import Foundation

extension Array where Element: Equatable {
    
    func index(of element: Element) -> Index? {
        var index: Index?
        for i in 0..<count {
            if self[i] == element {
                index = i
                break
            }
        }
        return index
    }
}
