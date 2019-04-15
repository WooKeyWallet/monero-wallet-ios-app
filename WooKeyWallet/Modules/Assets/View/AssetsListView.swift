//
//  AssetsListView.swift


import UIKit

class AssetsTokenItemView: UIView {
    
    // MARK: - Properties (Public)
    
    public var balanceSecureTextEntry: Bool = false {
        didSet {
            remainLabel.text = balanceSecureTextEntry ? "****" : balance
        }
    }
    
    // MARK: - Properties (Private)
    
    private var balance: String = ""
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var tokenIconView = { UIImageView() }()
    private lazy var tokenNameLabel = { UILabel() }()
    private lazy var remainLabel = { UILabel() }()
    private lazy var rightArrow = { UIImageView() }()
    private lazy var bottomLine = { UIView() }()
    
    // MARK: - Life Cycles
    
    required init() {
        super.init(frame: .zero)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let midY = height / 2
        rightArrow.updateFrame(CGRect(x: width - 8 - 15, y: midY - 6.5, width: 8, height: 13))
        tokenIconView.updateFrame(CGRect(x: 15, y: midY - 15, width: 30, height: 30))
        tokenNameLabel.sizeToFit()
        tokenNameLabel.updateFrame(CGRect(x: tokenIconView.maxX + 10, y: midY - tokenNameLabel.height/2, width: tokenNameLabel.width, height: tokenNameLabel.height))
        remainLabel.updateFrame(CGRect(x: tokenNameLabel.maxX + 10, y: midY - 10, width: rightArrow.x - tokenNameLabel.maxX - 20, height: 20))
    }
    
    private func configureView() {
        
        do///Self
        {
            layer.cornerRadius = 5
            backgroundColor = AppTheme.Color.page_common
        }
        
        do///Subviews
        {
            tokenIconView.contentMode = .scaleAspectFill
            tokenIconView.layer.cornerRadius = 15
            tokenIconView.layer.masksToBounds = true
            
            tokenNameLabel.textColor = AppTheme.Color.text_dark
            tokenNameLabel.font = AppTheme.Font.text_normal
            
            remainLabel.textColor = AppTheme.Color.text_dark
            remainLabel.font = AppTheme.Font.text_normal.medium()
            remainLabel.textAlignment = .right
            
            rightArrow.image = UIImage(named: "cell_arrow_right")
            
            bottomLine.backgroundColor = AppTheme.Color.cell_line
            
            addSubViews([
            tokenIconView,
            tokenNameLabel,
            remainLabel,
            rightArrow,
            bottomLine,
            ])
        }
    }
    
    // MARK: - configure model
    
    public func configure(_ model: Assets) {
        tokenIconView.image = model.icon
        tokenNameLabel.text = model.token
        remainLabel.text = balanceSecureTextEntry ? "****" : model.remain
        balance = model.remain
    }
}

class AssetsListView: UIView {
    
    // MARK: - Properties (Public)
    
    public var rowHeight: CGFloat = 77
    public var topAreaHeight: CGFloat = 45
    public var contentEdgeInserts = UIEdgeInsets(top: 15, left: 16, bottom: 15, right: 16)
    
    public var balanceSecureTextEntryState = false {
        didSet {
            updateBalance()
        }
    }
    
    // MARK: - Properties (Private)
    
    private let _width: CGFloat
    
    private var clickActionHandler: ((Int) -> Void)?
    
    
    // MARK: - Properties (Lazy)
    
    public lazy var syncButton: BaseButton = { BaseButton.init(frame: .zero, imageTitlePostion: .rightLeft(padding: 6)) }()
    private lazy var contentView: UIView = { UIView() }()
    private lazy var stackView: UIView = { UIView() }()
    
    
    // MARK: - Life Cycles

    required init(width: CGFloat) {
        self._width = width
        super.init(frame: .zero)
        configureView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    private func configureView() {
        
        backgroundColor = AppTheme.Color.tableView_bg
        contentView.backgroundColor = AppTheme.Color.page_common
        contentView.layer.cornerRadius = 5
        addSubview(contentView)
        
        do///top
        {
            let titleLabel = UILabel()
            titleLabel.text = LocalizedString(key: "assets.list.title", comment: "")
            titleLabel.textColor = AppTheme.Color.text_dark
            titleLabel.font = AppTheme.Font.text_normal
            contentView.addSubview(titleLabel)
            
            syncButton.setImage(UIImage(named: "assets_ sync_success"), for: .normal)
            syncButton.setTitle(LocalizedString(key: "assets.sync.success", comment: ""), for: .normal)
            syncButton.setTitleColor(AppTheme.Color.main_green_light, for: .normal)
            syncButton.titleLabel?.font = titleLabel.font
            syncButton.isHidden = true
            contentView.addSubview(syncButton)
            
            let bottomLine = UIView()
            bottomLine.backgroundColor = AppTheme.Color.cell_line
            contentView.addSubview(bottomLine)
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.left.equalToSuperview().offset(15)
            }
            syncButton.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-15)
                make.centerY.equalTo(titleLabel)
            }
            bottomLine.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(topAreaHeight-1)
                make.left.equalTo(titleLabel)
                make.right.equalTo(syncButton)
                make.height.equalTo(px(1))
            }
        }
        
        do///list
        {
            contentView.addSubview(stackView)
            
            contentView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(contentEdgeInserts.left)
                make.right.equalToSuperview().offset(-contentEdgeInserts.right)
                make.top.equalToSuperview().offset(contentEdgeInserts.top)
                make.bottom.equalToSuperview().offset(-contentEdgeInserts.bottom)
            }
        }
    }
    
    private func configureReusableViews(_ modelCount: Int) {
        let content_w = _width - contentEdgeInserts.left - contentEdgeInserts.right
        stackView.frame = CGRect(x: 0, y: topAreaHeight + 10, width: content_w, height: contentView.height - topAreaHeight - 20)
        let gap = modelCount - stackView.subviews.count
        if gap > 0 {
            var lastY = stackView.subviews.last?.maxY ?? 0
            stride(from: 0, to: gap, by: 1).forEach { (_) in
                let tokenView = AssetsTokenItemView()
                tokenView.frame = CGRect(x: 0, y: lastY, width: content_w, height: rowHeight)
                tokenView.balanceSecureTextEntry = balanceSecureTextEntryState
                stackView.addSubview(tokenView)
                tokenView.addTapGestureRecognizer(target: self, selector: #selector(self.clickAction(_:)))
                lastY = tokenView.maxY
            }
        } else if gap < 0 {
            stride(from: 0, to: abs(gap), by: 1).forEach { (_) in
                stackView.subviews.last?.removeFromSuperview()
            }
        }
    }
    
    public func configure(_ assetsList: [Assets]) {
        self.width = _width
        self.height = CGFloat(assetsList.count) * rowHeight + topAreaHeight + contentEdgeInserts.top + contentEdgeInserts.bottom + 20
        setNeedsLayout()
        layoutIfNeeded()
        print(contentView.frame)
        contentView.layer.setDefaultShadowStyle()
        
        configureReusableViews(assetsList.count)
        
        stride(from: 0, to: assetsList.count, by: 1).forEach { (i) in
            guard let tokenView = stackView.subviews[i] as? AssetsTokenItemView else { return }
            tokenView.configure(assetsList[i])
            tokenView.tag = i
        }
    }
    
    public func configureHandlers(_ clickAction: ((Int) -> Void)?) {
        clickActionHandler = clickAction
    }
    
    private func updateBalance() {
        stackView.subviews.forEach { (sub) in
            guard let sub = sub as? AssetsTokenItemView else { return }
            sub.balanceSecureTextEntry = balanceSecureTextEntryState
        }
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func clickAction(_ sender: UITapGestureRecognizer) {
        guard let senderView = sender.view else { return }
        clickActionHandler?(senderView.tag)
    }
    
}
