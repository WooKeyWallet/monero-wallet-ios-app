//
//  Node.swift


import UIKit

struct NodeDefaults {
    
    struct Monero {
        
        static let default_en = "node.moneroworld.com:18089"
        static let default_zh = "124.160.224.28:18081"
        static let default1 = "opennode.xmr-tw.org:18089"
        static let default2 = "uwillrunanodesoon.moneroworld.com:18089"
        
        static var `default`: String {
            switch AppLanguage.manager.current {
            case .en:
                return default_en
            case .zh:
                return default_zh
            }
        }
        
        static var defaultList: [String] {
            switch AppLanguage.manager.current {
            case .en:
                return [default_en, default_zh, default1, default2]
            case .zh:
                return [default_zh, default_en, default1, default2]
            }
        }
    }
}

struct TokenNodeModel {
    var tokenImage: UIImage?
    var tokenName: String = ""
    var tokenNode: String = ""
}

struct NodeOption {
    var node: String
    var fps: Int?
    var isSelected: Bool = false
}
