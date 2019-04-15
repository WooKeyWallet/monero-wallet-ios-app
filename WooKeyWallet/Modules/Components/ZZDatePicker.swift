//
//  ZZDatePicker.swift


import UIKit
import Foundation


open class ZZDatePicker: UIViewController {
    
    public struct Mode {
        public var date:Date = Date()
        public var maximumDate = Date()
        public var minimumDate:Date?
        public var backgroundColor:UIColor = .white
        public var datePickerMode:UIDatePicker.Mode = .date
        public var placeholder: String = ""
        public var toolBarTintColor: UIColor = AppTheme.Color.text_click
        public var lang: String = AppLanguage.manager.current.rawValue
    }
    
    // MARK: - Public Properties
    
    public var pickDone:((Date)->Void)?
    
    // MARK: - Private Properties
    
    private var date: Date!
    
    private var mode: Mode!
    
    
    // MARK: - Lazy Properties
    
    private lazy var box:UIView = { return UIView() }()
    
    
    // MARK: - Setup UI
    
    convenience init(mode:Mode) {
        self.init()
        self.mode = mode
        self.date = mode.date
        modalPresentationStyle = .overCurrentContext
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        show_animate()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Self
        view.backgroundColor = UIColor.init(white: 0.382, alpha: 0.2)
        
        // Box
        self.box.frame = CGRect(x: 0, y: view.bounds.size.height, width: view.bounds.size.width, height: 3 / 4 * view.bounds.size.width)
        self.box.backgroundColor = UIColor.clear
        view.addSubview(self.box)
        
        // Topline
        let line = UIView.init(frame: CGRect(x: 0, y: 0, width: box.bounds.size.width, height: 1/UIScreen.main.scale))
        line.backgroundColor = AppTheme.Color.cell_line
        box.addSubview(line)
        
        // ToolBar
        let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: line.frame.maxY, width: box.bounds.size.width, height: 44))
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        
        let cancelItem = UIBarButtonItem.init(title: LocalizedString(key: "cancel", comment: "取消"), style: .plain, target: self, action: #selector(self.clickcancel))
        let doneItem = UIBarButtonItem.init(title: LocalizedString(key: "done", comment: "完成"), style: .plain, target: self, action: #selector(self.clickdone))
        
        
        [cancelItem, doneItem].forEach({
            $0.setTitleTextAttributes([
                NSAttributedString.Key.foregroundColor: mode.toolBarTintColor,
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)
                ], for: .normal)
            var highlightedColor: UIColor
            let colorCompoents = mode.toolBarTintColor.cgColor.components ?? []
            if colorCompoents.count > 3 {
                highlightedColor = UIColor(red: colorCompoents[0], green: colorCompoents[1], blue: colorCompoents[2], alpha: colorCompoents[3] * 0.5)
            } else {
                highlightedColor = UIColor.lightText
            }
            $0.setTitleTextAttributes([
                NSAttributedString.Key.foregroundColor: highlightedColor,
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)
                ], for: .highlighted)
        })
        
        let placeholderItem = UIBarButtonItem.init(title: mode.placeholder, style: .plain, target: nil, action: nil)
        placeholderItem.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)
        ], for: .normal)
        placeholderItem.tintColor = UIColor.lightGray
        
        toolBar.items = [
            cancelItem,
            UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            placeholderItem,
            UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            doneItem,
        ]
        
        // Picker
        let datePicker = UIDatePicker.init()
        datePicker.frame = CGRect(x: 0, y: toolBar.frame.maxY, width: box.bounds.size.width, height: box.bounds.size.height-toolBar.bounds.size.height)
        datePicker.date = date
        datePicker.maximumDate = mode.maximumDate
        datePicker.minimumDate = mode.minimumDate
        datePicker.backgroundColor = mode.backgroundColor
        datePicker.datePickerMode = mode.datePickerMode
        datePicker.locale = Locale.init(identifier: mode.lang)
        box.addSubview(datePicker)
        datePicker.addTarget(self, action: #selector(ZZDatePicker.dateChanged(_:)), for: .valueChanged)
        
        box.addSubview(toolBar)
    }
    
    // MARK: - Methods
    
    open override func transition(from fromViewController: UIViewController, to toViewController: UIViewController, duration: TimeInterval, options: UIView.AnimationOptions = [], animations: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        fromViewController.definesPresentationContext = true
    }
    
    private func show_animate() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .curveLinear, animations: {
            self.box.frame.origin.y = self.view.bounds.size.height - self.box.bounds.size.height
        }) { (_) in
            
        }
    }
    
    private func dissmiss() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.3, options: .curveLinear, animations: {
            self.box.frame.origin.y = self.view.bounds.size.height
        }) { (_) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dissmiss()
    }
    
    @objc
    func dateChanged(_ picker:UIDatePicker) {
        self.date = picker.date
    }
    
    @objc
    func clickcancel() {
        dissmiss()
    }
    
    @objc
    func clickdone() {
        self.pickDone?(date)
        dissmiss()
    }
}
