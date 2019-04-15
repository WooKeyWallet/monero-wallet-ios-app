//
//  ReceiveViewModel.swift


import UIKit

class ReceiveViewModel: NSObject {
    
    // MARK: - Properties (Public)
    
    public var navigationTitle: String {
        return token.token + LocalizedString(key: "receive.title.suffix", comment: "")
    }
    
    public var receiveTitle: String {
        return LocalizedString(key: "receive.amount.title", comment: "").replacingOccurrences(of: "$0", with: "").replacingOccurrences(of: "$1", with: token.token)
    }
    
    public var receiveTips: String {
        return LocalizedString(key: "receive.address.tips", comment: "").replacingOccurrences(of: "$0", with: token.token)
    }
    
    
    // MARK: - Properties (Private)
    
    private let token: TokenWallet
    private let wallet: WalletProtocol
    
    private var paymentIdText: String = ""
    private var integartedAddressText: String = "" {
        didSet {
            guard oldValue != integartedAddressText else {
                return
            }
            intergartedAddressState.value = integartedAddressText
            if integartedAddressText == "" {
                generateQRCode(wallet.publicAddress)
            } else {
                generateQRCode(integartedAddressText)
            }
        }
    }
    
    
    // MARK: - Properties (Lazy)
    
    lazy var qrcodeState = { Observable<UIImage?>(nil) }()
    lazy var addressState = { Observable<String>("") }()
    lazy var paymentIdState = { Observable<String>("") }()
    lazy var intergartedAddressState = { Observable<String>("") }()
    lazy var paymentIdCountState = { Observable<String>("0/16") }()
    
    
    // MARK: - Life Cycle
    
    init(token: TokenWallet, wallet: WalletProtocol) {
        self.token = token
        self.wallet = wallet
        super.init()
    }
    
    func configure() {
        addressState.value = wallet.publicAddress
        generateQRCode(wallet.publicAddress)
    }
    
    
    // MARK: - Methods (Prviate)
    
    private func generateQRCode(_ content: String) {
        Helper.generateQRCode(content: content, icon: nil) { (qrcode) in
            self.qrcodeState.value = qrcode
        }
    }
    

    // MARK: - Methods (Public)
    
    public func inputPaymentId(_ text: String) {
        var _text = text
        if text.count > 64 {
            _text = String(text.prefix(64))
            paymentIdState.value = _text
        }
        if text.count == 16 || text.count == 64 {
            let generatedIntegartedAddress = wallet.generateIntegartedAddress(text)
            if wallet.validAddress(generatedIntegartedAddress) {
                self.integartedAddressText = generatedIntegartedAddress
            } else {
                self.integartedAddressText = ""
            }
        } else {
            self.integartedAddressText = ""
        }
        if _text.count > 16 {
            paymentIdCountState.value = "\(_text.count)/64"
        } else {
            paymentIdCountState.value = "\(_text.count)/16"
        }
        self.paymentIdText = _text
    }
    
    public func generatePaymentId() {
        let id = wallet.generatePaymentId()
        paymentIdState.value = id
        inputPaymentId(id)
    }
    
    public func copyAddress() {
        UIPasteboard.general.string = wallet.publicAddress
        HUD.showSuccess(LocalizedString(key: "copy_success", comment: ""))
    }
    
    public func copyPaymentId() {
        guard paymentIdText != "" else {
            return
        }
        UIPasteboard.general.string = paymentIdText
        HUD.showSuccess(LocalizedString(key: "copy_success", comment: ""))
    }
    
    public func copyIntegartedAddress() {
        guard integartedAddressText != "" else {
            return
        }
        UIPasteboard.general.string = integartedAddressText
        HUD.showSuccess(LocalizedString(key: "copy_success", comment: ""))
    }
    
}
