//
//  ImportFromWordsController.swift


import UIKit

class ImportFromWordsController: BaseViewController {
    
    
    // MARK: - Properties (Private)
    
    private let viewModel: ImportWalletViewModel
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var scrollView: AutoLayoutScrollView = {
        return AutoLayoutScrollView()
    }()
    
    private lazy var wordsFieldTitleLab: UILabel = {
        let label = UILabel()
        label.text = LocalizedString(key: "words.input.title", comment: "")
        label.textColor = AppTheme.Color.text_dark
        label.textAlignment = .center
        label.font = AppTheme.Font.text_normal.medium()
        return label
    }()
    
    private lazy var wordsField: WKTextView = {
        let textV = WKTextView()
        textV.font = AppTheme.Font.text_normal
        textV.placeholderFont = AppTheme.Font.text_normal
        textV.placeholder = LocalizedString(key: "words.input.placeholder", comment: "")
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
        self.title = LocalizedString(key: "wallet.import.fromWords", comment: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        super.configureUI()
        
        scrollView.isScrollOnlySelf = true
        view.addSubview(scrollView)
        scrollView.contentView.addSubViews([
        wordsFieldTitleLab,
        wordsField,
        blockTipsLabel,
        blockNumField,
        recentTransDateField,
        nextBtn,
        ])
        
        do /// configureConstraints
        {
            wordsFieldTitleLab.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(25)
                make.centerX.equalToSuperview()
            }
            wordsField.snp.makeConstraints { (make) in
                make.top.equalTo(wordsFieldTitleLab.snp.bottom).offset(15)
                make.left.equalToSuperview().offset(25)
                make.right.equalToSuperview().offset(-25)
                make.height.greaterThanOrEqualTo(90)
            }
            blockTipsLabel.snp.makeConstraints { (make) in
                make.top.equalTo(wordsField.snp.bottom).offset(30)
                make.left.right.equalTo(wordsField)
            }
            recentTransDateField.snp.makeConstraints { (make) in
                make.top.equalTo(blockTipsLabel.snp.bottom).offset(15)
                make.left.right.equalTo(blockTipsLabel)
            }
            blockNumField.snp.makeConstraints { (make) in
                make.top.equalTo(recentTransDateField.snp.bottom).offset(15)
                make.left.right.equalTo(recentTransDateField)
            }
            nextBtn.snp.makeConstraints { (make) in
                make.top.equalTo(blockNumField.snp.bottom).offset(50)
                make.left.right.equalTo(blockNumField)
                make.height.equalTo(50)
            }
            
            scrollView.resizeContentLayout()
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        wordsField.delegate = self
        
        /// Actions
        
        blockNumField.addTarget(self, action: #selector(self.blockNumFieldAction(sender:)), for: .editingChanged)
        nextBtn.addTarget(self, action: #selector(self.nextBtnAction), for: .touchUpInside)
        
        /// ViewModel -> View
        
        viewModel.fromSeedDateState.observe(recentTransDateField) { (date, field) in
            if let date = date {
                field.text = date.toString()
            }
        }
        
        viewModel.fromSeedNextState.observe(nextBtn) { (isEnable, btn) in
            btn.isEnabled = isEnable
        }
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func blockNumFieldAction(sender: UITextField) {
        viewModel.fromSeedBlockNumInput(text: sender.text!)
    }
    
    @objc private func recentTransDateFieldAction(sender: UITextField) {
        wordsField.endEditing(true)
        blockNumField.endEditing(true)
        self.viewModel.fromSeedRecentDate()
        DispatchQueue.main.async {
            self.wordsField.endEditing(true)
            self.blockNumField.endEditing(true)
        }
    }
    
    @objc private func nextBtnAction() {
        viewModel.recoveryFromSeed()
    }

}

extension ImportFromWordsController: UITextViewDelegate, UITextFieldDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        scrollView.resizeContentLayout()
        viewModel.seedInput(text: textView.text)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        recentTransDateFieldAction(sender: recentTransDateField)
        return false
    }
}

