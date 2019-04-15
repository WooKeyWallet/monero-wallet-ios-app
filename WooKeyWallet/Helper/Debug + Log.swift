//
//  Debug + Log.swift


import Foundation

public func dPrint(_ item:@autoclosure () -> Any) {
    #if DEBUG
    print("\(Date()) MarsWallet [\(#line)] \(item())")
    #elseif DEBUG_LOC
    print("\(Date()) MarsWallet [\(#line)] \(item())")
    #endif
}
