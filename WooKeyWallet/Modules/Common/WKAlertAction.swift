//
//  WKAlertAction.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/5/8.
//  Copyright © 2020 Wookey. All rights reserved.
//

import UIKit

class WKAlertAction: NSObject {
    
    public let title: String?
    public let style: Style
    private let handler: ((WKAlertAction) -> Void)?

    public init(title: String?, style: Style, handler: ((WKAlertAction) -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
        super.init()
    }
    
    public func performAction() {
        self.handler?(self)
    }
}

extension WKAlertAction {
    enum Style: Int {
        case cancel
        case confirm
    }
}
