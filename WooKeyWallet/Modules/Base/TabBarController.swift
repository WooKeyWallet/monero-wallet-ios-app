//
//  TabBarController.swift


import UIKit

class TabBarController: UITabBarController {

    enum Tab: Int {
        case assets
        case settings
        
        var title: String {
            get {
                switch self {
                case .assets:
                    return LocalizedString(key: "assets", comment: "资产")
                case .settings:
                    return LocalizedString(key: "settings", comment: "设置")
                }
            }
        }
    }
    
    // MARK: - Properties (Public)
    
    public var tab: Tab? {
        didSet {
            if let tab = tab {
                self.selectedIndex = tab.rawValue
                if let previousTab = oldValue {
                    self.previousTab = previousTab
                }
                if let vc = selectedViewController {
                    didSelect(vc)
                }
            }
        }
    }
    
    public var hideNavigationBar: Bool {
        guard let selectedViewController = self.selectedViewController as? BaseViewController else { return false }
        return selectedViewController.hideNavigationBar
    }
    
    // MARK: - Properties (Private)
    
    private var previousTab: Tab = .assets
    
    // MARK: - Properties (Lazy)
    
    private lazy var tabs: [Tab] = {
        return [
            .assets,
            .settings,
        ]
    }()
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Self
        do {
            self.view.backgroundColor = UIColor.white
            self.delegate = self
        }
        
        /// TabBar
        do {
            self.tabBar.layer.shadowColor = AppTheme.Color.tabBarShadow.cgColor
            self.tabBar.layer.shadowOffset = CGSize(width: 0, height: -3)
            self.tabBar.layer.shadowRadius = 3
            self.tabBar.layer.shadowOpacity = 0.3
            self.tabBar.backgroundColor = AppTheme.Color.tabBar
            self.tabBar.tintColor = AppTheme.Color.tabBar_tintColor
            if #available(iOS 13, *) {
                let standardAppearance = self.tabBar.standardAppearance
                standardAppearance.backgroundImage = UIImage.colorImage(.clear)
                standardAppearance.shadowImage = UIImage.colorImage(.clear)
                standardAppearance.backgroundEffect = nil
                self.tabBar.standardAppearance = standardAppearance
            } else {
                self.tabBar.backgroundImage = UIImage()
                self.tabBar.shadowImage = UIImage()
            }
        }
        
        /// Tabs
        self.setupTabs()
    }
    
    private func setupTabs() {
        /// tabs -> viewControllers
        self.viewControllers = self.tabs.map({
            _tab in
            let viewController: UIViewController
            let tabBarItem = UITabBarItem.init(title: _tab.title, image: nil, selectedImage: nil)
            tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -5)
            switch _tab {
            case .assets:
                viewController = AssetsViewController()
                tabBarItem.image = UIImage(named: "tabBarItem_assets_normal")?.withRenderingMode(.alwaysOriginal)
                tabBarItem.selectedImage = UIImage(named: "tabBarItem_assets_selected")?.withRenderingMode(.alwaysOriginal)
            case .settings:
                viewController = SettingsViewController()
                tabBarItem.image = UIImage(named: "tabBarItem_settings_normal")?.withRenderingMode(.alwaysOriginal)
                tabBarItem.selectedImage = UIImage(named: "tabBarItem_settings_selected")?.withRenderingMode(.alwaysOriginal)
            }
            viewController.tabBarItem = tabBarItem
            return viewController
        })
        
        if let firstVC = viewControllers?.first {
            tabBarController(self, didSelect: firstVC)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(hideNavigationBar, animated: animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {

    }
    
    
    // MARK: - didSelect viewController
    
    private func didSelect(_ viewController: UIViewController) {
        /// 将子控制器的导航内容传递给tabbar，只针对keyWindow.root是navigationController时
        if let titleView = viewController.navigationItem.titleView {
            navigationItem.titleView = titleView
        } else {
            navigationItem.titleView = nil
            navigationItem.title = viewController.navigationItem.title
        }
        if let leftBarButtonItems = viewController.navigationItem.leftBarButtonItems {
            navigationItem.leftBarButtonItems = leftBarButtonItems
        } else {
            navigationItem.leftBarButtonItems = nil
            navigationItem.leftBarButtonItem = viewController.navigationItem.leftBarButtonItem
        }
        if let rightBarButtonItems = viewController.navigationItem.rightBarButtonItems {
            navigationItem.rightBarButtonItems = rightBarButtonItems
        } else {
            navigationItem.rightBarButtonItems = nil
            navigationItem.rightBarButtonItem = viewController.navigationItem.rightBarButtonItem
        }
    }
    
    
    
}

// MARK: - UITabBarControllerDelegate

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard
            let selectedIndex = viewControllers?.index(of: viewController),
            let tab = Tab(rawValue: selectedIndex)
            else {
                return false
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        didSelect(viewController)
    }
}
