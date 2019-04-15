//
//  AppInfo.swift


import UIKit

// MARK: - App Info

struct AppInfo {
    static let infoDictionary = { return Bundle.main.infoDictionary ?? [:] }()
    static let displayName = { return AppInfo.infoDictionary["CFBundleDisplayName"] as? String ?? "" }()
    static let bundleIdentifier = { return Bundle.main.bundleIdentifier ?? "" }()
    static let appVersion = {return AppInfo.infoDictionary["CFBundleShortVersionString"] as? String ?? "" }()
    static let buildVersion = {return AppInfo.infoDictionary["CFBundleVersion"] as? String ?? "" }()
}

// MARK: - pt to px

public func px(_ pt: CGFloat) -> CGFloat {
    return pt / UIScreen.main.scale
}
