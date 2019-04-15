//
//  SafetyRankView.swift


import UIKit

class RankView: UIStackView {
    
    // MARK: - Properties (Public)
    
    public var level: Int = 0 {
        didSet {
            updateColorsLevel()
        }
    }
    

    // MARK: - Properties (Private)
    
    private let max: Int
    
    
    // MARK: - Life Cycles
    
    required init(max: Int) {
        self.max = max
        super.init(frame: .zero)
        self.configureUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        stride(from: 0, to: max, by: 1).forEach { (index) in
            let sub = UIView()
            sub.backgroundColor = AppTheme.Color.cell_line
            addArrangedSubview(sub)
        }
        self.axis = .vertical
        self.alignment = .fill
        self.distribution = .fillEqually
        self.spacing = 4
        self.layoutIfNeeded()
    }
    
    private func updateColorsLevel() {
        let min = max - level
        stride(from: 0, to: arrangedSubviews.count, by: 1).forEach { (index) in
            arrangedSubviews[index].backgroundColor = index >= min ? AppTheme.Color.main_green_light : AppTheme.Color.cell_line
        }
    }
    
}
