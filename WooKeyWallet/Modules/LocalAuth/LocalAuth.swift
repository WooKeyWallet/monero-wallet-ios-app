//
//  LocalAuth.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/6/10.
//  Copyright © 2020 Wookey. All rights reserved.
//

import Foundation
import LocalAuthentication


public final class LocalAuth {
    
    // MARK: - Properties (public static)
    
    public static let `default` = { LocalAuth() }()
    
    
    // MARK: - Properties (public)
    
    public var authId: ID {
        get {
            return authIdSupports()
        }
    }
    
    
    // MARK: - Methods (private)
    
    private var context: LAContext?
    
    private func authIdSupports() -> ID {
        var Id: ID = .none
        let context = LAContext()
        if canEvaluatePolicy(context) {
            if #available(iOS 11.0, *) {
                switch context.biometryType {
                case .faceID:
                    Id = .face
                case .touchID:
                    Id = .touch
                default:
                    break
                }
            } else {
                Id = .touch
            }
        }
        return Id
    }
    
    private func canEvaluatePolicy(_ context: LAContext) -> Bool {
        var error: NSError? = nil
        defer {
            #if DEBUG
            if let error = error {
                print(error)
            }
            #endif
        }
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    
    // MARK: - Methods (public)
    
    public func evaluatePolicy(_ localizedReason: String, result: ((Result<Void, ErrorCode>) -> Void)?) {
        let context = LAContext()
        guard canEvaluatePolicy(context) else {
            result?(.failure(.biometryNotAvailable))
            return
        }
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    result?(.success(()))
                } else {
                    guard let error = error else { return }
                    result?(.failure(ErrorCode(error: error as NSError)))
                }
            }
            self.context = nil
        }
        self.context = context
    }
    
}

public extension LocalAuth {
    
    enum ID: Int {
        case face
        case touch
        case none
    }
    
    enum ErrorCode: Error {
        case authenticationFailed // 验证失败
        case userCancel // 被用户手动取消
        case userFallback // 用户不使用TouchID,选择手动输入密码
        case systemCancel // 被系统取消 (如遇到来电,锁屏,按了Home键等)
        case passcodeNotSet // 无法启动,因为用户没有设置密码
        case biometryNotEnrolled // 无法启动,因为用户没有设置TouchID
        case biometryNotAvailable // 无效
        case biometryLockout // 被锁定(连续多次验证TouchID失败,系统需要用户手动输入密码)
        case appCancel // 当前软件被挂起并取消了授权 (如App进入了后台等)
        case invalidContext // 当前软件被挂起并取消了授权 (LAContext对象无效)
        case unknow
        
        init(error: NSError) {
            guard let code = LAError.Code(rawValue: error.code) else {
                self = .unknow
                return
            }
            switch code {
            case .authenticationFailed:
                self = .authenticationFailed
            case .userCancel:
                self = .userCancel
            case .userFallback:
                self = .userFallback
            case .systemCancel:
                self = .systemCancel
            case .passcodeNotSet:
                self = .passcodeNotSet
            case .touchIDNotEnrolled:
                self = .biometryNotEnrolled
            case .touchIDNotAvailable:
                self = .biometryNotAvailable
            case .touchIDLockout:
                self = .biometryLockout
            case .appCancel:
                self = .appCancel
            case .invalidContext:
                self = .invalidContext
            default:
                self = .unknow
            }
        }
    }
}

