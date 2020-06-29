//
//  UITableViewCell + Ext.swift
//  Wookey
//
//  Created by jowsing on 2020/5/12.
//  Copyright © 2020 Wookey. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    var editControl: UIControl? {
        for subview in subviews {
            if "\(subview.classForCoder)" == "UITableViewCellEditControl" {
                return subview as? UIControl
            }
        }
        return nil
    }
}

