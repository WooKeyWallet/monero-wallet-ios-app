//
//  TransactionDetailView.swift


import UIKit

class BrokenSeparatorView: UIView {
    
    public lazy var leftCurve: UIView = {
        return UIView()
    }()
    
    public lazy var rightCurve: UIView = {
        return UIView()
    }()
    
    public lazy var brokenLine: CAShapeLayer = {
        let shapeLayer = CAShapeLayer.init()
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = 1
        shapeLayer.lineJoin = .round
        shapeLayer.lineDashPattern = [NSNumber(value: 2), NSNumber(value: 2)]
        shapeLayer.strokeColor = AppTheme.Color.line_broken.cgColor
        return shapeLayer
    }()
    
    required init() {
        super.init(frame: .zero)
        
        layer.masksToBounds = true
        
        leftCurve.backgroundColor = AppTheme.Color.tableView_bg
        leftCurve.layer.masksToBounds = true
        rightCurve.backgroundColor = AppTheme.Color.tableView_bg
        rightCurve.layer.masksToBounds = true
        addSubViews([leftCurve, rightCurve])
        layer.addSublayer(brokenLine)
        
        leftCurve.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(self.snp.height)
            make.centerX.equalTo(snp.left)
        }
        rightCurve.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(leftCurve)
            make.centerX.equalTo(snp.right)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let cornerRadius = height * 0.5
        leftCurve.layer.cornerRadius = cornerRadius
        rightCurve.layer.cornerRadius = cornerRadius
        brokenLine.frame = self.bounds
        let path = UIBezierPath.init()
        path.move(to: CGPoint(x: cornerRadius + 2, y: cornerRadius - 0.5))
        path.addLine(to: CGPoint(x: width - cornerRadius - 2, y: cornerRadius - 0.5))
        brokenLine.path = path.cgPath
    }
}

class TransactionDetailBasicInfoView: UIView {
    
    // MARK: - Properties (Lazy)
    
    public lazy var titleLabels: [UILabel] = {
        return (0...5).map({ _ in
            let label = UILabel()
            label.textColor = AppTheme.Color.text_light
            label.font = AppTheme.Font.text_small
            return label
        })
    }()
    
    public lazy var contentLabels: [UILabel] = {
        return (0..<titleLabels.count).map({ _ in
            let label = UILabel()
            label.textColor = AppTheme.Color.text_dark
            label.font = AppTheme.Font.text_small
            label.numberOfLines = 0
            return label
        })
    }()
    
    
    // MARK: - Life Cycles
    
    required init() {
        super.init(frame: .zero)
        self.configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.configureConstraints()
    }
    
    
    // MARK: - Configure
    
    internal func configureView() {
        addSubViews(titleLabels)
        addSubViews(contentLabels)
    }
    
    internal func configureConstraints() {
        stride(from: 0, to: titleLabels.count, by: 1).forEach { (i) in
            let titleLabel = titleLabels[i]
            let contentLabel = contentLabels[i]
            contentLabel.setContentHuggingPriority(UILayoutPriority.init(1), for: .horizontal)
            titleLabel.setContentHuggingPriority(UILayoutPriority.init(700), for: .horizontal)
            titleLabel.snp.makeConstraints({ (make) in
                make.left.equalTo(0)
                make.top.equalTo(contentLabel)
                if i > 0 {
                    make.width.equalTo(titleLabels[i-1])
                    if i == titleLabels.count - 1 {
                        make.bottom.equalTo(0)
                    }
                }
            })
            contentLabel.snp.makeConstraints({ (make) in
                if i == 0 {
                    make.top.equalTo(0)
                } else {
                    make.top.equalTo(contentLabels[i-1].snp.bottom).offset(14)
                }
                make.left.equalTo(titleLabel.snp.right).offset(12)
                make.right.lessThanOrEqualTo(0)
            })
        }
    }
    
    public func configureTitles(strs: [String]) {
        stride(from: 0, to: min(strs.count, titleLabels.count), by: 1).forEach { (i) in
            titleLabels[i].text = strs[i]
        }
    }
    
    public func configureContents(strs: [String]) {
        stride(from: 0, to: min(strs.count, contentLabels.count), by: 1).forEach { (i) in
            contentLabels[i].text = strs[i]
        }
    }
}

class TransactionBlockInfoView: UIView {
    
    // MARK: - Porperties (Lazy)
    
    public lazy var transactionIdTitleLab: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_light
        label.font = AppTheme.Font.text_small
        label.text = LocalizedString(key: "transaction.id.prefix", comment: "")
        return label
    }()
    
    public lazy var transactionIdLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.font = AppTheme.Font.text_small
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        return label
    }()
    
    public lazy var blockIdTitleLab: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_light
        label.font = AppTheme.Font.text_small
        label.text = LocalizedString(key: "transaction.block.prefix", comment: "")
        return label
    }()
    
    public lazy var blockIdLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.font = AppTheme.Font.text_small
        label.numberOfLines = 0
        return label
    }()
    
    public lazy var blockQRCodeImage: UIImageView = {
        let imageV = UIImageView()
        imageV.backgroundColor = AppTheme.Color.tableView_bg
        imageV.contentMode = .scaleToFill
        return imageV
    }()
    
    
    // MARK: - Life Cycles
    
    required init() {
        super.init(frame: .zero)
        self.configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.configureConstraints()
    }
    
    
    // MARK: - Configure
    
    internal func configureView() {
        
        backgroundColor = AppTheme.Color.page_common
        
        addSubViews([
        transactionIdTitleLab,
        transactionIdLabel,
        blockIdTitleLab,
        blockIdLabel,
        blockQRCodeImage,
        ])
    }
    
    internal func configureConstraints() {
        
        transactionIdTitleLab.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
        }
        transactionIdLabel.snp.makeConstraints { (make) in
            make.left.equalTo(transactionIdTitleLab)
            make.top.equalTo(transactionIdTitleLab.snp.bottom).offset(14)
            make.right.equalTo(blockQRCodeImage.snp.left).offset(-29)
        }
        
        blockIdTitleLab.snp.makeConstraints { (make) in
            make.left.right.equalTo(transactionIdLabel)
            make.top.equalTo(transactionIdLabel.snp.bottom).offset(20)
        }
        blockIdLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(blockIdTitleLab)
            make.top.equalTo(blockIdTitleLab.snp.bottom).offset(14)
            make.bottom.equalToSuperview()
        }
        
        blockQRCodeImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(0)
            make.size.equalTo(84)
        }
    }
    
    
    
}

class TransactionDetailView: UIView {
    
    // MARK: - Properties (Lazy)
    
    public lazy var statusIcon: UIImageView = {
        let iconV = UIImageView()
        iconV.layer.cornerRadius = 17.5
        iconV.layer.masksToBounds = true
        iconV.contentMode = .scaleToFill
        return iconV
    }()
    
    public lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.font = AppTheme.Font.text_normal.medium()
        label.textAlignment = .center
        return label
    }()
    
    public lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_light
        label.font = AppTheme.Font.text_smaller
        label.textAlignment = .center
        return label
    }()
    
    public lazy var baseInfoView: TransactionDetailBasicInfoView = {
        let infoView = TransactionDetailBasicInfoView()
        infoView.backgroundColor = AppTheme.Color.page_common
        return infoView
    }()
    
    public lazy var separatorView: BrokenSeparatorView = {
        return BrokenSeparatorView()
    }()
    
    public lazy var blockInfoView: TransactionBlockInfoView = {
        return TransactionBlockInfoView()
    }()
    
    
    // MARK: - Life Cycles

    required init() {
        super.init(frame: .zero)
        self.configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.configureConstraints()
    }
    
    
    // MARK: - Configure
    
    internal func configureView() {
        backgroundColor = AppTheme.Color.page_common
        addSubViews([
        statusIcon,
        statusLabel,
        dateLabel,
        baseInfoView,
        separatorView,
        blockInfoView,
        ])
    }
    
    internal func configureConstraints() {
        statusIcon.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.size.equalTo(35)
            make.top.equalTo(22)
        }
        statusLabel.snp.makeConstraints { (make) in
            make.top.equalTo(statusIcon.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        dateLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(statusLabel.snp.bottom).offset(14)
        }
        baseInfoView.snp.makeConstraints { (make) in
            make.top.equalTo(dateLabel.snp.bottom).offset(29)
            make.left.equalTo(30)
            make.right.equalTo(-52)
        }
        separatorView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.height.equalTo(34)
            make.top.equalTo(baseInfoView.snp.bottom).offset(10)
        }
        blockInfoView.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.top.equalTo(separatorView.snp.bottom).offset(30)
            make.bottom.equalToSuperview().offset(-50)
        }
    }
    
    func configure(model: Transaction) {
        switch model.status {
        case .success:
            statusIcon.image = UIImage(named: "transaction_status_success")
            statusLabel.text = LocalizedString(key: "transaction.status.success", comment: "")
        case .failure:
            statusIcon.image = UIImage(named: "transaction_status_failure")
            statusLabel.text = LocalizedString(key: "transaction.status.fail", comment: "")
        case .proccessing:
            statusIcon.image = UIImage(named: "transaction_status_proccess")
            statusLabel.text = LocalizedString(key: "transaction.status.packaging", comment: "")
        }
        dateLabel.text = model.date
        var titles = [
            LocalizedString(key: "transaction.amount.prefix", comment: ""),
            LocalizedString(key: "transaction.fee.prefix", comment: ""),
            LocalizedString(key: "transaction.direction.prefix", comment: ""),
            LocalizedString(key: "transaction.label.prefix", comment: ""),
            "Payment ID:",
        ]
        var strs = [
            Helper.displayDigitsAmount(model.amount),
            Helper.displayDigitsAmount(model.fee),
            "",
            model.label,
            model.paymentId,
        ]
        switch model.type {
        case .in:
            strs[2] = LocalizedString(key: "receive", comment: "")
        case .out:
            strs[2] = LocalizedString(key: "send", comment: "")
            titles.remove(at: 3)
            strs.remove(at: 3)
        default:
            break
        }
        baseInfoView.configureTitles(strs: titles)
        baseInfoView.configureContents(strs: strs)
        blockInfoView.transactionIdLabel.text = model.hash
        blockInfoView.blockIdLabel.text = model.block
        DispatchQueue.global().async {
            Helper.generateQRCode(content: model.hash, icon: nil, result: { (img) in
                DispatchQueue.main.async {
                    self.blockInfoView.blockQRCodeImage.image = img
                }
            })
        }
    }
    
    func test() {
        
    }

}
