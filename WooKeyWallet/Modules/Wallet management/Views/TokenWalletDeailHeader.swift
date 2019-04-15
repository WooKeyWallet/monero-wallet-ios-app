//
//  TokenWalletDeailHeader.swift


import UIKit

class TokenWalletDeailHeaderCell: BaseTableViewCell {
    
    // MARK: - Properties (Private)
    
    private var actionHandler: ((Any) -> Void)?
    

    // MARK: - Properties (Lazy)
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_light
        label.textAlignment = .center
        label.font = AppTheme.Font.text_small
        return label
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.textAlignment = .center
        label.font = AppTheme.Font.text_huge
        return label
    }()
    
    private lazy var addressBG: UIView = {
        let bg = UIView()
        bg.backgroundColor = AppTheme.Color.alert_textView
        return bg
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.textAlignment = .center
        label.font = AppTheme.Font.text_small
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    
    public lazy var copyBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "btn_copy"), for: .normal)
        return btn
    }()
    
    
    // MARK: - Life Cycle
    
    override func initCell() {
        super.initCell()
        configureViews()
        configureConstaints()
    }
    
    private func configureViews() {
        backgroundColor = AppTheme.Color.page_common
        addSubViews([
            titleLabel,
            amountLabel,
            addressBG,
            ])
        addressBG.addSubViews([
            addressLabel,
            copyBtn,
            ])
        copyBtn.addTarget(self, action: #selector(self.copyAction), for: .touchUpInside)
    }
    
    private func configureConstaints() {
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(25)
        }
        amountLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        addressBG.snp.makeConstraints { (make) in
            make.left.equalTo(40)
            make.right.equalTo(-40)
            make.height.equalTo(28)
            make.top.equalTo(amountLabel.snp.bottom).offset(20)
        }
        addressLabel.snp.makeConstraints { (make) in
            make.left.equalTo(40)
            make.right.equalTo(-40)
            make.top.bottom.equalTo(0)
        }
        copyBtn.snp.makeConstraints { (make) in
            make.top.bottom.right.equalTo(0)
            make.width.equalTo(28)
        }
    }
    
    override func configure(with row: TableViewRow) {
        self.actionHandler = row.actionHandler
        guard let model: TokenWalletDetail = row.serializeModel() else { return }
        titleLabel.text = LocalizedString(key: "assets.prefix", comment: "") + "(\(model.token))"
        amountLabel.text = model.assets
        addressLabel.text = model.address
    }
    
    // MARK: - Methods (Action)
    
    @objc private func copyAction() {
        actionHandler?(0)
    }
}
