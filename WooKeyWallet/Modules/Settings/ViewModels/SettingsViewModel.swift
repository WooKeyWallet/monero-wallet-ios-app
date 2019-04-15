//
//  SettingsViewModel.swift


import UIKit

class SettingsViewModel: NSObject {
    
    // MARK: - Properties
    
    private lazy var itemGroup: [[SettingsItemType]] = {
        return [
            [.wallet, .token,],
            [.node, .lang,],
            [.help, .about,],
        ]
    }()
    
    
    // MARK: - Methods (Private)
    
    private func getItemFor(_ type: SettingsItemType) -> SettingsItem {
        switch type {
        case .wallet:
            return SettingsItem.init(icon: UIImage(named: "settings.wallet"), name: LocalizedString(key: "settings.wallet", comment: ""), text: "")
        case .pin:
            return SettingsItem.init(icon: UIImage(named: "settings.pin"), name: LocalizedString(key: "settings.pin", comment: ""), text: "")
        case .token:
            return SettingsItem.init(icon: UIImage(named: "settings.token"), name: LocalizedString(key: "settings.token", comment: ""), text: "")
        case .node:
            return SettingsItem.init(icon: UIImage(named: "settings.node"), name: LocalizedString(key: "settings.node", comment: ""), text: "")
        case .lang:
            let text: String
            switch AppLanguage.manager.current {
            case .en:
                text = "English"
            case .zh:
                text = "简体中文"
            }
            return SettingsItem.init(icon: UIImage(named: "settings.lang"), name: LocalizedString(key: "settings.lang", comment: ""), text: text)
        case .help:
            return SettingsItem.init(icon: UIImage(named: "settings.help"), name: LocalizedString(key: "settings.help", comment: ""), text: "")
        case .about:
            return SettingsItem.init(icon: UIImage(named: "settings.about"), name: LocalizedString(key: "settings.about", comment: ""), text: AppInfo.appVersion)
        }
    }
    
    
    // MARK: - Methods (Public)
    
    public func getDataSource() -> [TableViewSection] {
        return itemGroup.map({
            var sec = TableViewSection.init($0.map({
                return TableViewRow.init(getItemFor($0), cellType: SettingsViewCell.self, rowHeight: 60)
            }))
            sec.footerHeight = 20
            sec.headerHeight = 0.1
            return sec
        })
    }
    
    public func getNextViewController(_ indexPath: IndexPath) -> UIViewController {
        switch itemGroup[indexPath.section][indexPath.row] {
        case .node:
            return NodeSettingsViewController()
        case .token:
            return AddressBooksController()
        case .wallet:
            return WalletManagementViewController()
        case .lang:
            return LanguageViewController()
        case .about:
            return AboutViewController()
        case .help:
            return ContactUsViewController()
        default:
            return BaseViewController()
        }
    }
}
