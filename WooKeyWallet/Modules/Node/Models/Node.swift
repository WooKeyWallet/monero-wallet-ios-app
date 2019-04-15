//
//  Node.swift


import UIKit

struct NodeDefaults {
    struct Monero {
        static let `default` = "node.moneroworld.com:18089"
        static let default0 = "opennode.xmr-tw.org:18089"
        static let default1 = "uwillrunanodesoon.moneroworld.com:18089"
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
