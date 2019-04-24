//
//  AppManager.swift


import UIKit
import IQKeyboardManagerSwift
import SnapKit
import SafariServices
import Schedule



// MARK: - AppManage

@objc
class AppManager: NSObject {
    
    public typealias NewRootHandler = () -> UIViewController
    
    // MARK: - Properties (Static)
    
    public static let `default` = { return AppManager() }()
    
    
    // MARK: - Properties (Public)
    
    var rootViewController: NavigationController? {
        get { return UIApplication.shared.keyWindow?.rootViewController as? NavigationController }
    }
    
    
    // MARK: - Properties (Private)
    
    private var pasteboardLifeTask: Task?
    
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    
    
    // MARK: - Properties (Closure)
    
    private var createNewRootHandler: NewRootHandler?
    
    
    
    // MARK: - Methods (Public)
    
    public func configure(createNewRoot: NewRootHandler?) {
        self.createNewRootHandler = createNewRoot
    }
    
    public func configureIQKeyboard() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarTintColor = AppTheme.Color.main_green
        #if DEBUG
        IQKeyboardManager.shared.enableDebugging = true
        #elseif DEBUG_LOC
        IQKeyboardManager.shared.enableDebugging = true
        #else
        IQKeyboardManager.shared.enableDebugging = false
        #endif
        
    }
    
    /**
     *  进入根控制器
     **/
    public func rootIn(configs: (() -> ())? = nil) {
        UIApplication.shared.keyWindow?.rootViewController = createNewRootHandler?()
        configs?()
    }
    
    /**
     *  re tootIn
     **/
    public func reRootIn() {
        
    }

    
    /**
     *  go to Safari
     **/
    public func openSafari(with url: String) {
        guard
            let _URL = URL(string: url),
            UIApplication.shared.canOpenURL(_URL)
        else {
            return
        }
        UIApplication.shared.openURL(_URL)
    }
    
    /**
     *  go to SafariViewController
     **/
    public func openSafariViewController(with url: String) {
        guard let _URL = URL(string: url) else { return }
        let safariViewController = SFSafariViewController.init(url: _URL)
        if #available(iOS 11.0, *) {
            safariViewController.dismissButtonStyle = .close
        }
        self.rootViewController?.present(safariViewController, animated: true, completion: nil)
    }
    
    public func beginBackgroundTask() {
        endBackgroundTask()
        /// get 3 min
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask { [unowned self] in
            self.endBackgroundTask()
        }
        dPrint(#function)
    }
    
    public func endBackgroundTask() {
        if let id = backgroundTaskIdentifier {
            dPrint(#function)
            self.backgroundTaskIdentifier = nil
            UIApplication.shared.endBackgroundTask(id)
        }
    }
    
    
    public func beginPasteboardLifeTime() {
//        guard let str = UIPasteboard.general.string,
//            str != ""
//            else {
//                return
//        }
//        if let task = pasteboardLifeTask {
//            task.cancel()
//            pasteboardLifeTask = nil
//        }
//        pasteboardLifeTask = Plan.after(35.second).do {
//            dPrint("[PasteboardLifeTimeEnd =============================== ]")
//            DispatchQueue.main.async {
//                UIPasteboard.general.string = ""
//            }
//        }
    }
    
}


