//
//  WordListView.swift


import UIKit

class WordsLabel: UILabel {
    
    public let indexLabel: UILabel
    
    private lazy var tapGes: UITapGestureRecognizer = {
        return UITapGestureRecognizer()
    }()
    
    required init() {
        self.indexLabel = UILabel()
        super.init(frame: .zero)
        
        self.textColor = AppTheme.Color.text_dark
        self.font = AppTheme.Font.text_smaller.medium()
        self.textAlignment = .center
        self.backgroundColor = AppTheme.Color.words_bg
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.numberOfLines = 2
        self.isUserInteractionEnabled = true
        
        indexLabel.textColor = AppTheme.Color.text_light
        indexLabel.font = AppTheme.Font.text_smallest
        addSubview(indexLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTarget(_ target: Any, action: Selector) {
        tapGes.addTarget(target, action: action)
        self.addGestureRecognizer(tapGes)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        indexLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(6)
            make.top.equalToSuperview().offset(3)
        }
    }
}

class WordListView: UIView {

    // MARK: - Properties (Public)
    
    /// items of space
    public var xSpace: CGFloat = 1
    public var ySpace: CGFloat = 1
    
    public var title: String = "" {
        didSet {
            titleLab.text = title
        }
    }
    public var indexTextColor: UIColor = AppTheme.Color.text_light
    
    // MARK: - Properties (Private)
    
    internal var arrangedSubviews = [WordsLabel]()
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var titleLab: UILabel = {
        let label = UILabel()
        label.text = title
        label.textColor = AppTheme.Color.text_dark
        label.textAlignment = .center
        label.font = AppTheme.Font.text_normal.medium()
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
            make.top.equalTo(titleLab.snp.bottom).offset(20)
            make.left.right.bottom.equalToSuperview()
            
        }
    }
    
    
    
    
    // MARK: - Methods (Public)
    
    public func addArrangedSubviews(_ view: WordsLabel) {
        view.indexLabel.textColor = indexTextColor
        arrangedSubviews.append(view)
        wordsContent.addSubview(view)
    }
    
    public func insertArrangedSubviews(_ view: WordsLabel, at: Int) {
        guard at <= arrangedSubviews.count else {
            return
        }
        view.indexLabel.textColor = indexTextColor
        arrangedSubviews.insert(view, at: at)
        wordsContent.insertSubview(view, at: at)
    }
    
    public func removeArrangedSubviews(_ view: WordsLabel) {
        guard let index = arrangedSubviews.index(of: view) else {
            return
        }
        arrangedSubviews.remove(at: index).removeFromSuperview()
    }
    
    public func configure(_ wordList: [String]) {
        
        let leftCount = self.arrangedSubviews.count - wordList.count
        if leftCount > 0 {
            (0..<leftCount).forEach({ _ in removeArrangedSubviews(arrangedSubviews.last!) })
        } else if leftCount < 0 {
            let count = abs(leftCount)
            (0..<count).forEach({ _ in addArrangedSubviews(WordsLabel()) })
        }
        
        /// update value and frame
        setNeedsLayout()
        layoutIfNeeded()
        
        let itemW = (width - xSpace * 2) / 3
        let itemH = CGFloat(36)
        stride(from: 0, to: wordList.count, by: 1).forEach { (index) in
            let sub = arrangedSubviews[index]
            sub.text = wordList[index]
            sub.indexLabel.text = String(index + 1)
            sub.tag = index
            
            let row = CGFloat(index / 3)
            let col = CGFloat(index % 3)
            sub.updateFrame(CGRect(x: col * (itemW + xSpace), y: row * (itemH + ySpace), width: itemW, height: itemH))
        }
        let h = arrangedSubviews.last?.maxY ?? 50
        wordsContent.heightAnchor.constraint(equalToConstant: h).isActive = true
    }
    
    public func configure() {
        
    }

}

class VerifyWordsView: WordListView {
    
    var clickToRemove: ((Int) -> Void)?
    
    
    func configure(_ wordList: [String], indexs: [Int]) {
        super.configure(wordList)
        var count = indexs.count
        if indexs.count > wordList.count {
            count = wordList.count
        }
        stride(from: 0, to: count, by: 1).forEach { (i) in
            let sub = arrangedSubviews[i]
            sub.indexLabel.text = String(indexs[i])
            sub.addTarget(self, action: #selector(self.clickWords(_:)))
        }
        
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func clickWords(_ sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else { return }
        arrangedSubviews[tag].text = ""
        clickToRemove?(tag)
    }
}



