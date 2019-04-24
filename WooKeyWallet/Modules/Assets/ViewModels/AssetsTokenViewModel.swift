//
//  AssetsTokenViewModel.swift


import UIKit

class AssetsTokenViewModel: NSObject {

    // MARK: - Properties (Lazy)
    
    lazy var conncetingState = { return Observable<Bool>(false) }()
    
    lazy var progressState = { return Observable<CGFloat>(0) }()
    
    lazy var statusTextState = { return Observable<String>("") }()
    
    lazy var balanceState = { return Observable<String>(asset.remain) }()
    
    lazy var historyState = { return Observable<[[TableViewSection]]?>(nil) }()
    
    
    lazy var sendState = { return Observable<Bool>(false) }()
    lazy var reciveState = { return Observable<Bool>(false) }()
    lazy var refreshState = { return Observable<Bool>(false) }()
    
    
    // MARK: - Properties (Private)
    
    private let pwd: String
    
    private let asset: Assets
    
    private let _wallet: TokenWallet
    
    private var wallet: WalletProtocol!
    
    private var init_success = false
    private var listening = false
    private var needSynchronized = true
    private var isStoreSynced: Bool?
    
    // MARK: - Life Cycle
    
    init(asset: Assets, pwd: String) {
        self.asset = asset
        self.pwd = pwd
        self._wallet = asset.wallet ?? TokenWallet()
        super.init()
    }
    
    func init_wallet() {
        conncetingState.value = true
        statusTextState.value = LocalizedString(key: "assets.connect.ing", comment: "")
        WalletService.shared.safeOperation { [weak self] in
            guard let strongSelf = self else { return }
            do {
                strongSelf.wallet = try WalletService.shared.loginWallet(strongSelf._wallet.label, password: strongSelf.pwd)
                strongSelf.init_success = true
                strongSelf.connect()
            } catch {
                DispatchQueue.main.async {
                    strongSelf.refreshState.value = true
                    strongSelf.conncetingState.value = false
                    strongSelf.statusTextState.value = LocalizedString(key: "assets.connect.failure", comment: "")
                }
            }
        }
    }
    
    private func connect() {
        DispatchQueue.main.async {
            self.reciveState.value = true
            if !self.conncetingState.value {
                self.conncetingState.value = true
                self.statusTextState.value = LocalizedString(key: "assets.connect.ing", comment: "")
            }
        }
        WalletService.shared.safeOperation {
        [weak self] in
            guard let strongSelf = self else { return }
            let success = strongSelf.wallet.connectToDaemon(address: WalletDefaults.shared.node, upperTransactionSizeLimit: 0, daemonUsername: "", daemonPassword: "")
            if success {
                strongSelf.listen()
            } else {
                DispatchQueue.main.async {
                    guard let strongSelf = self else { return }
                    strongSelf.statusTextState.value = LocalizedString(key: "assets.connect.failure", comment: "")
                    strongSelf.conncetingState.value = false
                    strongSelf.refreshState.value = true
                }
            }
        }
    }
    
    private func listen() {
        weak var weakSelf = self
        var startListeningTime = CFAbsoluteTimeGetCurrent()
        let syncingPreffix = LocalizedString(key: "assets.sync.progress.preffix", comment: "")
        wallet.setListener(listenerHandler: {
            guard let strongSelf = weakSelf, strongSelf.wallet.synchronized else { return }
            dPrint("refreshed -----------------------------------> \(monero_getBlockchainHeight())---\(monero_getDaemonBlockChainHeight())")
            if strongSelf.needSynchronized {
                WalletService.shared.safeOperation({
                    guard let strongSelf = weakSelf else { return }
                    strongSelf.isStoreSynced = strongSelf.wallet.storeSycnhronized()
                })
            }
            strongSelf.storeToDB()
            strongSelf.needSynchronized = false
            DispatchQueue.main.async {
                if strongSelf.conncetingState.value {
                    strongSelf.conncetingState.value = false
                }
                strongSelf.synchronizedUI()
            }
            strongSelf.postData()
        }) { (current, total) in
            guard let strongSelf = weakSelf else { return }
            dPrint("newBlock --------------------------------------------> \(current)---\(total)")
            let currenTime = CFAbsoluteTimeGetCurrent()
            let leftHeight = total - current
            strongSelf.needSynchronized = leftHeight < 1000
            guard currenTime - startListeningTime >= 1 else {
                startListeningTime = currenTime
                return
            }
            startListeningTime = currenTime
            var progress = CGFloat(current)/CGFloat(total)
            let leftBlocks: String
            if leftHeight <= 1 {
                leftBlocks = "1"
                progress = 1
            } else {
                leftBlocks = String(leftHeight)
            }
            DispatchQueue.main.async {
                if strongSelf.conncetingState.value {
                    strongSelf.conncetingState.value = false
                }
                strongSelf.progressState.value = progress
                strongSelf.statusTextState.value = syncingPreffix + leftBlocks
            }
        }
        self.listening = true
        self.sycn()
    }
    
    private func sycn() {
        if let restoreHeight = _wallet.restoreHeight {
            wallet.restoreHeight = restoreHeight
        }
        wallet.refresh()
    }
    
    func refresh() {
        refreshState.value = false
        if listening {
            WalletService.shared.safeOperation {
                self.sycn()
            }
        } else if init_success {
            connect()
        } else {
            init_wallet()
        }
    }
    
    private func synchronizedUI() {
        progressState.value = 1
        sendState.value = true
        statusTextState.value = LocalizedString(key: "assets.sync.success", comment: "")
    }
    
    private func storeToDB() {
        let (balance, wallet_id, asset_id) = (self.wallet.balance, self._wallet.id, self.asset.id)
        DispatchQueue.global().async {
            /// 写入数据库
            let updateWallet = Wallet.init()
            updateWallet.balance = balance
            _ = DBService.shared.updateWallet(on: [Wallet.Properties.balance], with: updateWallet, condition: Wallet.Properties.id.is(wallet_id))
            let asset_update = Asset()
            asset_update.balance = balance
            if DBService.shared.update(on: [Asset.Properties.balance], with: asset_update, condition: Asset.Properties.id.is(asset_id)) {
                DispatchQueue.main.async {
                    WalletService.shared.assetRefreshState.value = 1
                }
            }
        }
    }
    
    private func postData() {
        DispatchQueue.global().async {
        [weak self] in
            guard let `self` = self else { return }
            let balance = self.wallet.balance
            /// 数据转换
            var allData = [TableViewSection()]
            var inData = [TableViewSection()]
            var outData = [TableViewSection()]
            
            for model in self.wallet.history.all {
                var trans = Transaction()
                trans.amount = model.amount
                trans.token = self._wallet.token
                trans.date = Date.init(timeIntervalSince1970: Double(model.timestamp)).toString("yyyy-MM-dd HH:mm:ss")
                trans.fee = model.networkFee
                trans.paymentId = model.paymentId
                trans.hash = model.hash
                trans.block = String(model.blockHeight)
                if model.isFailed {
                    trans.status = .failure
                } else if model.isPending {
                    trans.status = .proccessing
                } else {
                    trans.status = .success
                }
                var row: TableViewRow
                switch model.direction {
                case .received:
                    trans.type = .in
                    row = TransactionListCellFrame.toTableViewRow(trans)
                    row.didSelectedAction = {
                        [unowned self] _ in
                        self.pushToTransaction(trans)
                    }
                    inData[0].rows.append(row)
                case .sent:
                    trans.type = .out
                    row = TransactionListCellFrame.toTableViewRow(trans)
                    row.didSelectedAction = {
                        [unowned self] _ in
                        self.pushToTransaction(trans)
                    }
                    outData[0].rows.append(row)
                }
                allData[0].rows.append(row)
            }
            if allData[0].rows.count == 0 {
                allData = []
            }
            if inData[0].rows.count == 0 {
                inData = []
            }
            if outData[0].rows.count == 0 {
                outData = []
            }
            
            let balance_modify = Helper.displayDigitsAmount(balance)

            DispatchQueue.main.async {
                self.balanceState.value = balance_modify
                self.historyState.value = [allData, inData, outData]
                self.historyState.value = nil
            }
        }
    }
    
    func toSend() -> UIViewController {
        let vc = SendViewController.init(asset: asset, wallet: wallet)
        return vc
    }
    
    func toReceive() -> UIViewController {
        let vc = ReceiveViewController.init(token: _wallet, wallet: wallet)
        return vc
    }
    
    private func pushToTransaction(_ model: Transaction) {
        let vc = TransactionDetailController.init(transaction: model)
        AppManager.default.rootViewController?.pushViewController(vc, animated: true)
    }
    
    deinit {
        dPrint("\(#function) ================================= \(self.classForCoder)")
        guard let wallet = self.wallet else { return }
        let isRefreshing = self.listening
        let isStoreSynced = self.isStoreSynced
        WalletService.shared.safeOperation {
            if isRefreshing {
                wallet.pasueRefresh()
            }
            if let _ = isStoreSynced {
                if wallet.storeSycnhronized() {
                    wallet.lock()
                }
            } else {
                wallet.lock()
            }
        }
    }
    
    
    
}
