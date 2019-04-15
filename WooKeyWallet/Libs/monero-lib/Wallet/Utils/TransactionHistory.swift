//
//  TransactionHistory.swift
//

import Foundation


public struct TransactionItem {

    public var direction: TransactionDirection
    public var isPending: Bool
    public var isFailed: Bool
    public let amount: String
    public let networkFee: String
    public let timestamp: UInt64
    public let confirmations: UInt64
    public let paymentId: String
    public let hash: String
    public let label: String
    public let blockHeight: UInt64
    
    public init(direction: TransactionDirection,
                isPending: Bool,
                isFailed: Bool,
                amount: UInt64,
                networkFee: UInt64,
                timestamp: UInt64,
                paymentId: String,
                hash: String,
                label: String,
                blockHeight: UInt64,
                confirmations: UInt64)
    {
        self.direction = direction
        self.isPending = isPending
        self.isFailed = isFailed
        self.amount = xmr_displayAmount(amount)
        self.networkFee = xmr_displayAmount(networkFee)
        self.timestamp = timestamp
        self.confirmations = confirmations
        self.paymentId = paymentId
        self.hash = hash
        self.label = label
        self.blockHeight = blockHeight
    }
    
//    public func readableAmountWithNetworkFee() -> String {
//        var totalInAtomicUnits: UInt64
//        if self.isPending {
//            // as long as trx is pending the amount contains the network fee
//            totalInAtomicUnits = xmr_displayAmount(self.amount)
//        } else {
//            // when no longer pending then the total amount spent is the sum of amount and network fee
//            totalInAtomicUnits = xmr_displayAmount(self.amount + self.networkFee)
//        }
//
//        let floatAmount: Double = Double(totalInAtomicUnits) / 1e12
//        return String(format: "%0.05f", floatAmount)
//    }
//
//    private func readableAmount() -> String {
//        let floatAmount: Double = Double(self.amount) / 1e12
//        return String(format: "%0.05f", floatAmount)
//    }
//
//    private func readableNetworkFee() -> String {
//        let floatNetworkFee: Double = Double(self.networkFee) / 1e12
//        return String(format: "%0.05f", floatNetworkFee)
//    }
//    
//    public func readableTimestamp() -> String {
//        let date = Date(timeIntervalSince1970: Double(timestamp))
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = NSLocale.current
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
//        return dateFormatter.string(from: date)
//    }
    
//    public func toString() -> String {
//        var result = ""
//        result.append("\(self.readableTimestamp())\t")
//        result.append("\(self.readableAmountWithNetworkFee())\t")
//        result.append("\(self.readableAmount())\t")
//        result.append("\(self.readableNetworkFee())\t")
//        result.append("\(self.direction)\t")
//        result.append("confirmations: \(self.confirmations)\t")
//        result.append("pending:\(self.isPending)\t")
//        result.append("failed:\(self.isFailed)\t")
//        return result
//    }
}


public class TransactionHistory {
    
    public var all: [TransactionItem]
    
    public init() {
        self.all = [TransactionItem]()
    }
    
//    public func toString() -> String {
//        var result = "\n\t\t"
//        
//        for transactionItem in all {
//            result.append(transactionItem.toString())
//            result.append("\n\t\t")
//        }
//        
//        return result
//    }
}
