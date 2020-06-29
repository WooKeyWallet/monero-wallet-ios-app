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
    
    private let data: NewWallet
    
    private var recovery_seed = RecoverWallet(from: .seed)
    private var recovery_keys = RecoverWallet(from: .keys)
    
    // MARK: - Life Cycles
    
    init(data: NewWallet) {
        self.data = data
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
        self.alertWarningIfNeed(recovery_seed)
    }
    
    public func recoveryFromKeys() {
        self.alertWarningIfNeed(recovery_keys)
    }
    
    
    // MARK: - Methods (Private)
    
    private func alertWarningIfNeed(_ recover: RecoverWallet) {
        guard recover.date == nil &&
            recover.block == nil
        else {
            self.createWallet(recover)
            return
        }
        
        let alert = UIAlertController(title: LocalizedString(key: "wallet.import.blockTips.msg", comment: ""),
                                      message: "",
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: LocalizedString(key: "wallet.import.blockTips.cancel", comment: ""), style: .cancel, handler: nil)
        
        let confirmAction = UIAlertAction(title: LocalizedString(key: "wallet.import.blockTips.confirm", comment: ""), style: .destructive) {
        [unowned self] (_) in
            self.createWallet(recover)
        }
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        showAlertState.newState(alert)
    }
    
    private func createWallet(_ recover: RecoverWallet) {
        HUD.showHUD()
        WalletService.shared.createWallet(with: .recovery(data: data, recover: recover)) { (result) in
            DispatchQueue.main.async {
                HUD.hideHUD()
                switch result {
                case .success(let wallet):
                    wallet.close()
                    do // 刷新 UI
                    {
                        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController,
                            navigationController.viewControllers.first is UITabBarController,
                            navigationController.viewControllers.count > 2,
                            let managementVC = navigationController.viewControllers[1] as? WalletManagementViewController
                        {
                            managementVC.loadData()
                            navigationController.popToViewController(managementVC, animated: true)
                        } else {
                            AppManager.default.rootIn()
                        }
                    }
                case .failure(_):
                    HUD.showError("导入失败")
                }
            }
        }
    }
}
