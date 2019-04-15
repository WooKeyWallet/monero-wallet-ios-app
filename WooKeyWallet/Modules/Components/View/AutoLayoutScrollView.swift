//
//  AutoLayoutScrollView.swift


import UIKit

class AutoLayoutScrollView: UIScrollView, UIGestureRecognizerDelegate {

    // MARK: - Properties
    
    public var isScrollOnlySelf = false
    
    public lazy var contentView: UIView = {
        return UIView()
    }()
    
    
    // MARK: - Life Cycles
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        frame = superview?.frame ?? .zero
        contentView.frame = bounds
        contentView.backgroundColor = backgroundColor
        contentSize = bounds.size
        addSubViews(contentView)
    }
    
    public func resizeContentLayout() {
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        var maxY: CGFloat = 0
        contentView.subviews.forEach({
            if $0.maxY > maxY {
                maxY = $0.maxY
            }
        })
        contentView.frame = CGRect(x: 0, y: 0, width: width, height: maxY + 30)
        contentSize.height = contentView.height
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !isScrollOnlySelf
    }

}
