//
//  MarketsViewModel.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/5/9.
//  Copyright © 2020 Wookey. All rights reserved.
//

import UIKit
import Alamofire

class MarketsViewModel: NSObject {

    public lazy var modalState = { Postable<UIViewController>() }()
    public lazy var xmrPriceTextState = { Postable<String>() }()
    public lazy var dataSourceState = { Postable<[TableViewSection]>() }()
    public lazy var loadingState = { Postable<Bool>() }()
    
    private let coinList = [
        "monero",
        "bitcoin",
        "litecoin",
        "eos",
        "ethereum",
    ]
    private let coin_map_symbol = [
        "monero": "xmr",
        "bitcoin": "btc",
        "litecoin": "ltc",
        "eos": "eos",
        "ethereum": "eth",
    ]
    private var currency = ""
    private var supported_vs_currencies = [String]()
    
    private var refreshDuration: TimeInterval = 60
    
    private var marketsDataRequest: DataRequest?
    
    public func configure() {
        fetchSupportedCurrencies()
        fetchMarketsData(true)
        reloadData([:])
    }
    
    public func toSwicthLegal() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: LocalizedString(key: "cancel", comment: ""), style: .cancel, handler: nil))
        supported_vs_currencies.forEach({ currency in
            alert.addAction(UIAlertAction(title: currency.uppercased(), style: .default, handler: { [unowned self] (_) in
                self.currency = currency
                self.fetchMarketsData(true)
            }))
        })
        modalState.newState(alert)
    }
    
    private func reloadData(_ json: [String: [String: Any]]) {
        let xmrAmount = json["monero"]?[currency] as? Double
        let xmrPriceText = "1 XMR ≈ " + (xmrAmount == nil ? "--" : String(xmrAmount!)) + " " + currency.uppercased()
        var rowList = [TableViewRow]()
        stride(from: 1, to: coinList.count, by: 1).forEach { (i) in
            let coin = coinList[i]
            let amount = json[coin]?[currency] as? Double
            let model = MarketsModel(coin: coin_map_symbol[coin] ?? "--", amount: amount, legal: currency, xmrAmount: xmrAmount)
            rowList.append(TableViewRow(model, cellType: MarketsViewCell.self, rowHeight: 0))
        }
        xmrPriceTextState.newState(xmrPriceText)
        dataSourceState.newState([TableViewSection(rowList)])
    }
    
    private func fetchSupportedCurrencies() {
        self.supported_vs_currencies = ["usd","cny","eur","aed","ars","aud","bdt","bhd","bmd","brl","cad","chf","clp","czk","dkk","gbp","hkd","huf","idr","ils","inr","krw","kwd","lkr","mmk","mxn","myr","nok","nzd","php","pkr","pln","rub","sar","sek","sgd","thb","try","twd","uah","vef","vnd","zar"]
        self.currency = supported_vs_currencies.first ?? "usd"
//        let request = SessionManager.default.request("https://api.coingecko.com/api/v3/simple/supported_vs_currencies")
//        request.responseJSON(queue: .main, options: .mutableLeaves) { [weak self] (resp) in
//            guard let SELF = self else { return }
//            switch resp.result {
//            case .failure(let error):
//                HUD.showError(error.localizedDescription)
//            case .success(let value):
//                SELF.supported_vs_currencies = value as? [String] ?? []
//            }
//        }
    }
    
    private func fetchMarketsData(_ showHUD: Bool = false) {
        if let req = marketsDataRequest {
            req.cancel()
        }
        if showHUD { loadingState.newState(true) }
        let startTime = CFAbsoluteTimeGetCurrent()
        let request = Session.default.request("https://api.coingecko.com/api/v3/simple/price?ids=\(coinList.joined(separator: ","))&vs_currencies=\(currency)")
        request.responseJSON(queue: .main, options: .mutableLeaves) { [weak self] (resp) in
            guard let SELF = self else { return }
            SELF.marketsDataRequest = nil
            if showHUD { SELF.loadingState.newState(false) }
            switch resp.result {
            case .failure(let error):
                HUD.showError(error.localizedDescription)
            case .success(let value):
                SELF.reloadData(value as? [String: [String: Any]] ?? [:])
            }
            let endTime = CFAbsoluteTimeGetCurrent()
            let requestDuration = endTime - startTime
            if requestDuration >= SELF.refreshDuration {
                SELF.fetchMarketsData()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + SELF.refreshDuration - requestDuration) {
                    guard let SELF = self else { return }
                    SELF.fetchMarketsData()
                }
            }
        }
        marketsDataRequest = request
    }
    
}
