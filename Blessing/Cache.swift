//
//  Cache.swift
//  Blessing
//
//  Created by k on 02/11/2016.
//  Copyright © 2016 egg. All rights reserved.
//

import Foundation

// Thread unsafe

class Cache<T: RecordType> {
    
    var caches: [String: T] = [:]

    private var queue = DispatchQueue(label: "com.xspyhack.blessing.cacheQueue", attributes: .concurrent)

    /*
    func get(for key: String) -> T? {

        guard let record = caches[key] else {
            return nil
        }

        if record.isExpired {
            caches.removeValue(forKey: key)
            return nil
        }

        return record
    }
    */
    
    func get(for key: String) -> T? {
        
        var result: T? = nil
        
        queue.sync {
            result = caches[key] as? T
        }
        
        guard let record = result else {
            return nil
        }
        
        if record.isExpired {
            caches.removeValue(forKey: key)
            return nil
        }
        
        return record
    }

    /*
    func set(_ value: T, for key: String) {
        if let _ = caches[key] {
            caches.updateValue(value, forKey: key)
        } else {
            caches[key] = value
        }
    }
    */
    
    func set(_ value: T, for key: String) {
        queue.async(flags: .barrier) {
            if let _ = self.caches[key] {
                self.caches.updateValue(value, forKey: key)
            } else {
                self.caches[key] = value
            }
        }
    }

    func clean() {
        caches.removeAll()
    }

    func remove(for key: String) -> T? {
        return caches.removeValue(forKey: key)
    }
}

/* 
// LRU

struct Cache<T: RecordType> {

    let limit: Int = 10
    var caches: [String: Element<T>]
    var table: [Element<T>]

    mutating func get(for key: String) -> T? {

        guard let item = caches[key] else {
            return nil
        }

        if item.value.isExpired {
            caches.removeValue(forKey: key)
            table.remove(item)
            return nil
        }

        table.remove(item)
        table.insert(item, at: 0)

        return item.value
    }

    mutating func set(_ value: T, for key: String) {
        // old
        if var old = caches[key] {
            old.value = value
            table.remove(old)
            table.insert(old, at: 0)
            return
        } else if table.count == limit {
            // remove last
            let old = table.removeLast()
            caches.removeValue(forKey: old.key)
        }

        let new = Element(value: value, key: key)
        caches[key] = new
        table.insert(new, at: 0)
    }
}

struct Element<T: RecordType>: Equatable {

    var value: T
    var key: String
}

func ==<T>(lhs: Element<T>, rhs: Element<T>) -> Bool {
    return lhs.key == rhs.key
}

extension Array where Element: Equatable {

    // remove element
    mutating func remove(_ element: Element) {
        if let index = index(of: element) {
            remove(at: index)
        }
    }
}
*/
