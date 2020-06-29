//
//  AssetsViewHeader.swift


import UIKit

class AssetsViewHeader: UIView {
    
    // MARK: - Properties (Public)
    
    public lazy var walletNameLabel: UILabel = { return UILabel() }()
    public lazy var walletAddressLabel: UILabel = { return UILabel() }()
    public lazy var copyBtn: UIButton = { return UIButton() }()
    
    
    // MARK: - Life Cycles

    required init() {
        super.init(frame: .zero)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configureView() {
        
        let screen_w = UIScreen.main.bounds.size.width
        let bg_w = screen_w - 32
        backgroundColor = AppTheme.Color.tableView_bg
        
        let bgImageView = UIImageView(frame: CGRect(x: 16, y: 16, width: bg_w, height: 0.306 * bg_w))
        bgImageView.image = UIImage.bundleImage("assets_header_bg")
        bgImageView.contentMode = .scaleToFill
        bgImageView.isUserInteractionEnabled = true
        addSubview(bgImageView)
        
        let nameH = AppTheme.Font.text_normal.lineHeight
        let addressH = AppTheme.Font.text_small.lineHeight
        walletNameLabel.frame = CGRect(x: 16, y: (bgImageView.height - nameH - 20 - addressH)/2, width: bg_w - 32, height: nameH)
        walletNameLabel.textColor = UIColor.white
        walletNameLabel.font = AppTheme.Font.text_normal
        bgImageView.addSubview(walletNameLabel)
        
        walletAddressLabel.frame = CGRect(x: walletNameLabel.x + 15, y: walletNameLabel.maxY + 20, width: bg_w - 106, height: addressH)
        walletAddressLabel.textColor = UIColor(hex: 0xC5C5C5)
        walletAddressLabel.font = AppTheme.Font.text_small
        walletAddressLabel.lineBreakMode = .byTruncatingMiddle
        bgImageView.addSubview(walletAddressLabel)
        
        let dotV = UIView(frame: CGRect(x: 16, y: walletAddressLabel.midY - 4.5, width: 9, height: 9))
        dotV.backgroundColor = UIColor(hex: 0x59C698)
        dotV.layer.cornerRadius = 4.5
        bgImageView.addSubview(dotV)
        
        copyBtn.frame = CGRect(x: bg_w - 70, y: dotV.midY - 11, width: 45, height: 22)
        copyBtn.setTitle(LocalizedString(key: "copy", comment: ""), for: .normal)
        copyBtn.setTitleColor(UIColor.white, for: .normal)
        copyBtn.titleLabel?.font = AppTheme.Font.text_small
        copyBtn.layer.cornerRadius = 11
        copyBtn.layer.borderColor = UIColor.white.cgColor
        copyBtn.layer.borderWidth = px(1)
        bgImageView.addSubview(copyBtn)
        
        frame = CGRect(x: 0, y: 0, width: screen_w, height: bgImageView.maxY)
    }
    
    // MARK: - Configure
    
    func configure(_ model: Wallet) {
        walletNameLabel.text = model.name
        
        let key = model.address
        WalletDefaults.shared.subAddressIndexState.observe(self) { (subAddress, _Self) in
            _Self.walletAddressLabel.text = subAddress[key]?.address ?? key
        }
    }
    
}
