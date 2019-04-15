//
//  SeedWordsView.swift


import UIKit

class SeedWordsView: UIView {

    // MARK: - Properties (Public)
    
    /// items of space
    public var xSpace: CGFloat = 12
    public var ySpace: CGFloat = 12
    
    public var wordTextInserts: UIEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
    
    
    // MARK: - Properties (Private)
    
    private var arrangedSubviews = [UIButton]()
    
    private var tapedButtonTags = [Int: Int]()
    
    private var tapActionDoing: ((String) -> Int?)?
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var titleLab: UILabel = {
        let label = UILabel()
        label.text = LocalizedString(key: "words.verify.seed.title", comment: "")
        label.textColor = AppTheme.Color.text_light
        label.textAlignment = .center
        label.font = AppTheme.Font.text_smaller
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var wordsContent: UIView = {
        return UIView()
    }()
    
    
    // MARK: - Life Cycles
    
    required init() {
        super.init(frame: .zero)
        configureUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        addSubViews([
            titleLab,
            wordsContent,
            ])
        wordsContent.translatesAutoresizingMaskIntoConstraints = false
        titleLab.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        wordsContent.snp.makeConstraints { (make) in
            make.top.equalTo(titleLab.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview()
            
        }
    }
    
    
    // MARK: - Methods (Public)
    
    public func addArrangedSubviews(_ view: UIButton) {
        view.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        view.setTitleColor(UIColor(hex: 0x505050), for: .normal)
        view.setTitleColor(AppTheme.Color.text_light_M, for: .disabled)
        view.backgroundColor = AppTheme.Color.tableView_bg
        view.setBackgroundImage(UIImage.colorImage(AppTheme.Color.tableView_bg, size: CGSize.init(width: 1, height: 1)), for: .normal)
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        arrangedSubviews.append(view)
        wordsContent.addSubview(view)
        view.addTarget(self, action: #selector(self.tapWordAction(_:)), for: .touchUpInside)
    }
    
    public func removeArrangedSubviews(_ view: UIButton) {
        guard let index = arrangedSubviews.index(of: view) else {
            return
        }
        arrangedSubviews.remove(at: index).removeFromSuperview()
    }
    
    public func configure(_ wordList: [String], tapDoing: ((String) -> Int?)?) {
        let leftCount = self.arrangedSubviews.count - wordList.count
        if leftCount > 0 {
            (0..<leftCount).forEach({ _ in removeArrangedSubviews(arrangedSubviews.last!) })
        } else if leftCount < 0 {
            let count = abs(leftCount)
            (0..<count).forEach({ _ in addArrangedSubviews(UIButton()) })
        }
        
        /// update value and frame
        setNeedsLayout()
        layoutIfNeeded()
        
        var lastFrame = CGRect.zero
        stride(from: 0, to: wordList.count, by: 1).forEach { (index) in
            let word = wordList[index]
            let sub = arrangedSubviews[index]
            sub.tag = index
            sub.setTitle(word, for: .normal)
            var textSize = word.attributeText([.font: sub.titleLabel!.font]).size()
            textSize.height = textSize.height + wordTextInserts.top + wordTextInserts.bottom
            textSize.width = min(textSize.width + wordTextInserts.left + wordTextInserts.right, width)
            if lastFrame.width == 0 {
                lastFrame = CGRect(x: 0, y: 0, width: textSize.width, height: textSize.height)
            } else {
                if lastFrame.maxX + xSpace + textSize.width > width {
                    lastFrame = CGRect(x: 0, y: lastFrame.maxY + ySpace, width: textSize.width, height: textSize.height)
                } else {
                    lastFrame = CGRect(x: lastFrame.maxX + xSpace, y: lastFrame.origin.y, width: textSize.width, height: textSize.height)
                }
            }
            sub.updateFrame(lastFrame)
            sub.isEnabled = true
        }
        let h = lastFrame.maxY
        wordsContent.heightAnchor.constraint(equalToConstant: h).isActive = true
        
        self.tapActionDoing = tapDoing
        self.tapedButtonTags = [:]
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func tapWordAction(_ sender: UIButton) {
        guard let action = tapActionDoing else { return }
        if let index = action(sender.titleLabel?.text ?? "") {
            sender.isEnabled = false
            self.tapedButtonTags[index] = sender.tag
        }
    }
    
    func cancelTap(at index: Int) {
        guard let tag = self.tapedButtonTags.removeValue(forKey: index) else { return }
        arrangedSubviews[tag].isEnabled = true
    }
    
    func cancelAllTaps() {
        self.tapedButtonTags.forEach { (key, value) in
            arrangedSubviews[value].isEnabled = true
        }
        self.tapedButtonTags = [:]
    }
    

}
