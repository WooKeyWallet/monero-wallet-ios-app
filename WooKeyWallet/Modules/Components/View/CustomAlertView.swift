//
//  CustomAlertView.swift


import UIKit

class CustomAlertView: UIView {

    // MARK: - Properties (Public)
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var contentBG: UIView = {
        let bg = UIView()
        bg.backgroundColor = UIColor.white
        bg.layer.cornerRadius = 5
        return bg
    }()
    
    public lazy var topIconView: UIImageView = {
        let iconV = UIImageView()
        iconV.contentMode = .scaleToFill
        return iconV
    }()
    
    public lazy var titleStatusView: UIView = {
        let statusV = UIView()
        statusV.layer.cornerRadius = 4.5
        return statusV
    }()
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.font = AppTheme.Font.text_normal
        label.numberOfLines = 0
        return label
    }()
    
    public lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_light
        label.font = AppTheme.Font.text_small
        label.numberOfLines = 0
        return label
    }()
    
    public lazy var customView: UIView = {
        return UIView()
    }()
    
    public lazy var confirmBtn: UIButton = {
        let btn = UIButton.createCommon([
            UIButton.TitleAttributes.init(LocalizedString(key: "confirm", comment: "确定"), titleColor: AppTheme.Color.button_title, state: .normal)
            ], backgroundColor: AppTheme.Color.main_blue)
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    public lazy var cancelBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "alert.canel"), for: .normal)
        return btn
    }()
    
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init() {
        super.init(frame: .zero)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        configureConstraints()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.snp.remakeConstraints { (make) in
            make.centerX.equalToSuperview()
            if topIconView.image == nil {
                make.top.equalToSuperview().offset(27)
            } else {
                make.top.equalTo(topIconView.snp.bottom).offset(12)
            }
        }
    }
    
    internal func configureView() {
        addSubViews([
        contentBG,
        cancelBtn,
        ])
        contentBG.addSubViews([
        topIconView,
        titleStatusView,
        titleLabel,
        contentLabel,
        customView,
        confirmBtn,
        ])
    }
    
    internal func configureConstraints() {
        let scale_width_375 = UIScreen.main.bounds.size.width / 375
        contentBG.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(scale_width_375 * 29)
            make.right.equalToSuperview().offset(scale_width_375 * -29)
            make.centerY.equalToSuperview().offset(scale_width_375 * -33)
        }
        cancelBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(contentBG.snp.bottom).offset(34)
            make.width.height.equalTo(34)
        }
        topIconView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(27)
        }
        titleStatusView.snp.makeConstraints { (make) in
            make.right.equalTo(titleLabel.snp.left).offset(-9)
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(9)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(27)
        }
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        customView.snp.makeConstraints { (make) in
            make.left.right.equalTo(contentLabel)
            make.top.equalTo(contentLabel.snp.bottom).offset(20)
        }
        confirmBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(customView)
            make.top.equalTo(customView.snp.bottom).offset(25)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-22)
        }
    }
    

}
