//
//  CreateWalletViewModel.swift


import UIKit

class CreateWalletViewModel: NSObject {

    // MARK: - Properties (Public)
    
    lazy var pwdSecureTextEntryState = { Observable<Bool>(true) }()
    lazy var agreementState = { Observable<Bool>(false) }()
    lazy var nextState = { Observable<Bool>(false) }()
    
    lazy var nameTextState = { Observable<String>("") }()
    
    lazy var nameErrorState = { Observable<String?>(nil) }()
    lazy var pwdErrorState = { Observable<String?>(nil) }()
    lazy var pwdConfirmErrorState = { Observable<String?>(nil) }()
    
    lazy var pwdRankState = { Observable<Int>(0) }()
    
    lazy var pushState = { Postable<UIViewController?>() }()
    
    
    
    // MARK: - Properties (Private)
    
    private let style: CreateWalletStyle
    private var data = NewWallet()
    
    
    private var pwdConfirmText = ""
    
    private var isNameVaild: Bool { get { return !data.name.isEmpty && !FileManager.default.fileExists(atPath: data.name.filePaths.document) } }
    private var isPwdFormatVaild: Bool { get { return data.pwd.count >= 8 } }
    private var isPwdConfirmVaild: Bool { get { return data.pwd == pwdConfirmText } }
    
    
    // MARK: - Life Cycles
    
    init(style: CreateWalletStyle) {
        self.style = style
        super.init()
    }
    
    
    // MARK: - Methods (Public)
    
    func navigationTitle() -> String {
        switch style {
        case .new:
            return LocalizedString(key: "wallet.add.create", comment: "")
        case .recovery:
            return LocalizedString(key: "wallet.add.import", comment: "")
        }
    }
    
    func nameFieldInput(_ text: String) {
        var charCount = 0
        let nsStr = NSString.init(string: text)
        for i in 0..<text.count {
            if nsStr.character(at: i) >= 0x40EE {
                charCount += 2
            } else {
                charCount += 1
            }
        }
        let vaild = charCount <= 20
        if vaild {
            self.data.name = text
        } else {
            self.nameTextState.value = self.data.name
        }
        self.nameErrorState.value = nil
        self.nextState.value = isVaildNext()
    }
    
    func pwdFieldInput(_ text: String) {
        self.calculatePwdStrength(text)
        self.data.pwd = text
        self.pwdErrorState.value = nil
        self.nextState.value = isVaildNext()
    }
    
    func pwdConfirmFieldInput(_ text: String) {
        self.pwdConfirmText = text
        self.pwdConfirmErrorState.value = nil
        self.nextState.value = isVaildNext()
    }
    
    func pwdTipsFieldInput(_ text: String) {
        self.data.pwdTips = text
    }
    
    func pwdSecureTextEntryClick() {
        pwdSecureTextEntryState.value = !pwdSecureTextEntryState.value
    }
    
    func agreementClick() {
        agreementState.value = !agreementState.value
        self.nextState.value = isVaildNext()
    }
    
    func toServiceBook() -> UIViewController {
        let web = WebViewController.init(WooKeyURL.serviceBook.url)
        return web
    }
    
    func nextClick() {
        // 钱包名称
        guard isNameVaild else {
            nameErrorState.value = LocalizedString(key: "wallet_invalid", comment: "")
            return
        }
        
        // 密码格式
        guard isPwdConfirmVaild else {
            pwdConfirmErrorState.value = LocalizedString(key: "confirm_password_invalid", comment: "")
            return
        }
        guard isPwdFormatVaild else {
            pwdErrorState.value = LocalizedString(key: "password_invalid", comment: "")
            pwdConfirmErrorState.value = ""
            return
        }
        
        switch style {
        case .new:
            HUD.showHUD()
            WalletService.shared.createWallet(with: .new(data: data)) { (result) in
                switch result {
                case .success(let wallet):
                    if let db_wallets = DBService.shared.getWallets(Wallet.Properties.name.is(self.data.name), orderBy: nil) {
                        db_wallets.forEach({
                            WalletDefaults.shared.proceedWalletID = $0.id
                        })
                    }
                    let seed = wallet.seed
                    wallet.close()
                    DispatchQueue.main.async {
                        HUD.hideHUD()
                        self.pushState.newState(SeedViewController(seed: seed))
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        HUD.hideHUD()
                        HUD.showError("创建失败")
                    }
                }
            }
        case .recovery:
            let viewModel = ImportWalletViewModel(data: data)
            let vc = ImportWalletViewController(viewModel: viewModel)
            pushState.newState(vc)
        }
    }
    
    
    
    // MARK: - Methods (Private)
    
    private func calculatePwdStrength(_ pwd: String) {
        var value = 0
        if (pwd.count < 8) {
            value = 0
        } else {
            value = 25
            var upper = 0
            var lower = 0
            var number = 0
            var other = 0
            pwd.forEach { char in
                if char.isUpperCase() {
                    upper += 1
                } else if char.isLowerCase() {
                    lower += 1
                } else if char.isNumberCase() {
                    number += 1
                } else {
                    other += 1
                }
            }
            if (upper == pwd.count || lower == pwd.count) {
                value += 10
            }
            if (upper > 0 || lower > 0) {
                value += 30
            }
            if (number == 1) {
                value += 10
            }
            if (number >= 3) {
                value += 20
            }
            if (other == 1) {
                value += 10
            }
            if (other >= 2) {
                value += 25
            }
            if (number > 0 && (upper > 0 || lower > 0) && other == 0) {
                value += 2
            }
            if (other > 0 && (upper > 0 || lower > 0) && number == 0) {
                value += 2
            }
            if (number > 0 && other > 0) {
                value += upper > 0 && lower > 0 ? 5 : 3
            }
        }
        pwdRankState.value = { () -> Int in
            if value >= 90 {
                return 4
            } else if value >= 70 {
                return 3
            } else if value >= 47 {
                return 2
            } else if value >= 25 {
                return 1
            } else {
                return 0
            }
        }()
    }
    
    private func isVaildNext() -> Bool {
        return !data.name.isEmpty && !data.pwd.isEmpty && !pwdConfirmText.isEmpty && agreementState.value
    }
    
}
