//
//  CoinTypeSelectionView.swift


import UIKit

class CoinTypeSelectionView: UIView {

    // MARK: - Properties (Lazy)
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizedString(key: "coin", comment: "")
        label.textColor = AppTheme.Color.text_dark
        label.font = AppTheme.Font.text_normal
        return label
    }()
    
    public lazy var tokenIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    public lazy var tokenNameLab: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.font = AppTheme.Font.text_normal
        return label
    }()
    
    private lazy var arrow: UIImageView = {
        let imgV = UIImageView()
        imgV.image = UIImage(named: "cell_arrow_right")
        return imgV
    }()
    
    
    // MARK: - Life Cycles
    
    required init() {
        super.init(frame: .zero)
        self.configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.configureConstraints()
    }
    
    
    // MARK: - Configure
    
    internal func configureView() {
        addSubViews([
        titleLabel,
        tokenIcon,
        tokenNameLab,
//        arrow,
        ])
    }
    
    internal func configureConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.left.centerY.equalToSuperview()
        }
        tokenIcon.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(tokenNameLab.snp.left).offset(-5)
            make.size.equalTo(20)
        }
        tokenNameLab.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(0)
        }
//        arrow.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.right.equalTo(0)
//            make.size.equalTo(CGSize(width: 8, height: 13))
//        }
    }
    
    func test() {
        tokenIcon.image = UIImage(named: "token_icon_XMR")
        tokenNameLab.text = "XMR"
    }
    
    func configure(_ token: Token) {
        tokenIcon.image = UIImage(named: "token_icon_\(token.rawValue)")
        tokenNameLab.text = token.rawValue
    }
    
}
