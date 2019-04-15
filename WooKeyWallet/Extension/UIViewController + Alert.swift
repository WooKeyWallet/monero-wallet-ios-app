//
//  ViewController+Alert.swift


import UIKit

public typealias AlertAction = ()->Void

extension UIViewController {
    
    func showAlert(_ title:String, message:String, cancelTitle:String, doneTitle:String? = nil, doneClousre: AlertAction? = nil) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: cancelTitle, style: .cancel, handler: nil))
        if let ok = doneTitle,let done = doneClousre {
            alert.addAction(UIAlertAction.init(title: ok, style: .default, handler: {
                _ in
                done()
            }))
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertCancel(_ title:String, message:String, cancelTitle:String, cancelClousre: AlertAction? = nil) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: cancelTitle, style: .cancel, handler: { ac in
            if let done = cancelClousre {
                done()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}
