//
//  WKActivityIndicatorView.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/5/15.
//  Copyright © 2020 Wookey. All rights reserved.
//

import UIKit

class WKActivityIndicatorView: UIActivityIndicatorView {

    // MARK: - Properties (public)

    public var isLoading = false {
        didSet {
            guard isLoading != oldValue else {
                return
            }
            isLoading ? startAnimating() : stopAnimating()
        }
    }
    
    
    // MARK: - Life Cycles
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if isLoading && !isAnimating {
            startAnimating()
        }
    }
}
