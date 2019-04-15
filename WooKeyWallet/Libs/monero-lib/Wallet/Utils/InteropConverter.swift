//
//  InteropConverter.swift
//

import Foundation


public class InteropConverter {
    
    public static func convert<T>(data: UnsafePointer<T>, elementCount: Int) -> [T] {
        let buffer = data.withMemoryRebound(to: T.self, capacity: 1) {
            UnsafeBufferPointer(start: $0, count: elementCount)
        }
        return Array(buffer)
    }
}
