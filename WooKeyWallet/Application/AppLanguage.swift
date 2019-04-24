//
//  AppLanguage.swift


import UIKit

private struct LProjPath {
    static let zh_Hans = { Bundle.main.path(forResource: "zh-Hans", ofType: "lproj") }()
    static let en = { Bundle.main.path(forResource: "en", ofType: "lproj") }()
}

public func LocalizedString(key: String, comment: String) -> String {
    let path: String?
    switch AppLanguage.manager.current {
    case .zh:
        path = LProjPath.zh_Hans
    case .en:
        path = LProjPath.en
    }
    guard
        let _path = path,
        let bundle = Bundle.init(path: _path)
    else {
        return comment
    }
    return bundle.localizedString(forKey: key, value: "", table: nil)
}

class AppLanguage: NSObject {
    
    enum Lang: String {
        case zh = "zh"
        case en = "en"
    }
    
    static let manager: AppLanguage = { AppLanguage() }()
    static let PreferredLanguageKey: String = "PreferredLanguage"
    
    // MARK: - Properties (Public)
    
    public var current: Lang {
        get {
            var _currentStr: String
            if let lang = UserDefaults.standard.string(forKey: AppLanguage.PreferredLanguageKey), lang.count > 0 {
                _currentStr = lang
            } else { // 沙盒没有就去拿系统的
                _currentStr = Locale.preferredLanguages.first ?? "en"
            }
            if _currentStr.contains("zh") {
                return Lang.zh
            } else {
                return Lang.en
            }
        } set {
            guard newValue != current else {
                return
            }
            lang.value = newValue
            var identify = newValue.rawValue
            if identify.contains("zh") {
                identify = "zh-Hans"
            }
            UserDefaults.standard.set(identify, forKey: AppLanguage.PreferredLanguageKey)
        }
    }
    
    lazy var lang = {
        return Observable<Lang>(current)
    }()
    
}
