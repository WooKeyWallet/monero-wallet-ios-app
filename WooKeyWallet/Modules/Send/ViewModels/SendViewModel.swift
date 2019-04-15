//
//  SendViewModel.swift


import UIKit

class SendViewModel: NSObject {
    
    // MARK: - Properties (Public)
    
    public var navigationTitle: String {
        return token.token + " " + LocalizedString(key: "send.title.suffix", comment: "")
    }
    
    public var walletName: String {
        return token.label
    }
    

    // MARK: - Properties (Private)
    
    private let asset: Assets
    private let token: TokenWallet
    private let wallet: WalletProtocol
    
    
    private var address: String = ""
    private var amount: String = ""
    private var paymentId: String = ""
    
    private var sendValid: Bool {
        return address.count > 0 && amount.count > 0
    }
    
    private var isAllin: Bool = false
    
    
    // MARK: - Properties (Lazy)
    
    lazy var sendState = { return Observable<Bool>(false) }()
    
    lazy var addressState = { return Observable<String>("") }()
    lazy var amountState = { return Observable<String>("") }()
    lazy var paymentIdState = { return Observable<String>("") }()
    lazy var paymentIdLenState = { return Observable<String>("0/16") }()
    
    
    // MARK: - Life Cycle
    
    init(asset: Assets, wallet: WalletProtocol) {
        self.asset = asset
        self.token = asset.wallet ?? TokenWallet()
        self.wallet = wallet
        super.init()
    }
    
    func configureHeader(_ header: SendViewHeader) {
        header.configureModels(model: (token.icon, walletName, "\(Helper.displayDigitsAmount(wallet.balance)) \(token.token)"))
    }
    
    func configureConfirm(_ view: SendConfirmView) {
        let model = SendDetail.init(tokenIcon: token.icon,
                                    amount: Helper.displayDigitsAmount(amount),
                                    fee: Helper.displayDigitsAmount(wallet.getTransactionFee() ?? "--"),
                                    token: token.token,
                                    address: address,
                                    paymentId: paymentId)
        view.configureModel(model: model)
    }
    
    deinit {
        wallet.disposeTransaction()
    }
    
    
    /// Actions
    
    func allin() {
        if Double(wallet.balance) ?? 0 > 0 {
            amount = wallet.balance
            amountState.value = wallet.balance
            isAllin = true
            self.sendState.value = sendValid
        }
    }
    
    func toSelectAddress() -> UIViewController {
        let vc = AddressBooksController.init()
        vc.didSelected = {
            [unowned self] address in
            self.inputAddress(address)
            self.addressState.value = address
        }
        return vc
    }
    
    func generatePaymentId() {
        let id = wallet.generatePaymentId()
        paymentIdState.value = id
        inputPaymentId(id)
    }
    
    
    /// Inputs
    
    func inputAddress(_ text: String) {
        self.address = text
        self.sendState.value = sendValid
    }
    
    func inputAmount(_ text: String) {
        guard let balance = Double(wallet.balance), balance > 0 else {
            amountState.value = ""
            amount = ""
            sendState.value = sendValid
            return
        }
        let value = Double(text) ?? 0
        if value > balance {
            self.amount = wallet.balance
            self.amountState.value = wallet.balance
            self.isAllin = true
        } else if value == balance {
            self.amount = wallet.balance
            self.isAllin = true
        } else {
            self.isAllin = false
            self.amount = text
        }
        self.sendState.value = sendValid
    }
    
    func inputPaymentId(_ text: String) {
        var _text = text
        if _text.count > 64 {
            _text = String(text.prefix(64))
            self.paymentIdState.value = _text
        }
        self.paymentId = _text
        let text_count = _text.count
        if text_count > 16 {
            self.paymentIdLenState.value = "\(text_count)/64"
        } else {
            self.paymentIdLenState.value = "\(text_count)/16"
        }
    }
    
    func toScan() -> UIViewController {
        let vc = QRCodeScanViewController()
        vc.resultHandler = {
            [unowned self] (results, scanViewController) in
            if results.count > 0 {
                self.address = results.first?.strScanned ?? ""
                self.addressState.value = self.address
            } else {
                HUD.showError(LocalizedString(key: "not_recognized", comment: ""))
            }
            scanViewController.navigationController?.popViewController(animated: true)
        }
        return vc
    }
    
    
    /// Transactions
    
    func createTransaction(_ finish: (() -> Void)?) {
        guard wallet.validAddress(address) else {
            HUD.showError(LocalizedString(key: "address.validate.fail", comment: ""))
            return
        }
        HUD.showHUD()
        DispatchQueue.global().async {
            let success: Bool
            if self.isAllin {
                success = self.wallet.createSweepTransaction(self.address, paymentId: self.paymentId)
            } else {
                success = self.wallet.createPendingTransaction(self.address, paymentId: self.paymentId, amount: self.amount)
            }
            DispatchQueue.main.async {
                HUD.hideHUD()
                guard success else {
                    var errMsg = self.wallet.commitPendingTransactionError()
                    if errMsg.count == 0 {
                        errMsg = LocalizedString(key: "send.create.failure", comment: "")
                    }
                    HUD.showError(errMsg)
                    return
                }
                finish?()
            }
        }
    }
    
    func toConfirm() -> UIViewController {
        return SendConfirmViewController(viewModel: self)
    }
    
    func commitTransaction() {
        HUD.showHUD()
        DispatchQueue.global().async {
            let success = self.wallet.commitPendingTransaction()
            DispatchQueue.main.async {
                HUD.hideHUD()
                if success {
                    HUD.showSuccess(LocalizedString(key: "send.success", comment: ""))
                    AppManager.default.rootViewController?.popTo(2)
                } else {
                    HUD.showError(self.wallet.commitPendingTransactionError())
                }
            }
        }
    }
}
