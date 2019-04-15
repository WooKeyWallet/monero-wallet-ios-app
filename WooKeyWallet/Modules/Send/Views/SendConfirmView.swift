//
//  SendConfirmView.swift


import UIKit

class SendConfirmView: UIView {

    // MARK: - Properties (Lazy)
    
    private lazy var tokenIcon: UIImageView = {
        let iconV = UIImageView()
        iconV.layer.cornerRadius = 17.5
        iconV.layer.masksToBounds = true
        iconV.contentMode = .scaleAspectFill
        return iconV
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.textAlignment = .center
        label.font = AppTheme.Font.text_huge.medium()
        return label
    }()
    
    private lazy var toAddressField: JVFloatLabeledTextView = {
        let field = JVFloatLabeledTextView.createTextView()
        field.floatingLabel.text = LocalizedString(key: "send.address", comment: "")
        field.placeholder = LocalizedString(key: "send.address", comment: "")
        field.isEditable = false
        return field
    }()
    
    private lazy var feeField: JVFloatLabeledTextView = {
        let field = JVFloatLabeledTextView.createTextView()
        field.floatingLabel.text = LocalizedString(key: "send.fee", comment: "")
        field.placeholder = LocalizedString(key: "send.fee", comment: "")
        field.isEditable = false
        return field
    }()
    
    private lazy var paymentIdField: JVFloatLabeledTextView = {
        let field = JVFloatLabeledTextView.createTextView()
        field.floatingLabel.text = "Payment ID\(LocalizedString(key: "optional", comment: ""))"
        field.placeholder = "Payment ID\(LocalizedString(key: "optional", comment: ""))"
        field.isEditable = false
        return field
    }()
    
    public lazy var confirmBtn: UIButton = {
        return UIButton.createCommon([UIButton.TitleAttributes.init(LocalizedString(key: "confirm", comment: ""), titleColor: AppTheme.Color.button_title, state: .normal)], backgroundColor: AppTheme.Color.main_blue)
    }()
    
    
    private lazy var addressLine = { UIView() }()
    private lazy var feeLine = { UIView() }()
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
        
        addressLine.backgroundColor = AppTheme.Color.cell_line
        feeLine.backgroundColor = AppTheme.Color.cell_line
        paymentIdLine.backgroundColor = AppTheme.Color.cell_line
        
        addSubViews([
            tokenIcon,
            amountLabel,
            toAddressField,
            feeField,
            paymentIdField,
            confirmBtn,
            
            addressLine,
            feeLine,
            paymentIdLine,
        ])
    }
    
    internal func configureConstraints() {
        
        tokenIcon.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(25)
            make.width.height.equalTo(35)
        }
        
        amountLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(tokenIcon.snp.bottom).offset(15)
        }
        
        toAddressField.snp.makeConstraints { (make) in
            make.top.equalTo(amountLabel.snp.bottom).offset(29)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-25)
        }
        addressLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(toAddressField)
            make.height.equalTo(1)
        }
        
        feeField.snp.makeConstraints { (make) in
            make.left.right.equalTo(toAddressField)
            make.top.equalTo(toAddressField.snp.bottom).offset(15)
        }
        feeLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(feeField)
            make.height.equalTo(1)
        }
        
        paymentIdField.snp.makeConstraints { (make) in
            make.left.right.equalTo(feeField)
            make.top.equalTo(feeField.snp.bottom).offset(15)
        }
        paymentIdLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(paymentIdField)
            make.height.equalTo(1)
        }
        
        confirmBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(paymentIdLine)
            make.height.equalTo(50)
            make.top.equalTo(paymentIdField.snp.bottom).offset(50)
            make.bottom.equalToSuperview().offset(-30)
        }
    }
    
    public func configureModel(model: SendDetail) {
        tokenIcon.image = model.tokenIcon
        amountLabel.text = model.amount + " " + model.token
        toAddressField.text = model.address
        feeField.text = model.fee
        paymentIdField.text = model.paymentId
    }

}
