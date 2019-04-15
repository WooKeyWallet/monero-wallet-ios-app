//
//  BaseButton.swift


import UIKit

class BaseButton: UIButton {

    private enum SubControl: Int {
        case imageView
        case label
    }
    
    // MARK: - TitleImagePostion
    
    public enum ImageTitlePostion {
        case leftRight(padding: CGFloat)
        case rightLeft(padding: CGFloat)
        case upDown(padding: CGFloat)
        case downUp(padding: CGFloat)
    }
    
    // MARK: - Properties (Public)
    
    public var flexMiddleSpace: Bool = false
    public var imageTitlePostion: ImageTitlePostion = .rightLeft(padding: 0)
    public var titleCenterYOffset: CGFloat = 0
    public var imageCenterYOffset: CGFloat = 0
    public var contentHorizontalOffset: CGFloat = 0
    public var fitWidth: CGFloat {
        return imageView?.frame.maxX ?? 0
    }
    public var isTransformed: Bool {
        return transformedControls.count > 0
    }
    
    
    // MARK: - Properties (Private)
    
    private var transformedControls = [SubControl]()
    
    
    // MARK: - Life Cycles
    
    public init(frame: CGRect, imageTitlePostion: ImageTitlePostion) {
        super.init(frame: frame)
        self.imageTitlePostion = imageTitlePostion
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self._layout()
    }
    
    private func _layout() {
        var titleLabelFrame = self.titleLabel?.frame ?? .zero
        var imageViewFrame = self.imageView?.frame ?? .zero
        if flexMiddleSpace {
            titleLabelFrame.origin.x = 0
            imageViewFrame.origin.x = bounds.size.width - imageViewFrame.width
            self.titleLabel?.frame = titleLabelFrame
            self.imageView?.frame = imageViewFrame
            return
        }
        switch imageTitlePostion {
        case .leftRight(let padding):
            var X = bounds.size.width/2 - (titleLabelFrame.size.width + imageViewFrame.size.width + padding)/2
            if contentHorizontalAlignment == .left {
                X = 0 + contentHorizontalOffset
            } else if contentHorizontalAlignment == .right {
                X = bounds.size.width - (titleLabelFrame.size.width + imageViewFrame.size.width + padding) + contentHorizontalOffset
            }
            imageViewFrame.origin.x = X
            titleLabelFrame.origin.x = imageViewFrame.maxX + padding
            titleLabelFrame.origin.y = titleCenterYOffset + bounds.size.height/2 - titleLabelFrame.size.height/2
            imageViewFrame.origin.y = imageCenterYOffset + bounds.size.height/2 - imageViewFrame.size.height/2
        case .rightLeft(let padding):
            var X = bounds.size.width/2 - (titleLabelFrame.size.width + imageViewFrame.size.width + padding)/2
            if contentHorizontalAlignment == .left {
                X = 0 + contentHorizontalOffset
            } else if contentHorizontalAlignment == .right {
                X = bounds.size.width - (titleLabelFrame.size.width + imageViewFrame.size.width + padding) + contentHorizontalOffset
            }
            titleLabelFrame.origin.x = X
            imageViewFrame.origin.x = titleLabelFrame.maxX + padding
            titleLabelFrame.origin.y = titleCenterYOffset + bounds.size.height/2 - titleLabelFrame.size.height/2
            imageViewFrame.origin.y = imageCenterYOffset + bounds.size.height/2 - imageViewFrame.size.height/2
        case .upDown(let padding):
            let Y = bounds.size.height/2 - (titleLabelFrame.size.height + imageViewFrame.size.height + padding)/2
            titleLabelFrame.origin.y = Y
            imageViewFrame.origin.y = titleLabelFrame.maxY + padding
            titleLabelFrame.origin.x = titleCenterYOffset + bounds.size.width/2 - titleLabelFrame.size.width/2
            imageViewFrame.origin.x = imageCenterYOffset + bounds.size.width/2 - imageViewFrame.size.width/2
        case .downUp(let padding):
            let Y = bounds.size.height/2 - (titleLabelFrame.size.height + imageViewFrame.size.height + padding)/2
            imageViewFrame.origin.y = Y
            titleLabelFrame.origin.y = imageViewFrame.maxY + padding
            titleLabelFrame.origin.x = titleCenterYOffset + bounds.size.width/2 - titleLabelFrame.size.width/2
            imageViewFrame.origin.x = imageCenterYOffset + bounds.size.width/2 - imageViewFrame.size.width/2
        }
        self.titleLabel?.frame = titleLabelFrame
        self.imageView?.frame = imageViewFrame
    }
    
}
