//
//  Transaction.swift


import UIKit

struct Transaction {
    
    enum Status: Int {
        case success
        case failure
        case proccessing
    }
    
    var type: TransactionsType = .all
    var amount: String = ""
    var status: Status = .success
    var token: String = ""
    var date: String = ""
    var fee: String = ""
    var paymentId: String = ""
    var hash: String = ""
    var block: String = ""
}

struct TransactionListCellFrame {
    let icon: UIImage?
    let nameText: String
    let detailText: String
    let dateText: String
    let statusText: String
    let statusTextColor: UIColor
    
    init(model: Transaction) {
        
        let amount_modify = Helper.displayDigitsAmount(model.amount)
        
        switch model.type {
        case .all:
            icon = nil
            nameText = ""
            detailText = amount_modify + " " + model.token
        case .in:
            icon = UIImage(named: "transactions_receive")
            nameText = LocalizedString(key: "receive", comment: "")
            detailText = "+\(amount_modify) \(model.token)"
        case .out:
            icon = UIImage(named: "transactions_send")
            nameText = LocalizedString(key: "send", comment: "")
            detailText = "-\(amount_modify) \(model.token)"
        }
        
        dateText = model.date
        switch model.status {
        case .success:
            statusText = LocalizedString(key: "success", comment: "")
            statusTextColor = AppTheme.Color.main_green
        case .failure:
            statusText = LocalizedString(key: "failure", comment: "")
            statusTextColor = AppTheme.Color.status_red
        case .proccessing:
            statusText = LocalizedString(key: "proccessing", comment: "")
            statusTextColor = AppTheme.Color.status_blue
        }
    }
    
    static func toTableViewRow(_ model: Transaction) -> TableViewRow {
        return TableViewRow.init(self.init(model: model), cellType: TransactionListCell.self, rowHeight: 62)
    }
}
