//
//  WKProgressBar.swift


import UIKit

class WKProgressBar: UIView {

    // MARK: - Properties (Public)
    
    public var borderColor: UIColor? = nil {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    public var borderWidth: CGFloat = 1 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    public var progressColor: UIColor? = nil {
        didSet {
            progressLayer.backgroundColor = progressColor?.cgColor
            animateLayer.backgroundColor = progressColor?.cgColor
        }
    }
    
    public var progress: CGFloat = 0 {
        didSet {
            guard !animating else {
                return
            }
            setNeedsLayout()
        }
    }
    
    public var text: String? {
        didSet {
            if let text = self.text, let font = font {
                labelLayer.string = NSAttributedString.init(string: text, attributes: [NSAttributedString.Key.font: font,
                                                                                       NSAttributedString.Key.foregroundColor: textColor ?? UIColor.black])
            }
        }
    }
    
    public var textColor: UIColor? {
        didSet {
            if let text = self.text, let font = font {
                labelLayer.string = NSAttributedString.init(string: text, attributes: [NSAttributedString.Key.font: font,
                                                                                       NSAttributedString.Key.foregroundColor: textColor ?? UIColor.black])
            }
        }
    }
    
    public var font: UIFont? {
        didSet {
            if let text = self.text, let font = font {
                labelLayer.string = NSAttributedString.init(string: text, attributes: [NSAttributedString.Key.font: font,
                                                                                       NSAttributedString.Key.foregroundColor: textColor ?? UIColor.black])
            }
        }
    }
    
    public var animating: Bool = false {
        didSet {
            animating ? addAnimation() : removeAnimation()
        }
    }
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var progressLayer: CALayer = {
        return CALayer()
    }()
    
    private lazy var labelLayer: CATextLayer = {
        return CATextLayer()
    }()
    
    private lazy var animateLayer: CALayer = {
        return CALayer()
    }()
    
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        
        layer.addSublayer(progressLayer)
        layer.addSublayer(labelLayer)
        
        labelLayer.isWrapped = true
        labelLayer.alignmentMode = .center
        labelLayer.contentsScale = UIScreen.main.scale
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = height * 0.5
        progressLayer.cornerRadius = layer.cornerRadius
        progressLayer.frame = CGRect(x: 0, y: 0, width: width * progress, height: height)
        let textTopBottomInsert = (height-(font?.lineHeight ?? 0)) * 0.5
        labelLayer.frame = bounds.inset(by: UIEdgeInsets(top: textTopBottomInsert, left: 0, bottom: textTopBottomInsert, right: 0))
        animateLayer.frame = CGRect(x: 0, y: 0, width: width * 0.2, height: height)
    }
    
    func willAppear() {
        if animating {
            addAnimation()
        }
    }
    
    func willDisappear() {
        if animating {
            removeAnimation()
        }
    }
    
    
    // MARK: - Methods (Animate)
    
    private func addAnimation() {
        progressLayer.isHidden = true
        animateLayer.isHidden = false
        layer.addSublayer(animateLayer)
        
        let anim1 = CAKeyframeAnimation.init()
        anim1.keyPath = "transform.scale.x"
        anim1.values = [1, 1.5, 2.25, 1.5, 1]
        anim1.fillMode = .forwards
        anim1.repeatCount = HUGE
        anim1.beginTime = 0
        
        let itemW = animateLayer.bounds.size.width
        let anim2 = CAKeyframeAnimation.init()
        anim2.keyPath = "position.x"
        anim2.values = [0, itemW * 0.75, itemW * 1.875, itemW * 2.75, itemW * 4, itemW * 5]
        anim2.fillMode = .forwards
        anim2.repeatCount = HUGE
        anim2.beginTime = 0
        
        let group = CAAnimationGroup.init()
        group.animations = [anim1, anim2]
        group.fillMode = .forwards
        group.duration = 1.5
        group.repeatCount = HUGE
        animateLayer.add(group, forKey: nil)
    }
    
    private func removeAnimation() {
        progressLayer.isHidden = false
        animateLayer.isHidden = true
        animateLayer.removeAllAnimations()
        animateLayer.removeFromSuperlayer()
        // 重启过程
        let _p = self.progress
        self.progress = _p
    }

    
}
