//
//  WKTipsLabel.swift


import UIKit

class WKTipsLabel: UIView {

    // MARK: - Properties (Public)
    
    public var text: String? {
        didSet {
            label.text = text
        }
    }
    
    public var textColor: UIColor? {
        didSet {
            label.textColor = textColor
        }
    }
    
    public var textAlignment: NSTextAlignment = .left {
        didSet {
            label.textAlignment = textAlignment
        }
    }
    
    public var font: UIFont? {
        didSet {
            label.font = font
        }
    }
    
    public var dotColor: UIColor? {
        didSet {
            dotView.backgroundColor = dotColor
        }
    }
    
    public var dotWidth: CGFloat = 6.0
    
    public var contentInserts: UIEdgeInsets = .zero
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var dotView: UIView = { return UIView() }()
    private lazy var label: UILabel = { return UILabel() }()
    
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.numberOfLines = 0
        addSubViews([
            label,
            dotView,
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dotView.layer.cornerRadius = dotWidth * 0.5
        dotView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(contentInserts.left)
            make.top.equalTo(label).offset((label.font.lineHeight - dotWidth)/2)
            make.width.height.equalTo(dotWidth)
        }
        label.snp.makeConstraints { (make) in
            make.left.equalTo(dotView.snp.right).offset(7)
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-contentInserts.right)
            make.bottom.equalToSuperview().offset(-contentInserts.bottom)
        }
    }

}
