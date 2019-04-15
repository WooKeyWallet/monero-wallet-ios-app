//
//  LanguageViewController.swift


import UIKit

class LanguageViewController: BaseTableViewController {
    
    // MARK: - Properties (Public)
    
    override var rowHeight: CGFloat { return 62 }
    
    
    // MARK: - Life Cycle

    override func configureUI() {
        super.configureUI()
        
        do /// Views
        {
            navigationItem.title = LocalizedString(key: "language_select", comment: "")
            
            tableView.register(cellType: LanguageViewCell.self)
            tableView.separatorInset.left = 25
            tableView.backgroundColor = AppTheme.Color.page_common
        }
    }
    
    override func configureBinds() {
        var chinese: (String, Bool) = ("简体中文", false)
        var english: (String, Bool) = ("English", false)
        super.configureBinds()
        switch AppLanguage.manager.current {
        case .en:
            english.1 = true
        case .zh:
            chinese.1 = true
        }
        dataSource = [TableViewSection.init([
            TableViewRow.init(chinese, cellType: LanguageViewCell.self, rowHeight: 62),
            TableViewRow.init(english, cellType: LanguageViewCell.self, rowHeight: 62),
        ])]
        
        onDidSelectRow { (row, _) in
            guard let index = row.indexPath?.row else { return }
            switch index {
            case 0:
                AppLanguage.manager.current = .zh
            case 1:
                AppLanguage.manager.current = .en
            default:
                break
            }
            AppManager.default.rootIn(configs: {
                if let tabbarVC = AppManager.default.rootViewController?.rootViewController as? TabBarController {
                    tabbarVC.tab = .settings
                    tabbarVC.navigationController?.pushViewController(LanguageViewController(), animated: true)
                }
            })
        }
    }
    
    

}
