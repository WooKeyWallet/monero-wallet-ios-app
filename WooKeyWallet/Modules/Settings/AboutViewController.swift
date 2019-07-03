//
//  AboutViewController.swift


import UIKit

class AboutViewController: BaseViewController {
    
    // MARK: - Properties (Public)
    
    
    // MARK: - Life Cycle

    override func configureUI() {
        super.configureUI()
        
        navigationItem.title = LocalizedString(key: "settings.about", comment: "")
        
        do /// Views
        {
            let iconView = UIImageView()
            iconView.image = UIImage.bundleImage("team_logo")
            view.addSubview(iconView)
            
            let versionLabel = UILabel()
            versionLabel.text = LocalizedString(key: "version.no", comment: "") + " V " + AppInfo.appVersion
            versionLabel.textColor = AppTheme.Color.text_dark
            versionLabel.textAlignment = .center
            versionLabel.font = AppTheme.Font.text_smaller
            view.addSubview(versionLabel)
            
            let textView = UITextView()
            textView.attributedText = NSAttributedString(string: LocalizedString(key: "about.text", comment: "")).addLineSpace(5)
            textView.font = AppTheme.Font.text_smaller
            textView.textAlignment = .center
            textView.textColor = AppTheme.Color.text_light
            textView.textContainerInset = .zero
            textView.isScrollEnabled = false
            textView.isEditable = false
            view.addSubview(textView)
            
            let btnContainer = UIView()
            view.addSubview(btnContainer)
            
            let btnLabel = UILabel()
            btnLabel.text = AppInfo.displayName
            btnLabel.textColor = AppTheme.Color.text_light
            btnLabel.font = UIFont.systemFont(ofSize: 11)
            btnContainer.addSubview(btnLabel)
            
            let btn = UIButton()
            btn.setTitle(LocalizedString(key: "about.service", comment: ""), for: .normal)
            btn.setTitleColor(AppTheme.Color.text_dark, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 11)
            btnContainer.addSubview(btn)
            btn.addTarget(self, action: #selector(self.toServiceBookAction), for: .touchUpInside)
            
            iconView.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(versionLabel.snp.top).offset(-16)
                make.size.equalTo(CGSize(width: 152, height: 110))
            }
            versionLabel.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(textView.snp.top).offset(-34)
            }
            textView.snp.makeConstraints { (make) in
                make.left.equalTo(50)
                make.right.equalTo(-50)
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(44)
            }
            btnContainer.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                if #available(iOS 11, *) {
                    make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
                } else {
                    make.bottom.equalTo(-20)
                }
                make.height.equalTo(30)
            }
            btnLabel.snp.makeConstraints { (make) in
                make.left.top.bottom.equalTo(0)
            }
            btn.snp.makeConstraints { (make) in
                make.right.top.bottom.equalTo(0)
                make.left.equalTo(btnLabel.snp.right).offset(3)
            }
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func toServiceBookAction() {
        let web = WebViewController.init(WooKeyURL.serviceBook.url)
        navigationController?.pushViewController(web, animated: true)
    }

}
