//
//  AppDelegate.swift
//  Wookey

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties (Public)

    var window: UIWindow?
    
    
    // MARK: - Properties (Private)
    
    private var visualEffectView: UIVisualEffectView?


    // MARK: - Life Cycles
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Thread.sleep(forTimeInterval: 1)
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        AppManager.default.configure { () -> UIViewController in
            if WalletService.shared.hasProceedWallet {
                return NavigationController(rootViewController: ProceedCreateViewController(walletId: WalletDefaults.shared.proceedWalletID!))
            }
            if WalletService.shared.hasWallets {
                return NavigationController(rootViewController: TabBarController())
            }
            return NavigationController(rootViewController: AddWalletViewController())
        }
        AppManager.default.rootIn {
            /// configure on threading
            do // main
            {
                AppManager.default.configureIQKeyboard()
                HUD.setupAppearence()
            }
            
            // global
            DispatchQueue.global().async {
                DBService.shared.setup()
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        addBlurForWindow()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        AppManager.default.beginBackgroundTask()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        removeBlurForWindow()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        removeBlurForWindow()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }


}


extension AppDelegate {
    
    // MARK: - Methods (Private)
    
    private func addBlurForWindow() {
        let blur: UIBlurEffect
        blur = UIBlurEffect(style: .light)
        let visualView = UIVisualEffectView(effect: blur)
        visualView.frame = self.window?.bounds ?? .zero
        self.window?.addSubview(visualView)
        self.visualEffectView = visualView
    }
    
    private func removeBlurForWindow() {
        guard let visualEffectView = self.visualEffectView else { return }
        visualEffectView.removeFromSuperview()
        self.visualEffectView = nil
    }
}

