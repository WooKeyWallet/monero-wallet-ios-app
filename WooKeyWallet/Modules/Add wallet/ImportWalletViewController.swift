//
//  ImportWalletViewController.swift


import UIKit


class ImportWalletViewController: BaseViewController {
    
    // MARK: - Properties (Private)
    
    private let viewModel: ImportWalletViewModel
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var pagesView: CAPSPageMenu = {
        let viewControllers = [ImportFromWordsController.init(viewModel: viewModel), ImportFromKeysController.init(viewModel: viewModel)]
        let _frame = view.frame.inset(by: UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height + 44, left: 0, bottom: 0, right: 0))
        return CAPSPageMenu.init(viewControllers: viewControllers, frame: _frame, pageMenuOptions: CAPSPageMenuOption.useMenuLikeSegmentedControlOptions())
    }()
    
    
    // MARK: - Life Cycles
    
    required init(viewModel: ImportWalletViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func configureUI() {
        super.configureUI()
        
        navigationItem.title = LocalizedString(key: "wallet.add.import", comment: "")
        
        pagesView.controllerScrollView.bounces = false
        view.addSubview(pagesView.view)
        
        pagesView.view.snp.makeConstraints { (make) in
            make.top.equalTo(44+UIApplication.shared.statusBarFrame.height)
            make.left.right.bottom.equalTo(0)
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        /// ViewModel -> View
        
        viewModel.showDatePickerState.observe(self) { (picker, strongSelf) in
            DispatchQueue.main.async {
                strongSelf.definesPresentationContext = true
                picker.modalPresentationStyle = .overCurrentContext
                strongSelf.present(picker, animated: false, completion: nil)
            }
        }
        
        viewModel.showAlertState.observe(self) { (alert, strongSelf) in
            DispatchQueue.main.async {
                strongSelf.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    // MARK: - Methods (Action)


}

