//
//  ContactUsViewController.swift
//  Wookey
//

import UIKit

enum ContactStyle: Int {
    
    case telegram
    case twitter
    case github
    case facebook
    
    var name: String {
        switch self {
        case .telegram:
            return "Telegram"
        case .twitter:
            return "Twitter"
        case .github:
            return "GitHub"
        case .facebook:
            return "Facebook"
        }
    }
    
    var url: String {
        switch self {
        case .telegram:
            return "https://t.me/WooKeyWallet"
        case .twitter:
            return "https://twitter.com/WooKeyWallet"
        case .github:
            return "https://github.com/WooKeyWallet"
        case .facebook:
            return "https://www.facebook.com/WooKeyWalletOfficialChannel"
        }
    }
    
    var icon: UIImage? {
        return UIImage(named: name)
    }
}

class ContactUsViewCell: BaseTableViewCell {
    
    enum Action: Int {
        case link
        case copy
    }
    
    private var actionHandler: ((Any) -> Void)?
    
    private lazy var linkBtn: UIButton = {
        let btn = UIButton()
//        btn.setTitleColor(UIColor(hex: 0x2179FF), for: .normal)
//        btn.setTitleColor(UIColor(hex: 0x2179FF).highlighted(), for: .highlighted)
        btn.setTitleColor(AppTheme.Color.text_light, for: .normal)
        btn.titleLabel?.font = AppTheme.Font.text_small
        btn.titleLabel?.numberOfLines = 0
        btn.contentEdgeInsets = .zero
        btn.contentHorizontalAlignment = .left
        btn.titleEdgeInsets = .zero
        btn.imageEdgeInsets = .zero
        return btn
    }()
    
    private lazy var copyBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "btn_copy"), for: .normal)
        return btn
    }()
    
    override func initCell() {
        super.initCell()
        nameLabel.font = AppTheme.Font.text_normal
        addSubViews([iconView, nameLabel, linkBtn, copyBtn])
//        linkBtn.addTarget(self, action: #selector(self.toLinkAction), for: .touchUpInside)
        copyBtn.addTarget(self, action: #selector(self.copyAction), for: .touchUpInside)
    }
    
    override func frameLayout() {
        let (iconSize, nameH, copySize) = (CGFloat(25), nameLabel.font.lineHeight, CGFloat(22))
        iconView.updateFrame(CGRect(x: 25, y: 20, width: iconSize, height: iconSize))
        nameLabel.updateFrame(CGRect(x: iconView.maxX + 10, y: iconView.midY - nameH * 0.5, width: 200, height: nameH))
        copyBtn.updateFrame(CGRect(x: width - copySize - 23, y: 43, width: copySize, height: copySize))
    }
    
    override func configure(with row: TableViewRow) {
        guard let model: ContactStyle = row.serializeModel() else { return }
        self.actionHandler = row.actionHandler
        iconView.image = model.icon
        nameLabel.text = model.name
        linkBtn.setTitle(model.url, for: .normal)
        let linkBoundingW = copyBtn.x - nameLabel.x
        let linkSize = model.url.boundingRect(with: CGSize.bounding(width: linkBoundingW), font: linkBtn.titleLabel!.font)
        linkBtn.updateFrame(CGRect(x: nameLabel.x, y: nameLabel.maxY + 2, width: linkSize.width, height: linkSize.height))
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func toLinkAction() {
        actionHandler?(Action.link)
    }
    
    @objc private func copyAction() {
        actionHandler?(Action.copy)
    }
}

class ContactUsViewController: BaseTableViewController {
    
    // MARK: - Properties (Public)
    
    override var rowHeight: CGFloat { return 90 }
    
    
    // MARK: - Life Cycle

    override func configureUI() {
        super.configureUI()
        
        navigationItem.title = LocalizedString(key: "settings.help", comment: "")
        
        do /// Views
        {
            tableView.backgroundColor = AppTheme.Color.page_common
            tableView.separatorInset.left = 25
            tableView.register(cellType: ContactUsViewCell.self)
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        dataSource = [
            getTableViewSection()
        ]
        
    }
    
    // MARK: - Methods (Private)
    
    private func getTableViewSection() -> TableViewSection {
        let styles: [ContactStyle] = [.telegram, .twitter, .github, .facebook]
        let rows = styles.map({ (style) -> TableViewRow in
            var row = TableViewRow(style, cellType: ContactUsViewCell.self, rowHeight: rowHeight)
            row.actionHandler = {
                action in
                guard let action = action as? ContactUsViewCell.Action else { return }
                switch action {
                case .copy:
                    UIPasteboard.general.string = style.url
                    HUD.showSuccess(LocalizedString(key: "copy_success", comment: ""))
                case .link:
                    AppManager.default.openSafari(with: style.url)
                }
            }
            return row
        })
        return TableViewSection(rows)
    }
    
    
    

}
