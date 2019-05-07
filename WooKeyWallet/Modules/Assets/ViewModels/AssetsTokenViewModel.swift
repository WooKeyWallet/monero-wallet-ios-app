//
//  AssetsTokenViewModel.swift


import UIKit

class AssetsTokenViewModel: NSObject {

    // MARK: - Properties (Lazy)
    
    lazy var conncetingState = { return Observable<Bool>(false) }()
    
    lazy var progressState = { return Observable<CGFloat>(0) }()
    
    lazy var statusTextState = { return Observable<String>("") }()
    
    lazy var balanceState = { return Observable<String>(asset.remain) }()
    
    lazy var historyState = { return Postable<[[TableViewSection]]>() }()
    
    
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
        closeWallet()
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
        loadHistoryFromDB()
    }
    
    private func loadHistoryFromDB() {
        DispatchQueue.global().async {
            guard
                let all = DBService.shared.getTransactionList(condition: _Transaction_.Properties.walletId.is(self._wallet.id))
            else {
                return
            }
            /// 数据转换
            let itemMapToRow = { (item: Transaction) -> TableViewRow in
                var row = TransactionListCellFrame.toTableViewRow(item)
                row.didSelectedAction = {
                    [unowned self] _ in
                    self.pushToTransaction(item)
                }
                return row
            }
            let allData = [TableViewSection(all.map(itemMapToRow))]
            let receiveData = [TableViewSection(all.filter({ $0.type == .in }).map(itemMapToRow))]
            let sendData = [TableViewSection(all.filter({ $0.type == .out }).map(itemMapToRow))]
            DispatchQueue.main.async {
                self.historyState.newState([allData, receiveData, sendData])
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
        DispatchQueue.global(qos: .userInteractive).async {
        [weak self] in
            guard let strongSelf = self else { return }
            let success = strongSelf.wallet.connectToDaemon(address: WalletDefaults.shared.node, upperTransactionSizeLimit: 0, daemonUsername: "", daemonPassword: "")
            if success {
                WalletService.shared.safeOperation({
                    guard let strongSelf = self else { return }
                    strongSelf.listen()
                })
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
                strongSelf.needSynchronized = false
            }
            DispatchQueue.main.async {
                if strongSelf.conncetingState.value {
                    strongSelf.conncetingState.value = false
                }
                strongSelf.synchronizedUI()
            }
            DispatchQueue.global(qos: .userInteractive).async {
                guard let strongSelf = weakSelf else { return }
                let (balance, history) = (strongSelf.wallet.balance, strongSelf.wallet.history)
                strongSelf.storeToDB(balance: balance, history: history)
                strongSelf.postData(balance: balance, history: history)
            }
        }) { (current, total) in
            guard let strongSelf = weakSelf else { return }
            dPrint("newBlock --------------------------------------------> \(current)---\(total)")
            let currenTime = CFAbsoluteTimeGetCurrent()
            let difference = total.subtractingReportingOverflow(current)
            strongSelf.needSynchronized = difference.overflow || difference.partialValue < 1000
            guard currenTime - startListeningTime >= 1 else {
                startListeningTime = currenTime
                return
            }
            startListeningTime = currenTime
            var progress = CGFloat(current)/CGFloat(total)
            let leftBlocks: String
            if difference.overflow || difference.partialValue <= 1 {
                leftBlocks = "1"
                progress = 1
            } else {
                leftBlocks = String(difference.partialValue)
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
    
    private func storeToDB(balance: String, history: TransactionHistory) {
        let (wallet_id, asset_id) = (self._wallet.id, self.asset.id)
        DispatchQueue.global().async {
            /// 余额
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
            /// 交易历史
            guard
                DBService.shared.removeAllTransactions(condition: _Transaction_.Properties.walletId.is(wallet_id))
            else {
                return
            }
            _=DBService.shared.insertTransactions(list: history.all.map({ Transaction.init(item: $0) }),
                                                walletId: wallet_id)
        }
    }
    
    private func postData(balance: String, history: TransactionHistory) {
        DispatchQueue.global().async {
        [weak self] in
            guard let `self` = self else { return }
            
            let balance_modify = Helper.displayDigitsAmount(balance)
            
            /// 数据转换
            let itemMapToRow = { (item: TransactionItem) -> TableViewRow in
                let model = Transaction.init(item: item)
                var row = TransactionListCellFrame.toTableViewRow(model)
                row.didSelectedAction = {
                    [unowned self] _ in
                    self.pushToTransaction(model)
                }
                return row
            }
            
            let allData = [TableViewSection(history.all.map(itemMapToRow))]
            let receiveData = [TableViewSection(history.receive.map(itemMapToRow))]
            let sendData = [TableViewSection(history.send.map(itemMapToRow))]

            DispatchQueue.main.async {
                self.balanceState.value = balance_modify
                self.historyState.newState([allData, receiveData, sendData])
            }
        }
    }
    
    func toSwitchNode() -> UIViewController {
        let model = TokenNodeModel.init(tokenImage: UIImage(named: "token_icon_XMR"),
                                        tokenName: "XMR",
                                        tokenNode: WalletDefaults.shared.node)
        let viewModel = TokenNodeListViewModel.init(tokenNode: model) {
        [unowned self] _ in
            self.init_wallet()
            AppManager.default.rootViewController?.popViewController(animated: true)
        }
        let viewController = TokenNodeListController.init(viewModel: viewModel)
        return viewController
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
    
    private func closeWallet() {
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
    
    deinit {
        dPrint("\(#function) ================================= \(self.classForCoder)")
        closeWallet()
    }
    
    
    
}
