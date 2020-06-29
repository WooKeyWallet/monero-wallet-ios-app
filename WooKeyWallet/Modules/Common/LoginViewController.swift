//
//  SendConfirmPwdViewController.swift


import UIKit

class LoginViewController: BaseViewController {
    
    // MARK: - Properties (Private)
    
    private let walletName: String
    
    private var loginHandler: ((String?) -> Void)?
    

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
    
    private lazy var textView: UITextField = {
        let textV = UITextField()
        textV.font = AppTheme.Font.text_small
        textV.textColor = AppTheme.Color.text_dark
        textV.backgroundColor = AppTheme.Color.alert_textView
        textV.keyboardType = .alphabet
        textV.isSecureTextEntry = true
        return textV
    }()
    
    private lazy var errorMessageLab: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_warning
        label.font = AppTheme.Font.text_smaller
        return label
    }()
    
    
    // MARK: - Life Cycles
    
    required init(_ walletName: String) {
        self.walletName = walletName
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
            contentView.titleLabel.text = LocalizedString(key: "send.confirm.pwd.title", comment: "")
            contentView.confirmBtn.setTitle(LocalizedString(key: "confirm", comment: ""), for: .normal)
            
            // textView
            pwdBG.addSubview(textView)
            contentView.customView.addSubViews([
            pwdBG,
            errorMessageLab,
            ])
            textView.snp.makeConstraints { (make) in
                make.top.bottom.equalTo(0)
                make.left.equalTo(10)
                make.right.equalTo(-10)
            }
            pwdBG.snp.makeConstraints { (make) in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(42)
            }
            errorMessageLab.snp.makeConstraints { (make) in
                make.top.equalTo(textView.snp.bottom).offset(10)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        contentView.confirmBtn.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        contentView.cancelBtn.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        textView.addTarget(self, action: #selector(self.pwdInputAction(_:)), for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    // MARK: - Methods (Public)
    
    public class func loginWithOptions(_ options: LocalAuthOptions, walletName: String, loginResult: ((String?) -> Void)?) {
        let storage = WalletDefaults(wallet: walletName)
        if storage.localAuthOptions.contains(options) && (storage.hasFaceOrTouchID || storage.hasGesturePassword) {
            if storage.hasFaceOrTouchID {
                LocalAuth.default.evaluatePolicy(LocalizedString(key: LocalizedString(key: "localAuth.verify", comment: ""), comment: "")) { (result) in
                    switch result {
                    case .success:
                        if let rsaPwd = KeyChain.string(forKey: walletName) {
                            loginResult?(RSA(decrypt: rsaPwd).string)
                        } else {
                            loginResult?(nil)
                        }
                    case .failure(let error):
                        switch error {
                        case .passcodeNotSet:
                            HUD.showError(LocalizedString(key: "passcodeNotSet", comment: ""))
                        case .biometryNotAvailable:
                            HUD.showError(LocalizedString(key: "biometryNotAvailable", comment: ""))
                        case .biometryNotEnrolled:
                            HUD.showError(LocalizedString(key: "biometryNotEnrolled", comment: ""))
                        case .biometryLockout:
                            HUD.showError(LocalizedString(key: "biometryLockout", comment: ""))
                        default: break
                        }
                        switch error {
                        case .authenticationFailed, .userFallback, .passcodeNotSet, .biometryLockout, .biometryNotAvailable, .biometryNotEnrolled:
                            self.show(walletName: walletName, loginResult: loginResult)
                        default: break
                        }
                    }
                }
            } else {
                let passwordManager = LocalAuthGesturePassword(walletName) { (result) in
                    switch result {
                    case .success:
                        if let rsaPwd = KeyChain.string(forKey: walletName) {
                            loginResult?(RSA(decrypt: rsaPwd).string)
                        } else {
                            loginResult?(nil)
                        }
                    case .failure:
                        self.show(walletName: walletName, loginResult: loginResult)
                    }
                }
                let vc = GesturePwdViewController(type: .vertify, passwordManager: passwordManager)
                let nvc = NavigationController(rootViewController: vc)
                UIApplication.shared.keyWindow?.rootViewController?.present(nvc, animated: true, completion: nil)
            }
        } else {
            show(walletName: walletName, loginResult: loginResult)
        }
    }
    
    public class func show(_ cancelHidden: Bool = false, walletName: String, loginResult: ((String?) -> Void)?) {
        let vc = self.init(walletName)
        vc.loginHandler = loginResult
        vc.contentView.cancelBtn.isHidden = cancelHidden
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: false, completion: nil)
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func pwdInputAction(_ field: UITextField) {
        
    }
    
    @objc private func cancelAction() {
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func confirmAction() {
        let pwd = self.textView.text!
        guard WalletService.shared.verifyPassword(self.walletName, password: pwd) else {
            self.errorMessageLab.text = LocalizedString(key: "wallet.login.error", comment: "")
            return
        }
        self.loginHandler?(pwd)
        self.dismiss(animated: false, completion: nil)
    }
    
    

}
