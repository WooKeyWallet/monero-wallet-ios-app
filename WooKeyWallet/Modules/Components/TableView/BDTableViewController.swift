//
//  BDTableViewController.swift


import UIKit

class BDTableViewController: BaseTableViewController {
    
    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Base Deleagte (BD)
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = dataSource[indexPath.section].rows[indexPath.row]
        return row.rowHeight
    }
}

