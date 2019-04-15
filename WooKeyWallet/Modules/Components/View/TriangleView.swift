//
//  TriangleView.swift


import UIKit

class TriangleView: UIView {

    enum Style: Int {
        case up
        case right
        case down
        case left
    }
    
    
    // MARK: - Properties
    
    private let color: UIColor
    private let style: Style
    
    private var start: CGPoint = .zero
    private var move: CGPoint = .zero
    private var end: CGPoint = .zero
    
    
    
    // MARK: - Life Cycles
    
    required init(color: UIColor, style: Style) {
        self.color = color
        self.style = style
        super.init(frame: .zero)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.resetPoints()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.beginPath()
        context.move(to: start)
        context.addLine(to: move)
        context.addLine(to: end)
        context.closePath()
        
        color.setFill()
        color.setStroke()
        
        context.drawPath(using: .fillStroke)
        context.closePath()
    }
    
    
    // MARK: - Methods (Private)
    
    private func resetPoints() {
        switch style {
        case .up:
            start = CGPoint(x: 0, y: height)
            move = CGPoint(x: width * 0.5, y: 0)
            end = CGPoint(x: width, y: height)
        case .left:
            start = CGPoint(x: width, y: 0)
            move = CGPoint(x: width, y: height)
            end = CGPoint(x: 0, y: height * 0.5)
        case .right:
            start = CGPoint(x: 0, y: 0)
            move = CGPoint(x: width, y: height * 0.5)
            end = CGPoint(x: 0, y: height)
        case .down:
            start = CGPoint(x: 0, y: 0)
            move = CGPoint(x: width, y: 0)
            end = CGPoint(x: width * 0.5, y: height * 0.5)
        }
    }
    
}
