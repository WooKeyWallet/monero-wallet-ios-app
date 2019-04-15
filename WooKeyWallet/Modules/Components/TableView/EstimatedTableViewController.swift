//
//  EstimatedTableViewController.swift


import UIKit

class EstimatedTableViewController: BaseTableViewController {
    
    // MARK: - Properties (Public)
    
    public var estimatedHeight: CGFloat = 50
    
    
    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = estimatedHeight
    }
    

    // MARK: - Estimated
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource[indexPath.section].rows[indexPath.row].estimatedHeight
    }

}
