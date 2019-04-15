//
//  Observable.swift


import Foundation

class Observable<T> {
    
    typealias Value = T
    typealias EventHandler = (Value) -> Bool
    
    private var _value: Value
    public var value: Value {
        get { return _value }
        set {
            _value = newValue
            var pool = [EventHandler]()
            observerToHandler.forEach { (handler) in
                if handler(newValue) {
                    pool.append(handler)
                }
            }
            observerToHandler = pool
        }
    }
    
    fileprivate var observerToHandler = [EventHandler]()
    fileprivate var observerList = [Observer<Value>]()
    
    
    init(_ value: Value) {
        self._value = value
    }
    
    func observe<O: NSObject>(_ on: O, eventHandler: ((Value, O) -> Void)?) {
        observe(on, eventHandler: eventHandler, beforeHandler: nil, afterHandler: nil)
    }
    
    func observe<O: NSObject>(_ on: O, eventHandler: ((Value, O) -> Void)?, beforeHandler: ((O) -> Void)?) {
        observe(on, eventHandler: eventHandler, beforeHandler: beforeHandler, afterHandler: nil)
    }
    
    func observe<O: NSObject>(_ on: O, eventHandler: ((Value, O) -> Void)?, afterHandler: ((O) -> Void)?) {
        observe(on, eventHandler: eventHandler, beforeHandler: nil, afterHandler: afterHandler)
    }
    
    func observe<O: NSObject>(_ on: O, eventHandler: ((Value, O) -> Void)?, beforeHandler: ((O) -> Void)?, afterHandler: ((O) -> Void)?) {
        guard let eventHandler = eventHandler else { return }
        let handler: EventHandler = {
            [weak on] (v: Value) -> Bool in
            if let strongOn = on {
                beforeHandler?(strongOn)
                eventHandler(v, strongOn)
                afterHandler?(strongOn)
                return true
            }
            return false
        }
        if handler(_value) {
            observerToHandler.append(handler)
        }
    }
    
    func bindTo(_ observer: Observer<Value>) {
        self.observerList.append(observer)
    }
}
