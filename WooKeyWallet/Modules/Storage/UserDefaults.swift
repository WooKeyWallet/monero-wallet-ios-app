//
//  WalletUserDefaults.swift


import UIKit

private struct KeyPath {
    static let localAuthOptions = "localAuthOptionsKey"
    static let walletsCount = "walletsCountKey"
    static let node_current = "node_current_key"
    static let wallet_proceed = "walletProceedKey"
    static let wallet_subAddress = "walletSubAddressKey"
    static let wallet_subAddress_index = "walletIndexSubAddressKey"
    static let hiddenAsset = "hiddenAssetKey"
    static let hasFaceOrTouchID = "faceOrTouchIDKey"
    static let hasGesturePassword = "gesturePasswordKey"
}

public class WalletDefaults: UserDefaults {
    
    // MARK: - Properties
    
    public static let shared = { return WalletDefaults(suiteName: "WalletUserDefaults")! }()
    
    public var localAuthOptions: [LocalAuthOptions] {
        get { return [LocalAuthOptions](rawValues: array(forKey: KeyPath.localAuthOptions) as? [Int]) }
        set {
            set(newValue.map({$0.rawValue}), forKey: KeyPath.localAuthOptions)
            if newValue.isEmpty {
                self.hasFaceOrTouchID = false
                self.hasGesturePassword = false
            }
        }
    }
    
    public var hasFaceOrTouchID: Bool {
        get { return bool(forKey: KeyPath.hasFaceOrTouchID) }
        set {
            set(newValue, forKey: KeyPath.hasFaceOrTouchID)
        }
    }
    
    public var hasGesturePassword: Bool {
        get { return bool(forKey: KeyPath.hasGesturePassword) }
        set {
            set(newValue, forKey: KeyPath.hasGesturePassword)
        }
    }
    
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
    
    public typealias SubAddressIndexs = [String: SubAddress]
    public var subAddress: SubAddressIndexs {
        get {
            let json = value(forKey: KeyPath.wallet_subAddress) as? [String: Data] ?? [:]
            return json.compactMapValues({ try? JSONDecoder().decode(SubAddress.self, from: $0) })
        }
        set {
            let json = newValue.compactMapValues({ try? JSONEncoder().encode($0) })
            self.set(json, forKey: KeyPath.wallet_subAddress)
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
    
    lazy var subAddressIndexState = { Observable<SubAddressIndexs>(subAddress) }()
    
    public func upgrade() {
        
    }
    
}

extension WalletDefaults {
    convenience init(wallet name: String) {
        self.init(suiteName: "WalletUserDefaults_" + name)!
    }
}
