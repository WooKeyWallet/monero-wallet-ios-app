//
//  AssetsTokenViewModel.swift


import UIKit

class AssetsTokenViewModel: NSObject {

    // MARK: - Properties (Lazy)
    
    lazy var pushState = { Postable<UIViewController>() }()
    
    lazy var conncetingState = { return Observable<Bool>(false) }()
    
    lazy var progressState = { return Observable<CGFloat>(0) }()
    
    lazy var statusTextState = { return Observable<String>("") }()
    
    lazy var balanceState = { return Observable<String>(asset.remain) }()
    
    lazy var historyState = { return Postable<[[TableViewSection]]>() }()
    
    
    lazy var sendState = { return Observable<Bool>(false) }()
    lazy var reciveState = { return Observable<Bool>(false) }()
    lazy var refreshState = { return Observable<Bool>(false) }()
    
    private lazy var taskQueue = DispatchQueue(label: "monero.wallet.task")
    
    
    // MARK: - Properties (Private)
    
    private let pwd: String
    private let asset: Assets
    private let token: TokenWallet
    private var wallet: XMRWallet?
    
    private var connecting: Bool { return conncetingState.value }
    private var listening = false
    private var needSynchronized = false {
        didSet {
            guard needSynchronized, !oldValue,
                let wallet = self.wallet else { return }
            wallet.saveOnTerminate()
        }
    }
    private var currentBlockChainHeight: UInt64 = 0
    private var daemonBlockChainHeight: UInt64 = 0
    
    private var isSyncingUI = false {
        didSet {
            guard oldValue != isSyncingUI else { return }
            if isSyncingUI {
                RunLoop.main.add(timer, forMode: .common)
            } else {
                timer.invalidate()
            }
        }
    }
        
    private lazy var timer: Timer = {
        Timer.init(timeInterval: 0.5, repeats: true) { [weak self] (_) in
            guard let `self` = self else { return }
            self.updateSyncingProgress()
        }
    }()
    
    
    // MARK: - Life Cycle
    
    init(asset: Assets, pwd: String) {
        self.pwd = pwd
        self.asset = asset
        self.token = asset.wallet ?? TokenWallet()
        super.init()
    }
    
    func configure() {
        init_wallet()
    }
    
    private func init_wallet() {
        sendState.value = false
        reciveState.value = false
        conncetingState.value = true
        statusTextState.value = LocalizedString(key: "assets.connect.ing", comment: "")
        WalletService.shared.openWallet(token.label, password: pwd) { [weak self] (result) in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                switch result {
                case .success(let wallet):
                    strongSelf.wallet = wallet
                    strongSelf.connect(wallet: wallet)
                case .failure(_):
                    strongSelf.refreshState.value = true
                    strongSelf.conncetingState.value = false
                    strongSelf.statusTextState.value = LocalizedString(key: "assets.connect.failure", comment: "")
                }
            }
        }
        loadHistoryFromDB()
    }
    
    private func connect(wallet: XMRWallet) {
        self.reciveState.value = true
        if !connecting {
            self.conncetingState.value = true
            self.statusTextState.value = LocalizedString(key: "assets.connect.ing", comment: "")
        }
        wallet.connectToDaemon(address: WalletDefaults.shared.node, delegate: self) { [weak self] (isConnected) in
            guard let `self` = self else { return }
            if isConnected {
                if let wallet = self.wallet {
                    if let restoreHeight = self.token.restoreHeight {
                        wallet.restoreHeight = restoreHeight
                    }
                    wallet.start()
                }
                self.listening = true
            } else {
                DispatchQueue.main.async {
                    self.statusTextState.value = LocalizedString(key: "assets.connect.failure", comment: "")
                    self.conncetingState.value = false
                    self.refreshState.value = true
                    self.listening = false
                }
            }
        }
    }
    
    private func closeWallet() {
        guard let wallet = self.wallet else {
            return
        }
        self.wallet = nil
        if listening {
            listening = false
            wallet.pasue()
        }
        wallet.close()
    }
    
    deinit {
        dPrint("\(#function) ================================= \(self.classForCoder)")
        isSyncingUI = false
        closeWallet()
    }
    
    
    // MARK: - Methods (private)
    
    private func synchronizedUI() {
        progressState.value = 1
        sendState.value = true
        statusTextState.value = LocalizedString(key: "assets.sync.success", comment: "")
    }
    
    private func loadHistoryFromDB() {
        DispatchQueue.global().async {
            guard
                let all = DBService.shared.getTransactionList(condition: _Transaction_.Properties.walletId.is(self.token.id))
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
    
    private func storeToDB(balance: String, history: TransactionHistory) {
        let (wallet_id, asset_id) = (self.token.id, self.asset.id)
        /// 余额 & 恢复高度
        var properties = [Wallet.Properties.balance]
        let updateWallet = Wallet.init()
        updateWallet.balance = balance
        if let blockChainHeight = self.wallet?.blockChainHeight,
            let restoreHeight = self.token.restoreHeight,
            restoreHeight < blockChainHeight {
            updateWallet.restoreHeight = blockChainHeight
            properties.append(Wallet.Properties.restoreHeight)
        }
        _ = DBService.shared.updateWallet(on: properties, with: updateWallet, condition: Wallet.Properties.id.is(wallet_id))
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
    
    private func postData(balance: String, history: TransactionHistory) {
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
    
    
    // MARK: - Methods (action)
    
    func refresh() {
        refreshState.value = false
        if let wallet = self.wallet {
            if listening {
                wallet.pasue()
                wallet.start()
            } else {
                connect(wallet: wallet)
            }
        } else {
            init_wallet()
        }
    }
    
    func toSwitchNode() {
        let model = TokenNodeModel.init(tokenImage: UIImage(named: "token_icon_XMR"),
                                        tokenName: "XMR",
                                        tokenNode: WalletDefaults.shared.node)
        let viewModel = TokenNodeListViewModel.init(tokenNode: model) {
        [unowned self] _ in
            self.closeWallet()
            self.init_wallet()
            AppManager.default.rootViewController?.popViewController(animated: true)
        }
        let viewController = TokenNodeListController(viewModel: viewModel)
        pushState.newState(viewController)
    }
    
    func toSend() {
        guard let wallet = self.wallet else { return }
        let vc = SendViewController(asset: asset, wallet: wallet)
        pushState.newState(vc)
    }
    
    func toReceive() {
        guard let wallet = self.wallet else { return }
        let vc = ReceiveViewController(token: token, wallet: wallet)
        pushState.newState(vc)
    }
    
    func pushToTransaction(_ model: Transaction) {
        let vc = TransactionDetailController.init(transaction: model)
        pushState.newState(vc)
    }
    
}

extension AssetsTokenViewModel: MoneroWalletDelegate {
    
    func moneroWalletRefreshed(_ wallet: MoneroWalletWrapper) {
        dPrint("moneroWalletRefreshed -> \(wallet.blockChainHeight), \(wallet.daemonBlockChainHeight)")
        self.isSyncingUI = false
        if self.needSynchronized {
            self.needSynchronized = !wallet.save()
        }
        taskQueue.async {
            guard let wallet = self.wallet else { return }
            let (balance, history) = (wallet.balance, wallet.history)
            self.storeToDB(balance: balance, history: history)
            self.postData(balance: balance, history: history)
        }
        if daemonBlockChainHeight != 0 {
            /// 计算节点区块高度是否与钱包刷新回调的一致，不一致则表示并非同步完成
            let difference = wallet.daemonBlockChainHeight.subtractingReportingOverflow(daemonBlockChainHeight)
            guard !difference.overflow else { return }
        }
        DispatchQueue.main.async {
            if self.conncetingState.value {
                self.conncetingState.value = false
            }
            self.synchronizedUI()
        }
    }
    
    func moneroWalletNewBlock(_ wallet: MoneroWalletWrapper, currentHeight: UInt64) {
        dPrint("newBlock --------------------------------------------> \(currentHeight)---\(wallet.daemonBlockChainHeight)")
        self.currentBlockChainHeight = currentHeight
        self.daemonBlockChainHeight = wallet.daemonBlockChainHeight
        self.needSynchronized = true
        self.isSyncingUI = true
    }
    
    private func updateSyncingProgress() {
        taskQueue.async {
            let (current, total) = (self.currentBlockChainHeight, self.daemonBlockChainHeight)
            guard total != current else { return }
            let difference = total.subtractingReportingOverflow(current)
            var progress = CGFloat(current) / CGFloat(total)
            let leftBlocks: String
            if difference.overflow || difference.partialValue <= 1 {
                leftBlocks = "1"
                progress = 1
            } else {
                leftBlocks = String(difference.partialValue)
            }
            
            let statusText = LocalizedString(key: "assets.sync.progress.preffix", comment: "") + leftBlocks
            DispatchQueue.main.async {
                if self.conncetingState.value {
                    self.conncetingState.value = false
                }
                self.progressState.update(progress)
                self.statusTextState.update(statusText)
            }
        }
    }
    
}
