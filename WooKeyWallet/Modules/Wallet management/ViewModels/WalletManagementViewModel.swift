//
//  WalletManagementViewModel.swift


import UIKit

class WalletManagementViewModel: NSObject {
    
    // MARK: - Properties (Lazy)
    

    // MARK: - Life Cycles
    
    override init() {
        super.init()
        
    }
    
    // MARK: - Methods (Public)
    
    public func updateActive(_ walletId: Int) {
        guard WalletService.shared.updateActiveWallet(walletId) else {
            HUD.showError(LocalizedString(key: "change_active_failure", comment: ""))
            return
        }
        WalletService.shared.walletActiveState.value = walletId
        AppManager.default.rootViewController?.popViewController(animated: true)
    }
}
