//
//  CGSize + Ext.swift


import CoreGraphics

extension CGSize {
    static var bounding: CGSize {
        get { return CGSize(width: 10000, height: 10000) }
    }
    
    static func bounding(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: 10000)
    }
    
    static func bounding(height: CGFloat) -> CGSize {
        return CGSize(width: 10000, height: height)
    }
}
