//
//  AssetsTokenView.swift


import UIKit

class AssetsTokenView: UIView {
    
    // MARK: - Properties (Public)
        
    public lazy var tokenIconView: UIImageView = {
        let imageV = UIImageView()
        imageV.layer.cornerRadius = 18
        imageV.layer.masksToBounds = true
        return imageV
    }()
    
    public lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.textAlignment = .center
        label.font = AppTheme.Font.text_huge
        return label
    }()
    
    public lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_light_M
        label.textAlignment = .center
        label.font = AppTheme.Font.text_small
        return label
    }()
    
    public lazy var progressBar: WKProgressBar = {
        let progressBar = WKProgressBar()
        progressBar.progressColor = AppTheme.Color.progress_green
        progressBar.backgroundColor = AppTheme.Color.text_light_H
        return progressBar
    }()
    
    private lazy var tokenAddressBG: UIView = {
        let bg = UIView()
        bg.backgroundColor = AppTheme.Color.alert_textView
        return bg
    }()
    
    public lazy var tokenAddress: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.textAlignment = .center
        label.font = AppTheme.Font.text_small
        label.backgroundColor = AppTheme.Color.alert_textView
        label.layer.cornerRadius = 3
        label.layer.masksToBounds = true
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    
    public lazy var copyBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "btn_copy"), for: .normal)
        return btn
    }()
    
    public lazy var sendBtn: UIButton = {
        return UIButton.createCommon([
            UIButton.TitleAttributes(LocalizedString(key: "send", comment: ""), titleColor: AppTheme.Color.button_title, state: .normal)
        ], backgroundColor: AppTheme.Color.main_blue)
    }()
    
    public lazy var receiveBtn: UIButton = {
        return UIButton.createCommon([
            UIButton.TitleAttributes(LocalizedString(key: "receive", comment: ""), titleColor: AppTheme.Color.button_title, state: .normal)
        ], backgroundColor: AppTheme.Color.main_green)
    }()
    
    
    // MARK: - Properties (Private)
    
    private lazy var bottomLine = { UIView() }()
    

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
    
    private func configureView() {
        backgroundColor = AppTheme.Color.page_common
        sendBtn.layer.cornerRadius = 22.5
        receiveBtn.layer.cornerRadius = 22.5
        bottomLine.backgroundColor = AppTheme.Color.cell_line
        
        addSubViews([
        tokenIconView,
        balanceLabel,
        progressLabel,
        progressBar,
        tokenAddressBG,
        sendBtn,
        receiveBtn,
        bottomLine,
        ])
        
        tokenAddressBG.addSubViews([tokenAddress, copyBtn])
    }
    
    private func configureConstraints() {
        tokenIconView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(18)
            make.width.height.equalTo(36)
        }
        balanceLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(tokenIconView.snp.bottom).offset(12)
        }
        progressLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(balanceLabel.snp.bottom).offset(17)
        }
        progressBar.snp.makeConstraints { (make) in
            make.top.equalTo(progressLabel.snp.bottom).offset(11)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.height.equalTo(5)
        }
        tokenAddress.snp.makeConstraints { (make) in
            make.left.equalTo(50)
            make.right.equalTo(-50)
            make.top.bottom.equalTo(0)
        }
        tokenAddressBG.snp.makeConstraints { (make) in
            make.top.equalTo(progressBar.snp.bottom).offset(12)
            make.left.right.equalTo(progressBar)
            make.height.equalTo(28)
        }
        copyBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-9)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }
        sendBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(25)
            make.top.equalTo(tokenAddress.snp.bottom).offset(21)
            make.height.equalTo(45)
        }
        receiveBtn.snp.makeConstraints { (make) in
            make.left.equalTo(sendBtn.snp.right).offset(15)
            make.top.width.height.equalTo(sendBtn)
            make.right.equalToSuperview().offset(-25)
        }
        bottomLine.snp.makeConstraints { (make) in
            make.top.equalTo(receiveBtn.snp.bottom).offset(21)
            make.left.right.equalToSuperview()
            make.height.equalTo(px(1))
            make.bottom.equalToSuperview()
        }
    }

    
}
