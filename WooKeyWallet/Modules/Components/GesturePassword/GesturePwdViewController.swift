//
//  GesturePwdViewController.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/6/15.
//  Copyright © 2020 Wookey. All rights reserved.
//

import UIKit

protocol GesturePasswordManager {
    var configResult: (Result<GesturePwdViewController.ConfigType, GesturePwdViewController.ConfigError>) -> Void { get }
    func currentPassword() -> String
    func updatePassword(_ password: String)
}

class GesturePwdViewController: BaseViewController, PatternLockViewDelegate {

    enum ConfigType {
        case setup
        case modify
        case vertify
    }
    
    enum ConfigError: Error {
        case maxErrorCount
    }
    
    private let type: ConfigType
    private let passwordManager: GesturePasswordManager
    
    private var currentPassword: String = ""
    private var firstPassword: String = ""
    private var secondPassword: String = ""
    private var canModify: Bool = false
    private let maxErrorCount: Int = 5
    private var currentErrorCount: Int = 0
    
    private lazy var iconView: UIImageView = {
        let iconView = UIImageView()
        iconView.image = UIImage(named: "logo_designed")
        return iconView
    }()
    private lazy var lockView: PatternLockView = {
        let lockView = PatternLockView(config: GrayRoundConfig())
        lockView.delegate = self
        return lockView
    }()
    private lazy var pathView: PatternLockPathView = {
        var pathConifg = LockConfig()
        pathConifg.gridSize = CGSize(width: 10, height: 10)
        pathConifg.matrix = Matrix(row: 3, column: 3)
        let tintColor = AppTheme.Color.main_green
        pathConifg.initGridClosure = {(matrix) -> PatternLockGrid in
            let gridView = GridView()
            let outerStrokeLineWidthStatus = GridPropertyStatus<CGFloat>.init(normal: 1, connect: 1, error: 1)
            let outerStrokeColorStatus = GridPropertyStatus<UIColor>(normal: tintColor, connect: tintColor, error: UIColor.red)
            let outerFillColorStatus = GridPropertyStatus<UIColor>(normal: nil, connect: tintColor, error: UIColor.red)
            gridView.outerRoundConfig = RoundConfig(radius: 5, lineWidthStatus: outerStrokeLineWidthStatus, lineColorStatus: outerStrokeColorStatus, fillColorStatus: outerFillColorStatus)
            gridView.innerRoundConfig = RoundConfig.empty
            return gridView
        }
        let lineView = ConnectLineView()
        lineView.lineColorStatus = .init(normal: .clear, error: .clear)
        lineView.lineWidth = 1
        pathConifg.connectLine = lineView
        return PatternLockPathView(config: pathConifg)
    }()
    private lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.font = AppTheme.Font.text_normal
        return label
    }()
    private lazy var usePwdButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(LocalizedString(key: "usePassword", comment: ""), for: .normal)
        btn.setTitleColor(AppTheme.Color.main_blue, for: .normal)
        btn.setTitleColor(AppTheme.Color.main_blue.highlighted(), for: .highlighted)
        btn.titleLabel?.font = AppTheme.Font.text_small
        return btn
    }()

    init(type: ConfigType, passwordManager: GesturePasswordManager) {
        self.type = type
        self.passwordManager = passwordManager
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        super.configureUI()
        
        do // Views
        {
            view.backgroundColor = AppTheme.Color.page_common
            view.addSubViews([
                iconView,
                lockView,
                tipsLabel,
                pathView,
            ])
        }
        
        do // Layouts
        {
            tipsLabel.snp.makeConstraints { (make) in
                if #available(iOS 11.0, *) {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(114)
                } else {
                    make.top.equalTo(178)
                }
                make.centerX.equalToSuperview()
            }
            
            iconView.snp.makeConstraints { (make) in
                make.bottom.equalTo(tipsLabel.snp.top).offset(-20)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 100, height: 75))
            }
            
            pathView.snp.makeConstraints { (make) in
                make.bottom.equalTo(tipsLabel.snp.top).offset(-20)
                make.centerX.equalToSuperview()
                make.size.equalTo(50)
            }
        }
    }

    override func configureBinds() {
        super.configureBinds()
        switch type {
        case .setup:
            navigationItem.title = LocalizedString(key: "gesture.pwdSet.title", comment: "")
            tipsLabel.text = LocalizedString(key: "gesture.pwd.setup", comment: "")
            iconView.isHidden = true
        case .modify:
            navigationItem.title = LocalizedString(key: "gesture.pwdReset.title", comment: "")
            tipsLabel.text = LocalizedString(key: "gesture.oldPwd.vertify", comment: "")
            pathView.isHidden = true
        case .vertify:
            tipsLabel.text = LocalizedString(key: "gesture.pwd.vertify", comment: "")
            pathView.isHidden = true
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
            if let navigationBar = navigationController?.navigationBar {
                navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
            }
            view.addSubview(usePwdButton)
            usePwdButton.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.height.equalTo(30)
                make.bottom.equalTo(-45)
            }
            usePwdButton.addTarget(self, action: #selector(usePasswordClicked), for: .touchUpInside)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let lockWidth: CGFloat = 2/3 * view.bounds.size.width
        lockView.frame = CGRect(x: lockWidth * 0.25, y: tipsLabel.maxY + 50, width: lockWidth, height: lockWidth)
    }

    //MARK: - Event
    
    @objc func usePasswordClicked() {
        close()
        passwordManager.configResult(.failure(.maxErrorCount))
    }
    
    @objc func didRestButtonClicked() {
        showNormalText(LocalizedString(key: "gesture.pwdSet.title", comment: ""))
        currentPassword = ""
        firstPassword = ""
        secondPassword = ""
        pathView.reset()
        lockView.reset()
        self.navigationItem.rightBarButtonItem = nil
    }

    func showResetButtonIfNeeded() {
        guard type == .setup || type == .modify else {
            return
        }
        if !firstPassword.isEmpty {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: LocalizedString(key: "reset", comment: ""), style: .plain, target: self, action: #selector(didRestButtonClicked))
        }
    }

    func shouldShowErrorWithSavedAndCurrentPassword() -> Bool {
        if currentPassword == passwordManager.currentPassword() {
            //当前密码与保存的密码相同，不需要显示error
            return false
        }else {
            return true
        }
    }

    func shouldShowErrorWithFirstAndSecondPassword() -> Bool {
        if firstPassword.isEmpty {
            //第一次密码还未配置，不需要显示error
            return false
        }else if firstPassword == currentPassword {
            //两次输入的密码相同，不需要显示error
            return false
        }else {
            return true
        }
    }

    func setupPassword() {
        if firstPassword.isEmpty {
            firstPassword = currentPassword
            showNormalText(LocalizedString(key: "gesture.pwd.setup2", comment: ""))
        } else {
            secondPassword = currentPassword
            if firstPassword == secondPassword {
                passwordManager.updatePassword(firstPassword)
                passwordManager.configResult(.success(type))
                close()
            } else {
                showResetButtonIfNeeded()
                showErrorText(LocalizedString(key: "gesture.pwd.error.confirm", comment: ""))
                secondPassword = ""
            }
        }
    }

    func showErrorText(_ text: String) {
        tipsLabel.text = text
        tipsLabel.textColor = .red
        tipsLabel.layer.shakeBody()
    }

    func showNormalText(_ text: String) {
        tipsLabel.text = text
        tipsLabel.textColor = .lightGray
    }

    func showPasswordError() {
        currentErrorCount += 1
        if currentErrorCount == maxErrorCount {
            passwordManager.configResult(.failure(.maxErrorCount))
            close()
        }else {
            showErrorText(LocalizedString(key: "gesture.pwd.error.count", comment: "").replacingOccurrences(of: "$0", with: String(maxErrorCount - currentErrorCount)))
        }
    }

    func shouldHandlePathView() -> Bool {
        if firstPassword.isEmpty {
            //第一次的密码未输入，才需要更新path
            if type == .setup {
                return true
            }else if type == .modify {
                if canModify {
                    //修改时，第一次验证成功之后才需要更新path
                    return true
                }
            }
        }
        return false
    }
    
    @objc func close() {
        if let navigationController = navigationController {
            if navigationController.presentingViewController != nil {
                navigationController.dismiss(animated: true, completion: nil)
            } else {
                navigationController.popViewController(animated: true)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    

    //MARK: - PatternLockViewDelegate
    
    func lockView(_ lockView: PatternLockView, didConnectedGrid grid: PatternLockGrid) {
        currentPassword += grid.identifier
        if shouldHandlePathView() {
            pathView.addGrid(at: grid.matrix)
        }
    }

    func lockViewDidConnectCompleted(_ lockView: PatternLockView) {
        if currentPassword.count < 4 {
            showErrorText(LocalizedString(key: "gesture.pwd.error.length", comment: ""))
            if shouldHandlePathView() {
                pathView.reset()
            }
            showResetButtonIfNeeded()
        } else {
            switch type {
            case .setup:
                setupPassword()
            case .modify:
                if canModify {
                    setupPassword()
                } else {
                    if currentPassword == passwordManager.currentPassword() {
                        pathView.isHidden = false
                        iconView.isHidden = true
                        showNormalText(LocalizedString(key: "gesture.pwd.setup", comment: ""))
                        canModify = true
                    } else {
                        showPasswordError()
                    }
                }
            case .vertify:
                if currentPassword == passwordManager.currentPassword() {
                    passwordManager.configResult(.success(type))
                    close()
                } else {
                    showPasswordError()
                }
            }
        }
        print(currentPassword)
        currentPassword = ""
    }

    func lockViewShouldShowErrorBeforeConnectCompleted(_ lockView: PatternLockView) -> Bool {
        if type == .vertify {
            return shouldShowErrorWithSavedAndCurrentPassword()
        }else if type == .setup {
            return shouldShowErrorWithFirstAndSecondPassword()
        }else if type == .modify {
            if !canModify {
                return shouldShowErrorWithSavedAndCurrentPassword()
            }else {
                return shouldShowErrorWithFirstAndSecondPassword()
            }
        }
        return false
    }

}

extension CALayer {
    func shakeBody() {
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        keyFrameAnimation.values = [0, 16, -16, 8, -8 ,0]
        keyFrameAnimation.duration = 0.3
        keyFrameAnimation.repeatCount = 1
        add(keyFrameAnimation, forKey: "shake")
    }
}

struct GrayRoundConfig: PatternLockViewConfig {
    var matrix: Matrix = Matrix(row: 3, column: 3)
    var gridSize: CGSize = CGSize(width: 60, height: 60)
    var connectLine: ConnectLine?
    var autoMediumGridsConnect: Bool = false
    var connectLineHierarchy: ConnectLineHierarchy = .bottom
    var errorDisplayDuration: TimeInterval = 1
    var initGridClosure: (Matrix) -> (PatternLockGrid)

    init() {
        let tintColot = AppTheme.Color.main_green
        initGridClosure = {(matrix) -> PatternLockGrid in
            let gridView = GridView()
            let outerFillColorStatus = GridPropertyStatus<UIColor>(normal: nil, connect: tintColot.withAlphaComponent(0.3), error: UIColor.red.withAlphaComponent(0.3))
            gridView.outerRoundConfig = RoundConfig(radius: 33, lineWidthStatus: nil, lineColorStatus: nil, fillColorStatus: outerFillColorStatus)
            let innerFillColorStatus = GridPropertyStatus<UIColor>(normal: .lightGray, connect: tintColot, error: .red)
            gridView.innerRoundConfig = RoundConfig(radius: 10, lineWidthStatus: nil, lineColorStatus: nil, fillColorStatus: innerFillColorStatus)
            return gridView
        }
        let lineView = ConnectLineView()
        lineView.lineColorStatus = .init(normal: tintColot, error: .red)
        lineView.lineWidth = 3
        connectLine = lineView
    }
}

