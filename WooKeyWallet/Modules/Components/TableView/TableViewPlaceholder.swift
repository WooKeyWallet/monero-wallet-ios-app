//
//  TableViewPlaceholder.swift


import UIKit

class TableViewPlaceholder: UIView {

    enum State: Int {
        case withoutData
        case networkError
        case none
    }
    
    // MARK: - Properties (Public)
    
    public var state: State = .none {
        didSet {
            self.isHidden = state == .none
            
            topImageView.image = stateImages[state]
            descriptionLabel.text = stateDescriptions[state]
            
            if let btnTitle = stateButtonTitles[state] {
                bottomButton.setTitle(btnTitle, for: .normal)
                bottomButton.isHidden = false
            } else {
                bottomButton.isHidden = true
            }
        }
    }
    
    
    // MARK: - Properties (Private)
    
    private var stateImages = [State: UIImage]()
    private var stateDescriptions = [State: String]()
    private var stateButtonTitles = [State: String]()
    
    
    // MARK: - Properties (Lazy)
    
    lazy var topImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = AppTheme.Font.text_small
        descriptionLabel.textColor = AppTheme.Color.text_light
        descriptionLabel.numberOfLines = 0
        return descriptionLabel
    }()
    
    lazy var bottomButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(AppTheme.Color.button_title, for: .normal)
        button.titleLabel?.font = AppTheme.Font.text_normal
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        button.setBackgroundImage(UIImage.colorImage(AppTheme.Color.main_blue), for: .normal)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()
    
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI() {
        self.backgroundColor = AppTheme.Color.page_common
        self.addSubview(topImageView)
        self.addSubview(descriptionLabel)
        self.addSubview(bottomButton)
        
        topImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-50)
            make.centerX.equalToSuperview()
            make.width.equalTo(196)
            make.height.equalTo(139)
        }
        descriptionLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(200)
            make.top.equalTo(topImageView.snp.bottom).offset(20)
        }
        bottomButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(descriptionLabel.snp.bottom).offset(25)
            make.height.equalTo(50)
        }
        
        self.state = .none
    }
    
    
    // MARK: - Methods (Public)
    
    func setDescription(_ text: String, for state: State) {
        stateDescriptions[state] = text
    }
    
    func setImage(_ image: UIImage?, for state: State) {
        if let img = image {
            stateImages[state] = img
        }
    }
    
    func setButtonTitle(_ text: String, for state: State) {
        stateButtonTitles[state] = text
    }
    
}
