//
//  WKScriptMessageHandler.swift
//

import Foundation
import WebKit

public class WKScriptMessager: NSObject, WKScriptMessageHandler {
    
    private var delegate: WKScriptMessageHandler?
    
    init(_ delegate: WKScriptMessageHandler) {
        super.init()
        self.delegate = delegate
    }
    
    // MARK: - WKScriptMessageHandler
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}
