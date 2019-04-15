//
//  UIView+Extension.swift


import UIKit

extension UIView {

    func addSubViews(_ subviews: UIView ...) {
        subviews.forEach { (sub) in
            self.addSubview(sub)
        }
    }
    
    func addSubViews(_ subviews: [UIView]) {
        subviews.forEach { (sub) in
            self.addSubview(sub)
        }
    }
    

    var width: CGFloat {
        get { return self.frame.size.width }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    var height: CGFloat {
        get { return self.frame.size.height }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
    var size: CGSize  {
        get { return self.frame.size }
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }
    
    var origin: CGPoint {
        get { return self.frame.origin }
        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }
    
    var x: CGFloat {
        get { return self.frame.origin.x }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    var y: CGFloat {
        get { return self.frame.origin.y }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    var centerX: CGFloat {
        get { return self.center.x }
        set {
            self.center = CGPoint(x: newValue, y: self.center.y)
        }
    }
    
    var centerY: CGFloat {
        get { return self.center.y }
        set {
            self.center = CGPoint(x: self.center.x, y: newValue)
        }
    }
    
    var top : CGFloat {
        get { return self.frame.origin.y }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    var bottom : CGFloat {
        get { return frame.origin.y + frame.size.height }
        set {
            var frame = self.frame
            frame.origin.y = newValue - self.frame.size.height
            self.frame = frame
        }
    }
    
    var right : CGFloat {
        get { return self.frame.origin.x + self.frame.size.width }
        set {
            var frame = self.frame
            frame.origin.x = newValue - self.frame.size.width
            self.frame = frame
        }
    }
    
    var left : CGFloat {
        get { return self.frame.origin.x }
        set {
            var frame = self.frame
            frame.origin.x  = newValue
            self.frame = frame
        }
    }
    
    var maxX:CGFloat {
        get{ return self.frame.maxX }
    }
    
    var maxY:CGFloat {
        get{ return self.frame.maxY }
    }
    
    var minX:CGFloat {
        get{ return self.frame.minX }
    }
    
    var minY:CGFloat {
        get{ return self.frame.minY }
    }
    
    var midX:CGFloat {
        get{ return self.frame.midX }
    }
    
    var midY:CGFloat {
        get{ return self.frame.midY }
    }
    
    func updateFrame(_ rect: CGRect) {
        guard frame != rect else {
            return
        }
        self.frame = rect
    }
    
}

//MARK: - TapGestureRecognizer

extension UIView {
    
    func addTapGestureRecognizer(target:Any?, selector:Selector) {
        self.isUserInteractionEnabled = true
        let ges = UITapGestureRecognizer.init(target: target, action: selector)
        self.addGestureRecognizer(ges)
    }
}


// MARK: - Gradient

extension UIView {
    
    func setGradient(_ colors: [UIColor]) {
        let gradientLayer = CAGradientLayer.init()
        gradientLayer.colors = colors.map({ return $0.cgColor })
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setBrokenLine() {
        if let sublayers = layer.sublayers {
            sublayers.forEach({ $0.removeFromSuperlayer() })
        }
        let shapeLayer = CAShapeLayer.init()
        shapeLayer.frame = bounds
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = 1
        shapeLayer.lineJoin = .round
        shapeLayer.lineDashPattern = [NSNumber(value: 2), NSNumber(value: 2)]
        shapeLayer.strokeColor = AppTheme.Color.line_broken.cgColor
        let path = UIBezierPath.init()
        path.move(to: CGPoint(x: 6, y: (height - 1) * 0.5))
        path.addLine(to: CGPoint(x: width - 6, y: (height - 1) * 0.5))
        shapeLayer.path = path.cgPath
        layer.addSublayer(shapeLayer)
    }
}
