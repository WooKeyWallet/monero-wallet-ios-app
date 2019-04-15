//
//  ImportFromKeysViewController.swift


import UIKit

class ImportFromKeysController: BaseViewController {

    // MARK: - Properties (Private)
    
    private let viewModel: ImportWalletViewModel
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var scrollView: AutoLayoutScrollView = {
        return AutoLayoutScrollView()
    }()
    
    private lazy var tipsLabel: WKTipsLabel = {
        let tips = WKTipsLabel()
        tips.text = LocalizedString(key: "keys.input.tips", comment: "")
        tips.textColor = AppTheme.Color.text_gray
        tips.font = AppTheme.Font.text_smaller
        tips.dotColor = AppTheme.Color.button_disable
        return tips
    }()
    
    private lazy var keysForLookFieldTitleLab: UILabel = {
        let label = UILabel()
        label.text = LocalizedString(key: "secretViewKey", comment: "")
        label.textColor = AppTheme.Color.text_dark
        label.textAlignment = .center
        label.font = AppTheme.Font.text_normal.medium()
        return label
    }()
    
    private lazy var keysForLookField: WKTextView = {
        let textV = WKTextView()
        textV.font = AppTheme.Font.text_normal
        textV.placeholderFont = AppTheme.Font.text_normal
        textV.placeholder = LocalizedString(key: "keys.input.look", comment: "")
        textV.placeholderColor = AppTheme.Color.text_light
        textV.textColor = AppTheme.Color.text_dark
        textV.textContainer.lineFragmentPadding = 0
        textV.textContainerInset = UIEdgeInsets(top: 15, left: 11, bottom: 15, right: 11)
        textV.backgroundColor = AppTheme.Color.alert_textView
        textV.layer.cornerRadius = 5
        textV.isScrollEnabled = false
        textV.keyboardType = .alphabet
        return textV
    }()
    
    private lazy var keysForPayFieldTitleLab: UILabel = {
        let label = UILabel()
        label.text = LocalizedString(key: "secretSpendKey", comment: "")
        label.textColor = AppTheme.Color.text_dark
        label.textAlignment = .center
        label.font = AppTheme.Font.text_normal.medium()
        return label
    }()
    
    private lazy var keysForPayField: WKTextView = {
        let textV = WKTextView()
        textV.font = AppTheme.Font.text_normal
        textV.placeholderFont = AppTheme.Font.text_normal
        textV.placeholder = LocalizedString(key: "keys.input.pay", comment: "")
        textV.placeholderColor = AppTheme.Color.text_light
        textV.textColor = AppTheme.Color.text_dark
        textV.textContainer.lineFragmentPadding = 0
        textV.textContainerInset = UIEdgeInsets(top: 15, left: 11, bottom: 15, right: 11)
        textV.backgroundColor = AppTheme.Color.alert_textView
        textV.layer.cornerRadius = 5
        textV.isScrollEnabled = false
        textV.keyboardType = .alphabet
        return textV
    }()
    
    private lazy var addressFieldTitleLab: UILabel = {
        let label = UILabel()
        label.text = LocalizedString(key: "walletAddress", comment: "")
        label.textColor = AppTheme.Color.text_dark
        label.textAlignment = .center
        label.font = AppTheme.Font.text_normal.medium()
        return label
    }()
    
    private lazy var addressField: WKTextView = {
        let textV = WKTextView()
        textV.font = AppTheme.Font.text_normal
        textV.placeholderFont = AppTheme.Font.text_normal
        textV.placeholder = LocalizedString(key: "keys.input.address", comment: "")
        textV.placeholderColor = AppTheme.Color.text_light
        textV.textColor = AppTheme.Color.text_dark
        textV.textContainer.lineFragmentPadding = 0
        textV.textContainerInset = UIEdgeInsets(top: 15, left: 11, bottom: 15, right: 11)
        textV.backgroundColor = AppTheme.Color.alert_textView
        textV.layer.cornerRadius = 5
        textV.isScrollEnabled = false
        textV.keyboardType = .alphabet
        return textV
    }()
    
    private lazy var blockTipsLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizedString(key: "blockHeight.tips", comment: "")
        label.textColor = AppTheme.Color.main_green_light
        label.font = AppTheme.Font.text_smaller
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var blockNumField: WKFloatingLabelTextField = {
        let field = WKFloatingLabelTextField.createTextField()
        field.title = LocalizedString(key: "words.input.blockNum", comment: "")
        field.placeholder = LocalizedString(key: "words.input.blockNum", comment: "")
        field.keyboardType = .numberPad
        return field
    }()
    
    private lazy var recentTransDateField: WKFloatingLabelTextField = {
        let field = WKFloatingLabelTextField.createTextField()
        field.title = LocalizedString(key: "words.input.transDate", comment: "")
        field.placeholder = LocalizedString(key: "words.input.transDate", comment: "")
        field.delegate = self
        return field
    }()
    
    private lazy var nextBtn: UIButton = {
        let btn = UIButton.createCommon([
            UIButton.TitleAttributes.init(LocalizedString(key: "import", comment: ""), titleColor: AppTheme.Color.button_title, state: .normal)
            ], backgroundColor: AppTheme.Color.main_blue)
        return btn
    }()
    
    
    // MARK: - Life Cycles
    
    required init(viewModel: ImportWalletViewModel) {
        self.viewModel = viewModel
        super.init()
        self.title = LocalizedString(key: "wallet.import.fromKeys", comment: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        super.configureUI()
        
        scrollView.isScrollOnlySelf = true
        view.addSubview(scrollView)
        scrollView.contentView.addSubViews([
            tipsLabel,
            keysForLookFieldTitleLab,
            keysForLookField,
            keysForPayFieldTitleLab,
            keysForPayField,
            addressFieldTitleLab,
            addressField,
            blockTipsLabel,
            blockNumField,
            recentTransDateField,
            nextBtn,
        ])
        
        do /// configureConstraints
        {
            tipsLabel.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(15)
                make.left.equalToSuperview().offset(25)
                make.right.equalToSuperview().offset(-25)
            }
            keysForLookFieldTitleLab.snp.makeConstraints { (make) in
                make.top.equalTo(tipsLabel.snp.bottom).offset(20)
                make.left.right.equalTo(tipsLabel)
            }
            keysForLookField.snp.makeConstraints { (make) in
                make.top.equalTo(keysForLookFieldTitleLab.snp.bottom).offset(15)
                make.left.right.equalTo(keysForLookFieldTitleLab)
                make.height.greaterThanOrEqualTo(90)
            }
            keysForPayFieldTitleLab.snp.makeConstraints { (make) in
                make.top.equalTo(keysForLookField.snp.bottom).offset(25)
                make.left.right.equalTo(keysForLookField)
            }
            keysForPayField.snp.makeConstraints { (make) in
                make.top.equalTo(keysForPayFieldTitleLab.snp.bottom).offset(15)
                make.left.right.equalTo(keysForPayFieldTitleLab)
                make.height.greaterThanOrEqualTo(90)
            }
            addressFieldTitleLab.snp.makeConstraints { (make) in
                make.top.equalTo(keysForPayField.snp.bottom).offset(25)
                make.left.right.equalTo(keysForPayField)
            }
            addressField.snp.makeConstraints { (make) in
                make.top.equalTo(addressFieldTitleLab.snp.bottom).offset(15)
                make.left.right.equalTo(addressFieldTitleLab)
                make.height.greaterThanOrEqualTo(90)
            }
            blockTipsLabel.snp.makeConstraints { (make) in
                make.top.equalTo(addressField.snp.bottom).offset(30)
                make.left.right.equalTo(addressField)
            }
            blockNumField.snp.makeConstraints { (make) in
                make.top.equalTo(blockTipsLabel.snp.bottom).offset(15)
                make.left.right.equalTo(blockTipsLabel)
            }
            recentTransDateField.snp.makeConstraints { (make) in
                make.top.equalTo(blockNumField.snp.bottom).offset(15)
                make.left.right.equalTo(blockNumField)
            }
            nextBtn.snp.makeConstraints { (make) in
                make.top.equalTo(recentTransDateField.snp.bottom).offset(50)
                make.left.right.equalTo(recentTransDateField)
                make.height.equalTo(50)
            }
            
            scrollView.resizeContentLayout()
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        /// Actions
        
        keysForLookField.tag = 1
        keysForPayField.tag = 2
        addressField.tag = 3
        
        keysForLookField.delegate = self
        keysForPayField.delegate = self
        addressField.delegate = self
        
        blockNumField.addTarget(self, action: #selector(self.blockNumAction(sender:)), for: .editingChanged)
        
        nextBtn.addTarget(self, action: #selector(self.nextBtnAction), for: .touchUpInside)
        
        
        /// ViewModel -> View
        
        viewModel.fromKeysDateState.observe(recentTransDateField) { (date, field) in
            if let date = date {
                field.text = date.toString()
            }
        }
        
        viewModel.fromKeysNextState.observe(nextBtn) { (isEnable, btn) in
            btn.isEnabled = isEnable
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func blockNumAction(sender: UITextField) {
        viewModel.fromKeysBlockNumInput(text: sender.text!)
    }
    
    @objc private func recentTransDateAction(sender: UITextField) {
        keysForLookField.endEditing(true)
        keysForPayField.endEditing(true)
        addressField.endEditing(true)
        blockNumField.endEditing(true)
        self.viewModel.fromKeysRecentDate()
        DispatchQueue.main.async {
            self.keysForLookField.endEditing(true)
            self.keysForPayField.endEditing(true)
            self.addressField.endEditing(true)
            self.blockNumField.endEditing(true)
        }
    }
    
    @objc private func nextBtnAction() {
        viewModel.recoveryFromKeys()
    }
    
}

extension ImportFromKeysController: UITextViewDelegate, UITextFieldDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        switch textView.tag {
        case 1:
            viewModel.viewKeysInput(text: textView.text)
        case 2:
            viewModel.spendKeysInput(text: textView.text)
        case 3:
            viewModel.addressInput(text: textView.text)
        default:
            break
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        recentTransDateAction(sender: recentTransDateField)
        return false
    }
}
