//
//  TokenWalletDeleteCell.swift
//  Wookey
//
//  Created by jowsing on 2019/4/24.
//  Copyright © 2019 Wookey. All rights reserved.
//

import UIKit

class TokenWalletDeleteCell: BaseTableViewCell {

    override func initCell() {
        super.initCell()
        
        nameLabel.text = LocalizedString(key: "deleteWallet", comment: "")
        nameLabel.textColor = AppTheme.Color.text_dark
        nameLabel.font = AppTheme.Font.text_normal
        nameLabel.textAlignment = .center
        nameLabel.isUserInteractionEnabled = true
        
        addSubViews([
            nameLabel,
        ])
    }
    
    override func frameLayout() {
        nameLabel.updateFrame(bounds)
    }

}
