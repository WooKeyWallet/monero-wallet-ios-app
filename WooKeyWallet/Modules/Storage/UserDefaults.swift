//
//  WalletUserDefaults.swift


import UIKit

private struct KeyPath {
    static let walletsCount = "walletsCountKey"
    static let node_current = "node_current_key"
    static let wallet_proceed = "walletProceedKey"
    static let wallet_subAddress_index = "walletIndexSubAddressKey"
    static let hiddenAsset = "hiddenAssetKey"
    static let subAddressLabels = "Labels-"
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
    
    public var hiddenAsset: Bool {
        get { return bool(forKey: KeyPath.hiddenAsset) }
        set {
            setValue(newValue, forKey: KeyPath.hiddenAsset)
        }
    }
    
    lazy var subAddressIndexState = { Observable<SubAddressIndexs>(subAddressIndexs) }()
    
    
    // MARK: - Methods
    
    func addSubAddress(label: String, publicAddress: String) {
        let key = KeyPath.subAddressLabels + publicAddress
        var labels = value(forKey: key) as? [String] ?? []
        labels.append(label)
        setValue(labels, forKey: key)
    }
    
    func getSubAddressLabels(_ publicAddress: String) -> [String] {
        let key = KeyPath.subAddressLabels + publicAddress
        return value(forKey: key) as? [String] ?? []
    }
}
