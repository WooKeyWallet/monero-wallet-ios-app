//
//  BaseViewController.swift


import UIKit

class BaseViewController: UIViewController {

    typealias Paramtter = [AnyHashable: Any]
    
    
    // MARK: - Properties (Public)
    
    public var hideNavigationBar: Bool { return false }
    
    public var navigationBarColorStyle: NavigationController.BarColorStyle { return .default }
    
    public var observerPool = [NSObjectProtocol]()
    
    public var interactivePopGestureEnable: Bool { return true }
    
    
    // MARK: - Properties (Private)
    
    
    
    
    // MARK: - Properties (Closure)
    
    public var nextAction: ((Paramtter) -> Void)?
    
    
    // MARK: - Life cycles
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// UI
        configureUI()
        
        /// Binds
        configureBinds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(hideNavigationBar, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        observerPool.forEach({ NotificationCenter.default.removeObserver($0) })
    }
    
    // MARK: - Methods (Action)
    
    @objc func dismissAction() {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Methods (Public)
    
    
    // MARK: - Methods (Internal)
    
    internal func configureUI() {
        self.view.backgroundColor = AppTheme.Color.page_common
    }
    
    internal func configureBinds() {
        
    }
    
    
    // MARK: - Methods (Private)
    
    
}
