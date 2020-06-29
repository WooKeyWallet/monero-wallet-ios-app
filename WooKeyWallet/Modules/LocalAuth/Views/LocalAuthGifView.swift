//
//  LocalAuthGifView.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/5/18.
//  Copyright © 2020 Wookey. All rights reserved.
//

import UIKit

class LocalAuthGifView: UIView {
    
    // MARK: - Properties (public)
    
    public var isSelected: Bool = false {
        didSet {
            guard oldValue != isSelected else {
                return
            }
            if isSelected {
                selectIcon.image = UIImage(named: "localAuth_option_selected")
                if let data = gifData {
                    imageView.prepareForAnimation(withGIFData: data)
                    imageView.startAnimatingGIF()
                }
            } else {
                selectIcon.image = UIImage(named: "localAuth_option_normal")
                imageView.prepareForReuse()
                imageView.image = defaultImage
            }
        }
    }
    
    public var text: String? {
        didSet {
            label.text = text
        }
    }
    

    // MARK: - Properties (private)
    
    private let defaultImage: UIImage?
    private let gifData: Data?
    
    private lazy var imageView: WKImageView = {
        let gif = WKImageView()
        return gif
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.textAlignment = .center
        label.font = AppTheme.Font.text_smaller
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var selectIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "localAuth_option_normal")
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    
    // MARK: - Life Cycles
    
    init(image: UIImage?, gif: URL?) {
        self.defaultImage = image
        self.gifData = gif == nil ? nil : try? Data(contentsOf: gif!)
        super.init(frame: .zero)
        self.imageView.image = image
        self.addSubViews([imageView, label, selectIcon])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.updateFrame(CGRect(origin: .zero, size: CGSize(width: width, height: height - 77)))
        label.updateFrame(CGRect(x: 0, y: imageView.maxY, width: width, height: 55))
        selectIcon.updateFrame(CGRect(x: width * 0.5 - 11, y: label.maxY, width: 22, height: 22))
    }
    
}
