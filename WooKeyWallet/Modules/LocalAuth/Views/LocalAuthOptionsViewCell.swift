//
//  LocalAuthOptionsViewCell.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/5/18.
//  Copyright © 2020 Wookey. All rights reserved.
//

import UIKit

class LocalAuthOptionsViewCell: BaseTableViewCell {
    
    // MARK: - Properties (private)
    
    private var actionHandler: ((Any) -> Void)?
    
    
    // MARK: - Properties (private lazy)
    
    private lazy var openWalletGifView: LocalAuthGifView = {
        let gifURL = Bundle.wookey?.url(forResource: "auth_open", withExtension: "gif", subdirectory: "gifs")
        let gif = LocalAuthGifView(image: UIImage(named: "localAuth_openWallet"), gif: gifURL)
        gif.contentMode = .scaleAspectFit
        gif.text = LocalizedString(key: "auth.options.openWallet", comment: "")
        return gif
    }()
    private lazy var sendXMRGifView: LocalAuthGifView = {
        let gifURL = Bundle.wookey?.url(forResource: "auth_send", withExtension: "gif", subdirectory: "gifs")
        let gif = LocalAuthGifView(image: UIImage(named: "localAuth_sendXMR"), gif: gifURL)
        gif.contentMode = .scaleAspectFit
        gif.text = LocalizedString(key: "auth.options.sendXMR", comment: "")
        return gif
    }()
    private lazy var exportKeysGifView: LocalAuthGifView = {
        let gifURL = Bundle.wookey?.url(forResource: "auth_export", withExtension: "gif", subdirectory: "gifs")
        let gif = LocalAuthGifView(image: UIImage(named: "localAuth_exportKeys"), gif: gifURL)
        gif.contentMode = .scaleAspectFit
        gif.text = LocalizedString(key: "auth.options.exportKeys", comment: "")
        return gif
    }()
    
    
    // MARK: - Life Cycles

    override func initCell() {
        super.initCell()
        nameLabel.text = LocalizedString(key: "auth.options.title", comment: "")
        nameLabel.textColor = AppTheme.Color.text_dark
        nameLabel.font = AppTheme.Font.text_normal
        contentView.addSubview(nameLabel)
        let optionViewList = [
            openWalletGifView,
            sendXMRGifView,
            exportKeysGifView,
        ]
        contentView.addSubViews(optionViewList)
        optionViewList.forEach({ $0.addTapGestureRecognizer(target: self, selector: #selector(optionsTapAction(_:))) })
    }
    
    override func configure(with row: TableViewRow) {
        self.actionHandler = row.actionHandler
        guard let options: [LocalAuthOptions] = row.serializeModel() else { return }
        openWalletGifView.isSelected = options.contains(.openWallet)
        sendXMRGifView.isSelected = options.contains(.sendXMR)
        exportKeysGifView.isSelected = options.contains(.exportKeys)
    }
    
    override func frameLayout() {
        let nameSize = nameLabel.sizeThatFits(.zero)
        nameLabel.updateFrame(CGRect(origin: CGPoint(x: (width - nameSize.width) * 0.5, y: 25), size: nameSize))
        openWalletGifView.updateFrame(CGRect(x: width * 0.5 - 160, y: nameLabel.maxY + 20, width: 100, height: 240))
        sendXMRGifView.updateFrame(CGRect(x: openWalletGifView.maxX + 10, y: openWalletGifView.y, width: openWalletGifView.width, height: openWalletGifView.height))
        exportKeysGifView.updateFrame(CGRect(x: sendXMRGifView.maxX + 10, y: sendXMRGifView.y, width: sendXMRGifView.width, height: sendXMRGifView.height))
    }
    
    
    // MARK: - Methods (action)
    
    @objc private func optionsTapAction(_ sender: UITapGestureRecognizer) {
        guard let optionsView = sender.view as? LocalAuthGifView else { return }
        optionsView.isSelected = !optionsView.isSelected
        var options = [LocalAuthOptions]()
        if openWalletGifView.isSelected {
            options.append(.openWallet)
        }
        if sendXMRGifView.isSelected {
            options.append(.sendXMR)
        }
        if exportKeysGifView.isSelected {
            options.append(.exportKeys)
        }
        self.actionHandler?(options)
    }
}
