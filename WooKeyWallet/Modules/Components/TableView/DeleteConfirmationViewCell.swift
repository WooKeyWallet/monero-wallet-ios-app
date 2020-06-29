//
//  DeleteConfirmationViewCell.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/5/12.
//  Copyright © 2020 Wookey. All rights reserved.
//

import UIKit
import SwipeCellKit

class DeleteConfirmationViewCell: SwipeTableViewCell, TableViewCellProtocol {
        
    private(set) var actionHandler: ((Any) -> Void)?
    
    private var isConfirmStatus = false
        
    // MARK: - Properties (Override)
    
    override var frame: CGRect {
        get { return super.frame }
        set {
            super.frame = newValue
            self.frameLayout()
        }
    }
    
    
    // MARK: - Properties (Lazy)
    
    internal lazy var iconView: UIImageView = {
        let imgV = UIImageView()
        imgV.contentMode = .scaleAspectFit
        imgV.isUserInteractionEnabled = true
        return imgV
    }()
    
    internal lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.font = AppTheme.Font.text_normal.medium()
        return label
    }()
    
    internal lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_light
        label.font = AppTheme.Font.text_small
        label.textAlignment = .right
        return label
    }()
    
    internal lazy var rightArrow: UIImageView = {
        let imgV = UIImageView.init(image: UIImage(named: "cell_arrow_right"))
        return imgV
    }()
    
    
    // MARK: - Life Cycles
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initCell()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initCell()
    }
    
    func initCell() {
        delegate = self
        selectionStyle = .none
        self.backgroundColor = AppTheme.Color.cell_bg
        contentView.backgroundColor = AppTheme.Color.cell_bg
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - TableViewRowable
    
    func configure(with row: TableViewRow) {
        self.actionHandler = row.actionHandler
    }
    
    // MARK: - Layout

    func frameLayout() {
        
    }

}

extension DeleteConfirmationViewCell: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let delete = SwipeAction(style: .default, title: LocalizedString(key: isConfirmStatus ? "deleteConfirm" : "delete", comment: "")) { [unowned self] (action, indexPath) in
            if self.isConfirmStatus {
                self.actionHandler?(TableViewRowAction.delete(indexPath: indexPath))
            } else {
                action.fulfill(with: .reset)
                self.isConfirmStatus = true
                self.showSwipe(orientation: .right)
            }
        }
        delete.textColor = .white
        delete.backgroundColor = .red
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive(automaticallyDelete: false, timing: .with)
        options.buttonPadding = 20
        return options
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?, for orientation: SwipeActionsOrientation) {
        self.isConfirmStatus = false
    }
    
    
}
