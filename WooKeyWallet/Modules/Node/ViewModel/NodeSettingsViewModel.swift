//
//  NodeSettingsViewModel.swift


import UIKit

class NodeSettingsViewModel: NSObject {
    
    private var tokenNodeList = [TokenNodeModel]()
    
    public func getDataSource() -> [TableViewSection] {
        tokenNodeList = [
            TokenNodeModel.init(tokenImage: UIImage(named: "token_icon_XMR"), tokenName: "XMR", tokenNode: WalletDefaults.shared.node)
        ]
        return [
            TableViewSection.init(tokenNodeList.map({
                return TableViewRow.init($0, cellType: NodeSettingsViewCell.self, rowHeight: 62)
            }))
        ]
    }
    
    public func getNextViewController(_ indexPath: IndexPath) -> UIViewController {
        let viewModel = TokenNodeListViewModel.init(tokenNode: tokenNodeList[indexPath.row])
        let vc = TokenNodeListController.init(viewModel: viewModel)
        return vc
    }
}
