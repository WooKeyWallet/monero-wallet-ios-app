//
//  ReceiveViewModel.swift


import UIKit

class ReceiveViewModel: NSObject {
    
    // MARK: - Properties (public lazy)
    
    public lazy var qrcodeLoading = { Postable<Bool>() }()
    
    
    // MARK: - Properties (public)
    
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
    private let wallet: XMRWallet
    
    private var paymentIdText: String = ""
    private var integartedAddressText: String = "" {
        didSet {
            guard oldValue != integartedAddressText else {
                return
            }
            intergartedAddressState.value = integartedAddressText
            if integartedAddressText == "" {
                let addr = token.displayAddress()
                generateQRCode(addr)
            } else {
                generateQRCode(integartedAddressText)
            }
        }
    }
    
    
    // MARK: - Properties (Lazy)
    
    lazy var qrcodeState = { Observable<UIImage?>(nil) }()
    lazy var addressLabelState = { Observable<String>("") }()
    lazy var addressState = { Observable<String>("") }()
    lazy var paymentIdState = { Observable<String>("") }()
    lazy var intergartedAddressState = { Observable<String>("") }()
    lazy var paymentIdCountState = { Observable<String>("0/16") }()
    
    
    // MARK: - Life Cycle
    
    init(token: TokenWallet, wallet: XMRWallet) {
        self.token = token
        self.wallet = wallet
        super.init()
    }
    
    func configure() {
        WalletDefaults.shared.subAddressIndexState.observe(self) { (subAddress, _Self) in
            let key = _Self.wallet.publicAddress
            let model = subAddress[key]
            let addr = model?.address ?? _Self.wallet.publicAddress
            if _Self.integartedAddressText == "" {
                _Self.generateQRCode(addr)
            }
            _Self.addressLabelState.value = model?.label ?? LocalizedString(key: "primaryAddress", comment: "")
            guard !_Self.addressState.value.contains("*") else { return }
            _Self.addressState.value = addr
        }
        generateQRCode(wallet.publicAddress)
    }
    
    
    // MARK: - Methods (Prviate)
    
    private func generateQRCode(_ content: String) {
        qrcodeLoading.newState(true)
        Helper.generateQRCode(content: content, icon: nil) { (qrcode) in
            self.qrcodeState.value = qrcode
            self.qrcodeLoading.newState(false)
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
            if MoneroWalletWrapper.validAddress(generatedIntegartedAddress) {
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
    
    public func showHideAddress(_ isHidden: Bool) {
        let addr = token.displayAddress()
        addressState.value = !isHidden ? addr : String(addr.map({ _ in Character.init("*") }))
    }
    
    public func copyAddress() {
        UIPasteboard.general.string = token.displayAddress()
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
    
    public func toSubAddress() -> UIViewController {
        let viewModel = SubAddressViewModel(wallet: wallet)
        return SubAddressViewController(viewModel: viewModel)
    }
    
}
