//
//  UIImage + Ext.swift


import UIKit

extension UIImage {
    
    class func colorImage(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    class func bundleImage(_ name: String) -> UIImage? {
        guard
            let bundlePath = Bundle.main.path(forResource: "WooKeyWallet", ofType: "bundle"),
            let filePath = Bundle(path: bundlePath)?.path(forResource: name, ofType: "png", inDirectory: "images")
        else {
            return nil
        }
        return UIImage.init(contentsOfFile: filePath)
    }
    
}
