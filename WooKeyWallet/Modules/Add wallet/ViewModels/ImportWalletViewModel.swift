//
//  ImportWalletViewModel.swift


import UIKit


class ImportWalletViewModel: NSObject {
    
    // MARK: - Properties (Public)
    
    lazy var fromKeysNextState = { Observable<Bool>(false) }()
    lazy var fromSeedNextState = { Observable<Bool>(false) }()
    
    lazy var fromSeedDateState = { Observable<Date?>(nil) }()
    lazy var fromKeysDateState = { Observable<Date?>(nil) }()
    
    lazy var showDatePickerState = { Postable<ZZDatePicker>() }()
    lazy var showAlertState = { Postable<UIAlertController>() }()
    
    // MARK: - Properties (Private)
    
    private let create: WalletCreate
    
    private var recovery_seed = WalletRecovery(from: .seed)
    private var recovery_keys = WalletRecovery(from: .keys)
    
    // MARK: - Life Cycles
    
    init(create: WalletCreate) {
        self.create = create
        super.init()
    }

    
    // MARK: - Methods (Public)
    
    public func seedInput(text: String) {
        recovery_seed.seed = text
        fromSeedNextState.value = recovery_seed.validateNext()
    }
    
    public func viewKeysInput(text: String) {
        recovery_keys.viewKey = text
        fromKeysNextState.value = recovery_keys.validateNext()
    }
    
    public func spendKeysInput(text: String) {
        recovery_keys.spendKey = text
        fromKeysNextState.value = recovery_keys.validateNext()
    }
    
    public func addressInput(text: String) {
        recovery_keys.address = text
        fromKeysNextState.value = recovery_keys.validateNext()
    }
    
    public func fromSeedBlockNumInput(text: String) {
        recovery_seed.block = text
    }
    
    public func fromKeysBlockNumInput(text: String) {
        recovery_keys.block = text
    }
    
    public func fromSeedRecentDate() {
        var dateMode = ZZDatePicker.Mode()
        dateMode.minimumDate = Date.init(timeIntervalSince1970: 1398873600)
        let picker = ZZDatePicker.init(mode: dateMode)
        picker.pickDone = { [unowned self] date in
            self.fromSeedDateState.value = date
            self.recovery_seed.date = date
        }
        showDatePickerState.newState(picker)
    }
    
    public func fromKeysRecentDate() {
        var dateMode = ZZDatePicker.Mode()
        dateMode.minimumDate = Date.init(timeIntervalSince1970: 1398873600)
        let picker = ZZDatePicker.init(mode: dateMode)
        picker.pickDone = { [unowned self] date in
            self.fromKeysDateState.value = date
            self.recovery_keys.date = date
        }
        showDatePickerState.newState(picker)
    }
    
    public func recoveryFromSeed() {
        var create = self.create
        create.recovery = self.recovery_seed
        self.alertWarningIfNeed(create)
    }
    
    public func recoveryFromKeys() {
        var create = self.create
        create.recovery = self.recovery_keys
        self.alertWarningIfNeed(create)
    }
    
    // MARK: - Methods (Private)
    
    private func alertWarningIfNeed(_ create: WalletCreate) {
        guard create.recovery?.date == nil &&
            create.recovery?.block == nil
        else {
            self.createWallet(create)
            return
        }
        
        let alert = UIAlertController(title: LocalizedString(key: "wallet.import.blockTips.msg", comment: ""),
                                      message: "",
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: LocalizedString(key: "wallet.import.blockTips.cancel", comment: ""), style: .cancel, handler: nil)
        
        let confirmAction = UIAlertAction(title: LocalizedString(key: "wallet.import.blockTips.confirm", comment: ""), style: .destructive) {
        [unowned self] (_) in
            self.createWallet(create)
        }
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        showAlertState.newState(alert)
    }
    
    private func createWallet(_ create: WalletCreate) {
        HUD.showHUD()
        WalletService.shared.safeOperation {
            do {
                let _ = try WalletService.shared.createWallet(create)
                WalletService.shared.createFinish()
                DispatchQueue.main.async {
                    HUD.hideHUD()
                    if
                        let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController,
                        let _ = navigationController.viewControllers.first as? UITabBarController
                    {
                        guard let managementVC = navigationController.viewControllers[1] as? WalletManagementViewController else { return }
                        managementVC.loadData()
                        navigationController.popToViewController(managementVC, animated: true)
                    } else {
                        AppManager.default.rootIn()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    HUD.hideHUD()
                    HUD.showError("导入失败")
                }
            }
        }
    }
}
