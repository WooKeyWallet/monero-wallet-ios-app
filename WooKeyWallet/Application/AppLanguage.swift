//
//  AppLanguage.swift


import UIKit

public func LocalizedString(key: String, comment: String) -> String {
    let forResource: String
    switch AppLanguage.manager.current {
    case .zh:
        forResource = "zh-Hans"
    default:
        forResource = "en"
    }
    guard
        let path = Bundle.main.path(forResource: forResource, ofType: "lproj"),
        let localizedString = Bundle.init(path: path)?.localizedString(forKey: key, value: "", table: nil)
        else {
            return comment
    }
    return localizedString
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
