//
//  WKAlertController.swift


import UIKit

class WKAlertController: BaseViewController {
    
    // MARK: - Properties (Public)
    
    public var containerColor: UIColor = UIColor(white: 0, alpha: 0.5)
    public var icon: UIImage?
    public var statusColor: UIColor = AppTheme.Color.status_green
    public var alertTitle: String = ""
    public var message: String = ""
    public var confirmTitle: String = "OK"
    public var showCancel: Bool = false
    public var confirmActionHandler: (() -> Void)?
    public var msgAlignment: NSTextAlignment = .left
    

    // MARK: - Properties (Lazy)
    
    private lazy var contentView: CustomAlertView = {
        return CustomAlertView()
    }()
    
    
    // MARK: - Life Cycles
    
    override init() {
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
            contentView.backgroundColor = containerColor
            contentView.topIconView.image = icon
            contentView.titleStatusView.backgroundColor = statusColor
            contentView.titleLabel.text = alertTitle
            contentView.contentLabel.text = message
            contentView.contentLabel.textAlignment = msgAlignment
            contentView.confirmBtn.setTitle(confirmTitle, for: .normal)
            contentView.cancelBtn.isHidden = !showCancel
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        contentView.confirmBtn.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        contentView.cancelBtn.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func confirmAction() {
        confirmActionHandler?()
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func cancelAction() {
        dismiss(animated: false, completion: nil)
    }
}
