//
//  Postable.swift
//  Wookey
//
//  Created by Wookey on 2019/3/12.
//  Copyright © 2019 Wookey. All rights reserved.
//

import Foundation

class Postable<T> {
    
    typealias Value = T
    typealias EventHandler = (Value) -> Bool
    
    fileprivate var observerToHandler = [EventHandler]()
    fileprivate var observerList = [Observer<Value>]()
    
    func observe<O: NSObject>(_ on: O, eventHandler: ((Value, O) -> Void)?) {
        guard let eventHandler = eventHandler else { return }
        let handler: EventHandler = {
            [weak on] (v: Value) -> Bool in
            if let strongOn = on {
                eventHandler(v, strongOn)
                return true
            }
            return false
        }
        observerToHandler.append(handler)
    }
    
    func bindTo(_ observer: Observer<Value>) {
        self.observerList.append(observer)
    }
    
    func newState(_ state: Value) {
        var pool = [EventHandler]()
        observerToHandler.forEach { (handler) in
            if handler(state) {
                pool.append(handler)
            }
        }
        observerToHandler = pool
    }
    
}
