//
//  SendDetailView.swift


import UIKit

class SendDetailView: UIView {

    // MARK: - Properties (Lazy)
    
    public lazy var toAddressField: JVFloatLabeledTextView = {
        let field = JVFloatLabeledTextView.createTextView()
        field.floatingLabel.text = LocalizedString(key: "send.address", comment: "")
        field.placeholder = LocalizedString(key: "send.address", comment: "")
        field.keyboardType = .alphabet
        return field
    }()
    
    public lazy var amountField: JVFloatLabeledTextView = {
        let field = JVFloatLabeledTextView.createTextView()
        field.floatingLabel.text = LocalizedString(key: "send.amount", comment: "")
        field.placeholder = LocalizedString(key: "send.amount", comment: "")
        field.keyboardType = .decimalPad
        return field
    }()
    
    public lazy var paymentIdField: JVFloatLabeledTextView = {
        let field = JVFloatLabeledTextView.createTextView()
        field.floatingLabel.text = "Payment ID \(LocalizedString(key: "optional", comment: ""))"
        field.placeholder = "Payment ID \(LocalizedString(key: "optional", comment: ""))"
        field.keyboardType = .alphabet
        return field
    }()
    
    public lazy var addressSelectBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "toAddress_select"), for: .normal)
        return btn
    }()
    
    public lazy var allinBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "amount_allin"), for: .normal)
        return btn
    }()
    
    public lazy var paymentIdSwitch: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "paymentId_switch"), for: .normal)
        return btn
    }()
    
    public lazy var paymentIdLimitTip: UILabel = {
        let label = UILabel()
        label.text = "0/64"
        label.textColor = AppTheme.Color.text_light
        label.font = AppTheme.Font.text_smaller
        return label
    }()
    
    public lazy var sendBtn: UIButton = {
        return UIButton.createCommon([UIButton.TitleAttributes.init(LocalizedString(key: "send", comment: ""), titleColor: AppTheme.Color.button_title, state: .normal)], backgroundColor: AppTheme.Color.main_blue)
    }()
    
    
    private lazy var addressLine = { UIView() }()
    private lazy var amountLine = { UIView() }()
    private lazy var paymentIdLine = { UIView() }()
    
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
        
        backgroundColor = AppTheme.Color.page_common
        
        addressLine.backgroundColor = UIColor(hex: 0xC3C7CB)
        amountLine.backgroundColor = UIColor(hex: 0xC3C7CB)
        paymentIdLine.backgroundColor = UIColor(hex: 0xC3C7CB)
        
        addSubViews([
        toAddressField,
        addressSelectBtn,
        amountField,
        allinBtn,
        paymentIdField,
        paymentIdSwitch,
        paymentIdLimitTip,
        sendBtn,
        
        addressLine,
        amountLine,
        paymentIdLine,
        ])
    }
    
    internal func configureConstraints() {
        toAddressField.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-65)
        }
        addressSelectBtn.snp.makeConstraints { (make) in
            make.left.equalTo(toAddressField.snp.right).offset(12)
            make.top.equalTo(toAddressField.snp.top).offset(14)
            make.width.height.equalTo(22)
        }
        addressLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(toAddressField)
            make.height.equalTo(1)
        }
        
        amountField.snp.makeConstraints { (make) in
            make.left.right.equalTo(toAddressField)
            make.top.equalTo(toAddressField.snp.bottom).offset(15)
        }
        allinBtn.snp.makeConstraints { (make) in
            make.left.equalTo(amountField.snp.right).offset(12)
            make.top.equalTo(amountField.snp.top).offset(14)
            make.width.height.equalTo(22)
        }
        amountLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(amountField)
            make.height.equalTo(1)
        }
        
        paymentIdField.snp.makeConstraints { (make) in
            make.left.right.equalTo(amountField)
            make.top.equalTo(amountField.snp.bottom).offset(15)
        }
        paymentIdSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(paymentIdField.snp.right).offset(12)
            make.top.equalTo(paymentIdField.snp.top).offset(14)
            make.width.height.equalTo(22)
        }
        paymentIdLimitTip.snp.makeConstraints { (make) in
            make.right.equalTo(paymentIdField)
            make.top.equalTo(paymentIdField.snp.bottom).offset(5)
        }
        paymentIdLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(paymentIdField)
            make.height.equalTo(1)
        }
        
        sendBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-25)
            make.height.equalTo(50)
            make.top.equalTo(paymentIdField.snp.bottom).offset(65)
            make.bottom.equalToSuperview().offset(-30)
        }
    }
    

}
