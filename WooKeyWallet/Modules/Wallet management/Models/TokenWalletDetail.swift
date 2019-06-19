//
//  TokenWalletDetail.swift


import Foundation

struct TokenWalletDetail {
    var token: String = ""  // 币种
    var assets: String = "" // 资产
    var address: String = "" // 地址
}

typealias TokenWalletDetaillViewCellModel = (
    title: String,
    detail: String,
    showArrow: Bool
)
