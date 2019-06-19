//
//  WalletUserDefaults.swift


import UIKit

private struct KeyPath {
    static let walletsCount = "walletsCountKey"
    static let node_current = "node_current_key"
    static let wallet_proceed = "walletProceedKey"
    static let wallet_subAddress_index = "walletIndexSubAddressKey"
}

public class WalletDefaults: UserDefaults {
    
    // MARK: - Properties
    
    public static let shared = { return WalletDefaults(suiteName: "WalletUserDefaults")! }()
    
    public var walletsCount: Int {
        get { return integer(forKey: KeyPath.walletsCount) }
        set {
            set(newValue, forKey: KeyPath.walletsCount)
        }
    }
    
    
    public var proceedWalletID: Int? {
        get { return value(forKey: KeyPath.wallet_proceed) as? Int }
        set {
            set(newValue, forKey: KeyPath.wallet_proceed)
        }
    }
    
    
    public var node: String {
        get { return string(forKey: KeyPath.node_current) ?? NodeDefaults.Monero.default }
        set {
            set(newValue, forKey: KeyPath.node_current)
        }
    }
    
    public typealias SubAddressIndexs = [String: String]
    public var subAddressIndexs: SubAddressIndexs {
        get { return value(forKey: KeyPath.wallet_subAddress_index) as? SubAddressIndexs ?? [:] }
        set {
            set(newValue, forKey: KeyPath.wallet_subAddress_index)
            if newValue != subAddressIndexState.value {
                DispatchQueue.main.async {
                    self.subAddressIndexState.value = newValue
                }
            }
        }
    }
    
    lazy var subAddressIndexState = { Observable<SubAddressIndexs>(subAddressIndexs) }()
    
    // MARK: - Methods
    
    
}
