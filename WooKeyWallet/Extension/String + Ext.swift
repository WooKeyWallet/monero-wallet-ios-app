//
//  String + Ext.swift


import UIKit


// MARK: - Character

extension String {
    
    func indexsOf(_ char: String) -> [Int] {
        var indexs = [Int]()
        stride(from: 0, to: self.count, by: 1).forEach { (i) in
            let _char = self[self.index(self.startIndex, offsetBy: i)]
            if String(_char) == char {
                indexs.append(i)
            }
        }
        return indexs
    }
}

extension String {
    
    func boundingRect(with constrainedSize: CGSize, font: UIFont, lineSpacing: CGFloat? = nil) -> CGSize {
        let attritube = NSMutableAttributedString(string: self)
        let range = NSRange(location: 0, length: attritube.length)
        attritube.addAttributes([NSAttributedString.Key.font: font], range: range)
        if lineSpacing != nil {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing!
            attritube.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        }
        
        let rect = attritube.boundingRect(with: constrainedSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        var size = rect.size
        
        if let currentLineSpacing = lineSpacing {
            // 文本的高度减去字体高度小于等于行间距，判断为当前只有1行
            let spacing = size.height - font.lineHeight
            if spacing <= currentLineSpacing && spacing > 0 {
                size = CGSize(width: size.width, height: font.lineHeight)
            }
        }
        
        return size
    }
    
    func boundingRect(with constrainedSize: CGSize, font: UIFont, lineSpacing: CGFloat? = nil, lines: Int) -> CGSize {
        if lines < 0 {
            return .zero
        }
        
        let size = boundingRect(with: constrainedSize, font: font, lineSpacing: lineSpacing)
        if lines == 0 {
            return size
        }
        
        let currentLineSpacing = (lineSpacing == nil) ? (font.lineHeight - font.pointSize) : lineSpacing!
        let maximumHeight = font.lineHeight*CGFloat(lines) + currentLineSpacing*CGFloat(lines - 1)
        if size.height >= maximumHeight {
            return CGSize(width: size.width, height: maximumHeight)
        }
        
        return size
    }
    
    func attributeText(_ attributes:[NSAttributedString.Key: Any] = [:]) -> NSAttributedString {
        return NSAttributedString.init(string: self, attributes: attributes)
    }
}


// MARK: - String <-> Decimal

extension String {
    
    func decimal() -> Decimal? {
        if Double(self) == nil {
            return nil
        }
        return Decimal.init(string: self)
    }
    
    func decimalString() -> String {
        guard let _ = Double(self) else { return "--" }
        guard let dec = self.decimal() else {
            return "--"
        }
        return "\(dec)"
    }
    
    //// 四舍五入保留小数位
    func decimalScaleString(_ scale: Int16) -> String {
        guard let dec = self.decimal() else {
            return "--"
        }
        return dec.scaleString(scale)
    }
    
    
    func repeatString(_ count: Int) -> String {
        var repeatStr = ""
        stride(from: 0, to: count, by: 1).forEach { (i) in
            repeatStr += self
        }
        return repeatStr
    }
}

// MARK:  - FilePath

private struct SearchPathForDirectories {
    static let documentPath: String = {
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = allPaths[0]
        return documentDirectory + "/"
    }()
}

public struct FilePathsInDomain {
    
    private let fileName: String
    
    var document: String {
        get {
            return SearchPathForDirectories.documentPath + fileName
        }
    }
    
    init(fileName: String) {
        self.fileName = fileName
    }
}

extension String {
    
    var filePaths: FilePathsInDomain {
        get {
            return FilePathsInDomain.init(fileName: self)
        }
    }
}
