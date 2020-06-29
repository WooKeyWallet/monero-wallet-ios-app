//
//  GIFImageView.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/5/18.
//  Copyright © 2020 Wookey. All rights reserved.
//

import UIKit
import Gifu

class WKImageView: UIImageView, GIFAnimatable {
    
    /// A lazy animator.
    public lazy var animator: Animator? = {
      return Animator(withDelegate: self)
    }()

    /// Layer delegate method called periodically by the layer. **Should not** be called manually.
    ///
    /// - parameter layer: The delegated layer.
    override public func display(_ layer: CALayer) {
      updateImageIfNeeded()
    }
}
