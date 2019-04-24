//
//  Debug + Log.swift


import Foundation

public func dPrint(_ item:@autoclosure () -> Any) {
    #if DEBUG
    print("\(Date()) \(AppInfo.displayName) [\(#line)] \(item())")
    #elseif DEBUG_LOC
    print("\(Date()) \(AppInfo.displayName) [\(#line)] \(item())")
    #endif
}
