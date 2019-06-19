//
//  VisualEffectView.swift
//  WooKeyMonero
//
//  Created by WooKey Team on 2019/6/10.
//  Copyright © 2019 WooKey. All rights reserved.
//

import UIKit

class VisualEffectView: UIVisualEffectView {
    
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    
    var blurRadius: CGFloat {
        get { return _value(forKey: "blurRadius") as! CGFloat }
        set { _setValue(newValue, forKey: "blurRadius") }
    }
    
    var scale: CGFloat {
        get { return _value(forKey: "scale") as! CGFloat }
        set { _setValue(newValue, forKey: "scale") }
    }
    
    // MARK: - Life Cycles
    
    public override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        scale = 1
    }
    
    private func _value(forKey key: String) -> Any? {
        return blurEffect.value(forKeyPath: key)
    }
    
    private func _setValue(_ value: Any?, forKey key: String) {
        blurEffect.setValue(value, forKeyPath: key)
        self.effect = blurEffect
    }
    
}
