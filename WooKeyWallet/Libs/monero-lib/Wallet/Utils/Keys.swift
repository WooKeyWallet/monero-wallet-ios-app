//
//  Keys.swift


import Foundation

public struct Keys {
    public let restoreHeight: UInt64
    public let addressString: String
    public let viewKeyString: String
    public let spendKeyString: String
    
    public init(restoreHeight: UInt64, addressString: String, viewKeyString: String, spendKeyString: String) {
        self.restoreHeight = restoreHeight
        self.addressString = addressString
        self.viewKeyString = viewKeyString
        self.spendKeyString = spendKeyString
    }
}
