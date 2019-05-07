//
//  NavigationController.swift


import UIKit

class NavigationController: UINavigationController {

    public enum BarColorStyle: Int {
        case clear
        case `default`
    }
    
    // MARK: - Properties (Public)
    
    public var isModal: Bool = false
    
    public var rootViewController: UIViewController? { return viewControllers.first }
    
    private(set) var barColorStyle: BarColorStyle = .default
    
    /**
     当我们调用setNeedsStatusBarAppearanceUpdate时，
     系统会调用application.window的rootViewController的preferredStatusBarStyle方法，
     我们的程序里一般都是用UINavigationController做root，
     如果是这种情况，那我们自己的UIViewController里的preferredStatusBarStyle根本不会被调用；
     所以通过该方法指定可以更改的控制器
     */
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    
    // MARK: - Properties (Lazy)
    
    lazy var statusBarBackground: UIView = {
        let statusBarBackground = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBarBackground.y = -statusBarBackground.height
        return statusBarBackground
    }()
    
    
    // MARK: - Life Cycles
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let self_viewDidLoad = {
            [weak self] () -> Void in
            guard let strongSelf = self else { return }
            strongSelf.view.backgroundColor = UIColor.white
            strongSelf.navigationBar.tintColor = AppTheme.Color.navigation_tintColor
            strongSelf.navigationBar.backgroundColor = UIColor.clear
            strongSelf.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : AppTheme.Color.navigationTitle,
                NSAttributedString.Key.font : AppTheme.Font.navigationTitle,
            ]
            strongSelf.navigationBar.isTranslucent = true
            strongSelf.interactivePopGestureRecognizer?.delegate = strongSelf
            strongSelf.delegate = strongSelf
            strongSelf.hideBottomLine()
        }
        self_viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if animated {
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
        if self.children.count > 0 {
            let barButtonItem = UIBarButtonItem.init(image: UIImage(named: "navigation_back_icon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.popAction))
            
            viewController.navigationItem.leftBarButtonItem = barButtonItem
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    // MARK: - Actions
    
    @objc private func popAction() {
        self.popViewController(animated: true)
    }
    
    @objc private func dismissAction() {
        
    }
    
    // MARK: - Methods (Public)
    
    
    // MARK: - Methods (Private)
    
    private func hideBottomLine() {
        if #available(iOS 11.0, *) {
            navigationBar.shadowImage = UIImage()
        } else {
            let bottomLine = navigationBar.findView({ $0.height <= 1 })
            bottomLine?.isHidden = true
        }
    }
    
}

extension NavigationController: UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if animated {
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
        return super.popToRootViewController(animated: animated)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if animated {
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
        return super.popToViewController(viewController, animated: animated)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let VC = viewController as? BaseViewController {
            self.interactivePopGestureRecognizer?.isEnabled = VC.interactivePopGestureEnable
        } else {
            self.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.interactivePopGestureRecognizer {
            if viewControllers.count < 2 || visibleViewController == viewControllers.first {
                return false
            }
        }
        return true
    }
}
