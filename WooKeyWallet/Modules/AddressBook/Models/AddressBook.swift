//
//  AddressBook.swift


import UIKit

struct AddressBook {
    var tokenIcon: UIImage?
    var label: String = ""
    var tokenAddress: String = ""
    
    init(_ address: Address) {
        tokenIcon = UIImage(named: "token_icon_\(address.symbol)")
        label = address.notes
        tokenAddress = address.address
    }
}

