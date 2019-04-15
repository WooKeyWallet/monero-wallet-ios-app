//
//  AddNodeForTokenController.swift


import UIKit

class AddNodeForTokenController: BaseViewController {
    
    // MARK: - Properties (Public)
    
    public let viewModel: TokenNodeListViewModel
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var contentView: CustomAlertView = {
        return CustomAlertView()
    }()
    
    private lazy var textView: WKTextView = {
        let textV = WKTextView()
        textV.font = AppTheme.Font.text_small
        textV.placeholderFont = AppTheme.Font.text_small
        textV.placeholder = LocalizedString(key: "node.add.alert.placeholder", comment: "")
        textV.placeholderColor = AppTheme.Color.text_light
        textV.textColor = AppTheme.Color.text_dark
        textV.textContainer.lineFragmentPadding = 0
        textV.textContainerInset = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
        textV.backgroundColor = AppTheme.Color.alert_textView
        textV.layer.cornerRadius = 5
        textV.isScrollEnabled = false
        return textV
    }()
    
    
    
    // MARK: - Life Cycles
    
    required init(viewModel: TokenNodeListViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = contentView
    }
    
    override func configureUI() {
        super.configureUI()
        
        do /// Subviews
        {
            // contentView
            contentView.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
            contentView.titleStatusView.backgroundColor = AppTheme.Color.status_green
            contentView.titleLabel.text = LocalizedString(key: "node.add.alert.title", comment: "")
            contentView.contentLabel.text = LocalizedString(key: "node.add.alert.msg", comment: "")
            contentView.contentLabel.font = AppTheme.Font.text_smaller
            contentView.contentLabel.textAlignment = .center

            // textView
            contentView.customView.addSubview(textView)
            textView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        contentView.cancelBtn.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        contentView.confirmBtn.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func cancelAction() {
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func confirmAction() {
        viewModel.addNode(textView.text) { (success) in
            guard success else { return }
            self.dismiss(animated: false, completion: nil)
        }
    }

}


