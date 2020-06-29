//
//  AlertInputViewController.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/5/8.
//  Copyright © 2020 Wookey. All rights reserved.
//

import UIKit

class AlertInputViewController: BaseViewController {

    // MARK: - Properties (Private)
            
    private let textField: UITextField
        
    private var actions = [WKAlertAction.Style: WKAlertAction]()
    

    // MARK: - Properties (Lazy)
    
    private lazy var contentView: CustomAlertView = {
        return CustomAlertView()
    }()
    
    private lazy var pwdBG: UIView = {
        let bg = UIView()
        bg.backgroundColor = AppTheme.Color.alert_textView
        bg.layer.cornerRadius = 5
        return bg
    }()
    
    private lazy var errorMessageLab: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_warning
        label.font = AppTheme.Font.text_smaller
        return label
    }()
    
    
    // MARK: - Life Cycles
    
    init(title: String?, textField: UITextField) {
        textField.font = AppTheme.Font.text_small
        textField.textColor = AppTheme.Color.text_dark
        textField.backgroundColor = AppTheme.Color.alert_textView
        self.textField = textField
        super.init()
        self.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addAction(_ action: WKAlertAction) {
        switch action.style {
        case .confirm:
            contentView.confirmBtn.setTitle(action.title, for: .normal)
        case .cancel:
            break
        }
        self.actions[action.style] = action
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
            contentView.titleLabel.text = title
            contentView.confirmBtn.isHidden = actions[.confirm] == nil
            contentView.cancelBtn.isHidden = actions[.cancel] == nil
            
            // textField
            pwdBG.addSubview(textField)
            contentView.customView.addSubViews([
            pwdBG,
            errorMessageLab,
            ])
            textField.snp.makeConstraints { (make) in
                make.top.bottom.equalTo(0)
                make.left.equalTo(10)
                make.right.equalTo(-10)
            }
            pwdBG.snp.makeConstraints { (make) in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(42)
            }
            errorMessageLab.snp.makeConstraints { (make) in
                make.top.equalTo(textField.snp.bottom).offset(10)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        contentView.confirmBtn.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        contentView.cancelBtn.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        textField.addTarget(self, action: #selector(self.pwdInputAction(_:)), for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func pwdInputAction(_ field: UITextField) {
        if errorMessageLab.text != nil {
            errorMessageLab.text = nil
        }
    }
    
    @objc private func cancelAction() {
        self.actions[.cancel]?.performAction()
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc private func confirmAction() {
//        let text = textField.text ?? ""
//        guard !text.isEmpty else {
//            errorMessageLab.text = LocalizedString(key: "input.empty.error", comment: "")
//            return
//        }
        self.actions[.confirm]?.performAction()
        self.dismiss(animated: false, completion: nil)
    }

}
