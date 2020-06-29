//
//  DispatchQueuePool.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/4/28.
//  Copyright © 2020 Wookey. All rights reserved.
//

import UIKit

class DispatchQueuePool: NSObject {
    
    typealias DispatchQueueCaches = [String: DispatchQueue]
    
    
    // MARK: - Properties (static)
    
    static let shared = DispatchQueuePool()
    
    
    // MARK: - Properties (private set)
    
    private(set) var queue_caches: DispatchQueueCaches {
        get { return _queue_caches }
        set {
            dispatch_lock.lock(); defer { dispatch_lock.unlock() }
            _queue_caches = newValue
        }
    }
    
    
    // MARK: - Properties (private)
    
    private lazy var dispatch_lock = NSLock()
    private var _queue_caches = DispatchQueueCaches()
    
    
    // MARK: - Methods (public)
    
    subscript(_ label: String, attributes: DispatchQueue.Attributes = []) -> DispatchQueue {
        var queue = queue_caches[label]
        if queue == nil {
            let name = AppInfo.bundleIdentifier + "-" + label
            queue = DispatchQueue(label: name, qos: .default, attributes: attributes, autoreleaseFrequency: .workItem)
            queue_caches[label] = queue
        }
        return queue!
    }
    
}
