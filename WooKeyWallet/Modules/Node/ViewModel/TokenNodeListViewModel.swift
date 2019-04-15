//
//  TokenNodeListViewModel.swift


import UIKit
import Alamofire

class TokenNodeListViewModel: NSObject {
    
    // MARK: - Properties (Observable)
    
    public lazy var dataSourceOb = { Observable<[TableViewSection]>([]) }()
    public lazy var reloadIndexPathState = { Postable<TableViewRow>() }()
    
    
    // MARK: - Properties (Private)
    
    private let tokenNode: TokenNodeModel
    private var nodeList = [NodeOption]() {
        didSet {
            postDataSource()
        }
    }
    private var selectedIndex: Int?
    
    private var fpsCaches = [String: Int]()
    
    private lazy var fpsQueue = { DispatchQueue.init(label: "node.fps.flow") }()
    
    private lazy var defaultNodes = {
        [
            NodeDefaults.Monero.default,
            NodeDefaults.Monero.default0,
            NodeDefaults.Monero.default1,
        ]
    }()
    
    // MARK: - Life Cycles
    
    required init(tokenNode: TokenNodeModel) {
        self.tokenNode = tokenNode
        super.init()
    }
    
    // MARK: - Properties (Private)
    
    private func postDataSource() {
        DispatchQueue.global().async {
            let sections = [TableViewSection.init(self.nodeList.map({
                var model = $0
                model.fps = self.fpsCaches[$0.node]
                self.pingNode($0.node)
                return TableViewRow.init(model, cellType: TokenNodeListCell.self, rowHeight: 62)
            }))]
            DispatchQueue.main.async {
                self.dataSourceOb.value = sections
            }
        }
    }
    
    private func pingNode(_ url: String) {
        DispatchQueue.global().async {
            /// ping the node
            self.verifyNodeURI(url, callBack: { (fps) in
                self.fpsCaches[url] = fps
                self.fpsQueue.async {
                    for i in 0..<self.nodeList.count {
                        var node = self.nodeList[i]
                        if node.node == url {
                            node.fps = fps
                            var block_row = TableViewRow.init(node, cellType: TokenNodeListCell.self, rowHeight: 62)
                            block_row.indexPath = IndexPath(row: i, section: 0)
                            DispatchQueue.main.async {
                                self.reloadIndexPathState.newState(block_row)
                            }
                            break
                        }
                    }
                }
            })
        }
    }
    
    private func verifyNodeURI(_ host_port: String, callBack: ((Int?) -> Void)?) {
        let url = "http://" + host_port + "/json_rpc"
        let param = ["jsonrpc": "2.0", "id": "0", "method": "getlastblockheader"]
        let dataTask = SessionManager.default.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
        dataTask.responseJSON { (response: DataResponse<Any>) in
            let statusCode = response.response?.statusCode ?? 404
            let contentLen = response.data?.count ?? 0
            var resultVaild = false
            if statusCode == 200 && contentLen < 1000 {
                let json = response.value as? [String: Any] ?? [:]
                let result = json["result"] as? [String: Any] ?? [:]
                let header = result["block_header"] as? [String: Any] ?? [:]
                let timestamp = header["timestamp"] as? CLong
                if timestamp != nil {
                    resultVaild = true
                }
            }
            if resultVaild {
                callBack?(Int(response.timeline.requestDuration * 1000))
            } else {
                callBack?(nil)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            dataTask.cancel()
        }
    }
    
    
    // MARK: - Methods (Public)
    
    public func loadData() {
        DispatchQueue.global().async {
            self.selectedIndex = self.defaultNodes.index(of: WalletDefaults.shared.node) ?? 0
            var _nodeList: [NodeOption] = self.defaultNodes.map({
                let isSelected = $0 == WalletDefaults.shared.node
                return NodeOption(node: $0, fps: nil, isSelected: isSelected)
            })
            if let node_list = DBService.shared.getNodeList(), node_list.count > 0 {
                stride(from: 0, to: node_list.count, by: 1).forEach { (i) in
                    let node = node_list[i]
                    if node.isSelected {
                        _nodeList[0].isSelected = false
                        self.selectedIndex = i + self.defaultNodes.count
                    }
                    _nodeList.append(NodeOption.init(node: node.url, fps: nil, isSelected: node.isSelected))
                }
            }
            DispatchQueue.main.async {
                self.nodeList = _nodeList
            }
        }
    }
    
    public func getNavigationTitle() -> String {
        return tokenNode.tokenName + LocalizedString(key: "settings.node.suffix", comment: "")
    }
    
    public func didSelect(_ indexPath: IndexPath) {
        guard indexPath.row != selectedIndex else {
            return
        }
        var nodeList = self.nodeList
        nodeList[indexPath.row].isSelected = true
        if let index = selectedIndex {
            nodeList[index].isSelected = false
            if index >= defaultNodes.count {
                let node = Node()
                node.isSelected = false
                _ = DBService.shared.update(on: [Node.Properties.isSelected], with: node, condition: Node.Properties.url.is(nodeList[index].node))
            }
        }
        selectedIndex = indexPath.row
        self.nodeList = nodeList
        
        WalletDefaults.shared.node = nodeList[indexPath.row].node
        if selectedIndex! >= defaultNodes.count {
            let node = Node()
            node.isSelected = true
            _ = DBService.shared.update(on: [Node.Properties.isSelected], with: node, condition: Node.Properties.url.is(WalletDefaults.shared.node))
        }
    }
    
    public func toAddNodeViewController() -> UIViewController {
        let vc = AddNodeForTokenController.init(viewModel: self)
        vc.modalPresentationStyle = .overCurrentContext
        return vc
    }
    
    public func addNode(_ str: String, result: ((Bool) -> Void)?) {
        guard let result = result else { return }
        guard !nodeList.map({ $0.node }).contains(str) else {
            result(false)
            return
        }
        HUD.showHUD()
        DispatchQueue.global().async {
            self.verifyNodeURI(str, callBack: { (time) in
                DispatchQueue.main.async {
                    HUD.hideHUD()
                    guard time != nil else {
                        result(false)
                        HUD.showError(LocalizedString(key: "node.verify.error", comment: ""))
                        return
                    }
                    let node = Node()
                    node.url = str
                    node.symbol = self.tokenNode.tokenName
                    guard DBService.shared.insertNode(node) else {
                        result(false)
                        HUD.showError(LocalizedString(key: "node.add.failure", comment: ""))
                        return
                    }
                    self.fpsCaches[str] = time
                    self.nodeList.append(NodeOption.init(node: str, fps: time, isSelected: false))
                    result(true)
                }
            })
        }
    }
    
    public func deleteNode(_ indexPath: IndexPath) {
        var _nodeList = self.nodeList
        let deleteNode = _nodeList.remove(at: indexPath.row)
        AppManager.default.rootViewController?.showAlert(LocalizedString(key: "node.delete.alert.title", comment: ""),
                       message: LocalizedString(key: "node.delete.alert.msg", comment: "").replacingOccurrences(of: "$0", with: deleteNode.node),
                       cancelTitle: "cancel",
                       doneTitle: "confirm",
                       doneClousre: {
                        [unowned self] in
                        if deleteNode.isSelected {
                            WalletDefaults.shared.node = NodeDefaults.Monero.default
                        }
                        _ = DBService.shared.deleteNode(deleteNode.node)
                        self.nodeList = _nodeList
                        self.loadData()
        })
    }
    
    public func editActionsForRow(at indexPath: IndexPath) -> [UITableViewRowAction] {
        guard indexPath.row >= defaultNodes.count else {
            return []
        }
        return [
            UITableViewRowAction.init(style: .destructive, title: LocalizedString(key: "delete", comment: ""), handler: { [unowned self] (_, indexPath) in
                self.deleteNode(indexPath)
            })
        ]
    }
    
}
