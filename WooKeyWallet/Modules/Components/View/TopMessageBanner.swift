//
//  TopMessageBanner.swift


import UIKit

class TopMessageBanner: UIView {
    
    // MARK: - Properties
    
    private let messages: [String]
    
    
    // MARK: - Life Cycles
    
    required init(messages: [String]) {
        self.messages = messages
        super.init(frame: .zero)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        /// Self
        self.backgroundColor = AppTheme.Color.main_green_light
        
        /// initSubViews
        do {
            var messageLabelArray = [UILabel]()
            stride(from: 0, to: messages.count, by: 1).forEach { (index) in
                let dotV = UIView()
                dotV.backgroundColor = AppTheme.Color.page_common
                dotV.layer.cornerRadius = 3
                self.addSubview(dotV)
                let messageLabel = UILabel()
                messageLabel.text = messages[index]
                messageLabel.textColor = AppTheme.Color.page_common
                messageLabel.font = AppTheme.Font.text_smaller
                messageLabel.numberOfLines = 0
                messageLabel.lineBreakMode = .byWordWrapping
                self.addSubview(messageLabel)
                messageLabelArray.append(messageLabel)
                
                dotV.snp.makeConstraints({ (make) in
                    make.right.equalTo(messageLabel.snp.left).offset(-7)
                    make.top.equalTo(messageLabel.snp.top).offset(4)
                    make.size.equalTo(CGSize(width: 6, height: 6))
                })
                messageLabel.snp.makeConstraints({ (make) in
                    make.left.equalToSuperview().offset(38)
                    make.right.equalToSuperview().offset(-26)
                    if index == 0 {
                        make.top.equalToSuperview().offset(15)
                        if messages.count == 1 {
                            make.bottom.equalToSuperview().offset(-15)
                        }
                    } else {
                        make.top.equalTo(messageLabelArray[index-1].snp.bottom).offset(5)
                        if index == messages.count - 1 {
                            make.bottom.equalToSuperview().offset(-15)
                        }
                    }
                })
            }
        }
    }
    
}
