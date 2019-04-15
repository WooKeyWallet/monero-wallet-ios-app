//
//  SeedAlertViewController.swift


import UIKit

class SeedAlertViewController: BaseViewController {

    // MARK: - Properties (Lazy)
    
    private lazy var contentView: CustomAlertView = {
        return CustomAlertView()
    }()
    
    
    // MARK: - Life Cycles
    
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
            contentView.topIconView.image = UIImage(named: "ban_snapshot")
            contentView.titleStatusView.backgroundColor = AppTheme.Color.status_red
            contentView.titleLabel.text = LocalizedString(key: "recovery.alert.title", comment: "")
            contentView.contentLabel.text = LocalizedString(key: "recovery.alert.text", comment: "")
            contentView.confirmBtn.setTitle(LocalizedString(key: "ok", comment: ""), for: .normal)
            contentView.cancelBtn.isHidden = true
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        contentView.confirmBtn.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func confirmAction() {
        dismiss(animated: false, completion: nil)
    }

    
}
