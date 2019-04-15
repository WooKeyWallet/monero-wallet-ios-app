//
//  Helper.swift


import UIKit
import EFQRCode

class Helper: NSObject {

    class func generateQRCode(content: String, icon: UIImage?, result: ((UIImage?) -> Void)?) {
        DispatchQueue.global().async {
            let generator = EFQRCodeGenerator.init(content: content, size: EFIntSize.init(width: 400, height: 400))
            generator.setColors(backgroundColor: UIColor.white.cgColor, foregroundColor: UIColor.black.cgColor)
            generator.setIcon(icon: icon?.cgImage, size: EFIntSize.init(width: 120, height: 120))
            let cgImage = generator.generate()
            DispatchQueue.main.async {
                if let cgImage = cgImage {
                    result?(UIImage.init(cgImage: cgImage))
                } else {
                    result?(nil)
                }
            }
        }
        
    }
    
    class func clipSuffix(_ text: String, clipChar: String) -> String {
        if text.hasSuffix(clipChar) {
            return clipSuffix(String(text.prefix(text.count - 1)), clipChar: clipChar)
        } else {
            return text
        }
    }
    
    class func displayDigitsAmount(_ original: String) -> String {
        guard original.contains(".") else {
            return original + ".00"
        }
        let components = original.components(separatedBy: ".")
        if components.count == 2 {
            let preffix = components[0]
            let suffix = components[1]
            let cliped = clipSuffix(suffix, clipChar: "0")
            if cliped == "" {
                return preffix + ".00"
            } else if cliped.count == 1 {
                return "\(preffix).\(cliped)0"
            }
            return preffix + "." + cliped
        }
        return original
    }
}
