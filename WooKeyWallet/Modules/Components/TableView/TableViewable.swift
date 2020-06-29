//
//  TableViewable.swift


import UIKit

protocol TableViewCellProtocol where Self: UITableViewCell {
    func configure(with row: TableViewRow)
}

enum TableViewRowAction {
    case delete(indexPath: IndexPath)
    case edit
    case custom(sender: Any)
}

struct TableViewSection {
    var rows = [TableViewRow]()
    var headerHeight: CGFloat = 0
    var footerHeight: CGFloat = 0
    var headerTitle: String?
    var footerTitle: String?
    var estimatedHeaderHeight: CGFloat = 0
    var estimatedFooterHeight: CGFloat = 0
    
    init(_ rows: [TableViewRow]) {
        self.rows = rows
    }
    
    init() {
        
    }
}

struct TableViewRow {
    
    var rowHeight: CGFloat
    var estimatedHeight: CGFloat
    var cellType: TableViewCellProtocol.Type = BaseTableViewCell.self
    var indexPath: IndexPath?
    var tableViewWidth: CGFloat
    var selectionStyle: UITableViewCell.SelectionStyle?
    var model: Any?
    
    var didSelectedAction: ((Int) -> Void)?
    var actionHandler: ((Any) -> Void)?
    
    init(_ model: Any? = nil, cellType: TableViewCellProtocol.Type = BaseTableViewCell.self, rowHeight: CGFloat = 50) {
        self.model = model
        self.rowHeight = rowHeight
        self.estimatedHeight = 0
        self.cellType = cellType
        self.tableViewWidth = UIScreen.main.bounds.size.width
    }
    
    func serializeModel<T>() -> T? {
        return model as? T
    }
    
}

