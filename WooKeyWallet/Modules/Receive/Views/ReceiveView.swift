//
//  ReceiveView.swift


import UIKit

class ReceiveView: UIView {

    // MARK: - Properties (Lazy)
    
    private lazy var topBG: UIImageView = {
        let bg = UIImageView(image: UIImage(named: "receive_top_bg"))
        bg.contentMode = .scaleToFill
        bg.backgroundColor = AppTheme.Color.tableView_bg
        return bg
    }()
    
    public lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.button_title
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.text = LocalizedString(key: "", comment: "")
        return label
    }()
    
    private lazy var triangleView: TriangleView = {
        let view = TriangleView.init(color: AppTheme.Color.main_green_light, style: .down)
        view.backgroundColor = AppTheme.Color.page_common
        return view
    }()
    
    public lazy var qrcodeView: UIImageView = {
        let qrcodeView = UIImageView()
        qrcodeView.contentMode = .scaleToFill
        return qrcodeView
    }()
    
    private lazy var sepratorView: UIView = {
        let sepratorView = UIView()
        sepratorView.backgroundColor = AppTheme.Color.page_common
        return sepratorView
    }()
    
    public lazy var addressView: WKTextView = {
        let textView = createTextView()
        textView.font = AppTheme.Font.text_smaller
        textView.isEditable = false
        textView.delegate = self
        return textView
    }()
    
    public lazy var addressTipLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = AppTheme.Font.text_smaller
        label.textColor = AppTheme.Color.text_warning
        label.numberOfLines = 0
        return label
    }()
    
//    public lazy var amountField: WKTextView = {
//        let field = createTextView()
//        field.placeholder = LocalizedString(key: "receive.amount.placeholder", comment: "")
//        return field
//    }()
    
    public lazy var paymentIdField: WKTextView = {
        let field = createTextView()
        field.placeholder = "Payment ID\(LocalizedString(key: "optional", comment: ""))"
        return field
    }()
    
    public lazy var payIdLimitLab: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_light
        label.textAlignment = .right
        label.font = AppTheme.Font.text_smaller
        return label
    }()
    
    public lazy var integartedAddressField: WKTextView = {
        let field = createTextView()
        field.placeholder = "Integrated Address\(LocalizedString(key: "optional", comment: ""))"
        field.isUserInteractionEnabled = false
        return field
    }()
    
    public lazy var unfoldBtn: BaseButton = {
        let btn = BaseButton.init(frame: UIScreen.main.bounds, imageTitlePostion: .rightLeft(padding: 10))
        btn.setImage(UIImage(named: "receive_ubfold_normal"), for: .normal)
        btn.setTitle(LocalizedString(key: "receive.unfold.normal", comment: ""), for: .normal)
        btn.setImage(UIImage(named: "receive_ubfold_selected"), for: .selected)
        btn.setTitle(LocalizedString(key: "receive.unfold.selected", comment: ""), for: .selected)
        btn.setTitleColor(AppTheme.Color.text_light, for: .normal)
        btn.titleLabel?.font = AppTheme.Font.text_small
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    public lazy var showHideAddrBtn: UIButton = {
        let btn = createIconBtn(icon: UIImage(named: "receive_address_show"))
        btn.setImage(UIImage(named: "receive_address_hidden"), for: .selected)
        return btn
    }()
    
    public lazy var copyAddressBtn: UIButton = {
        return createIconBtn(icon: UIImage(named: "receive_copy"))
    }()
    
    public lazy var newPayIdBtn: UIButton = {
        return createIconBtn(icon: UIImage(named: "paymentId_switch"))
    }()
    
    public lazy var copyPayIdBtn: UIButton = {
        return createIconBtn(icon: UIImage(named: "receive_copy"))
    }()
    
    public lazy var addressVSPayIdCopyBtn: UIButton = {
        return createIconBtn(icon: UIImage(named: "receive_copy"))
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sepratorView.setBrokenLine()
        layer.setDefaultShadowStyle()
    }
    
    
    // MARK: - Configures
    
    internal func configureView() {
        
        backgroundColor = AppTheme.Color.page_common
        
        addSubViews([
        topBG,
        triangleView,
        qrcodeView,
        sepratorView,
        addressView,
        addressTipLabel,
        showHideAddrBtn,
        copyAddressBtn,
        
//        amountField,
        paymentIdField,
        payIdLimitLab,
        integartedAddressField,
        
        newPayIdBtn,
        copyPayIdBtn,
        addressVSPayIdCopyBtn,
        
        unfoldBtn,
        ])
        
        topBG.addSubview(amountLabel)
        

        paymentIdField.isHidden = true
        payIdLimitLab.isHidden = true
        integartedAddressField.isHidden = true
        
        copyPayIdBtn.isHidden = true
        newPayIdBtn.isHidden = true
        addressVSPayIdCopyBtn.isHidden = true
    }
    
    internal func configureConstraints() {
        
        amountLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
        topBG.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(47)
        }
        triangleView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(topBG.snp.bottom)
            make.width.equalTo(16)
            make.height.equalTo(6)
        }
        qrcodeView.snp.makeConstraints { (make) in
            make.top.equalTo(triangleView.snp.bottom).offset(15)
            make.size.equalTo(114)
            make.centerX.equalToSuperview()
        }
        sepratorView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(qrcodeView.snp.bottom).offset(12)
            make.height.equalTo(3)
        }
        addressView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(sepratorView.snp.bottom).offset(10)
        }
        addressTipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(54)
            make.right.equalTo(-54)
            make.top.equalTo(addressView.snp.bottom).offset(10)
        }
        
        
        copyAddressBtn.snp.makeConstraints { (make) in
            make.size.equalTo(32)
            make.right.bottom.equalTo(addressView)
        }
        showHideAddrBtn.snp.makeConstraints { (make) in
            make.size.equalTo(32)
            make.right.equalTo(copyAddressBtn.snp.left).offset(-5)
            make.bottom.equalTo(copyAddressBtn)
        }
        
//        amountField.snp.makeConstraints { (make) in
//            make.top.equalTo(addressTipLabel.snp.bottom).offset(10)
//            make.left.right.equalTo(addressView)
//        }
        paymentIdField.snp.makeConstraints { (make) in
            make.top.equalTo(addressTipLabel.snp.bottom).offset(20)
            make.left.right.equalTo(addressView)
        }
        payIdLimitLab.snp.makeConstraints { (make) in
            make.right.equalTo(paymentIdField)
            make.top.equalTo(paymentIdField.snp.bottom).offset(3)
        }
        integartedAddressField.snp.makeConstraints { (make) in
            make.top.equalTo(paymentIdField.snp.bottom).offset(20)
            make.left.right.equalTo(paymentIdField)
        }
        
        copyPayIdBtn.snp.makeConstraints { (make) in
            make.size.equalTo(32)
            make.right.bottom.equalTo(paymentIdField)
        }
        newPayIdBtn.snp.makeConstraints { (make) in
            make.size.equalTo(32)
            make.right.equalTo(copyPayIdBtn.snp.left).offset(-5)
            make.bottom.equalTo(copyPayIdBtn)
        }
        addressVSPayIdCopyBtn.snp.makeConstraints { (make) in
            make.size.equalTo(32)
            make.right.bottom.equalTo(integartedAddressField)
        }
        
        unfoldBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(120)
            make.top.equalTo(addressTipLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        unfoldBtn.setNeedsLayout()
        unfoldBtn.layoutIfNeeded()
        setNeedsLayout()
        layoutIfNeeded()
        
    }
    
    
    // MARK: - Methods (Private)
    
    private func createTextView() -> WKTextView {
        let textView = WKTextView()
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 30, right: 10)
        textView.backgroundColor = AppTheme.Color.alert_textView
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        textView.placeholderFont = AppTheme.Font.text_normal
        textView.font = AppTheme.Font.text_normal
        textView.textColor = AppTheme.Color.text_dark
        textView.placeholderColor = AppTheme.Color.text_light
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byCharWrapping
        return textView
    }
    
    private func createIconBtn(icon: UIImage?) -> UIButton {
        let btn = UIButton()
        btn.setImage(icon, for: .normal)
        return btn
    }
    
    func setUnFold(_ bool: Bool) {        
        paymentIdField.isHidden = !bool
        integartedAddressField.isHidden = !bool
        
        copyPayIdBtn.isHidden = !bool
        newPayIdBtn.isHidden = !bool
        addressVSPayIdCopyBtn.isHidden = !bool
        
        payIdLimitLab.isHidden = !bool
        
        unfoldBtn.snp.remakeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(120)
            if bool {
                make.top.equalTo(integartedAddressField.snp.bottom).offset(10)
            } else {
                make.top.equalTo(addressTipLabel.snp.bottom).offset(10)
            }
            make.bottom.equalToSuperview().offset(-10)
        }
        
        self.layoutIfNeeded()
    }
    
}

// MARK: -

extension ReceiveView: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return !textView.isSecureTextEntry
    }
}
