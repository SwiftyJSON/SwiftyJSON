//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//


#if os(Linux)

import Foundation

// Support protocols for casting

// slated for removal, these are the swift-corelibs-only variant of the _ObjectiveCBridgeable
internal protocol _CFBridgeable {
    associatedtype CFType
    var _cfObject: CFType { get }
}

internal protocol _SwiftBridgeable {
    associatedtype SwiftType
    var _swiftObject: SwiftType { get }
}

internal protocol _NSBridgeable {
    associatedtype NSType
    var _nsObject: NSType { get }
}


/// - Note: This is an internal boxing value for containing abstract structures
internal final class _SwiftValue : NSObject, NSCopying {
    internal private(set) var value: Any
    
    static func fetch(_ object: AnyObject?) -> Any? {
        if let obj = object {
            return fetch(obj)
        }
        return nil
    }
    
    static func fetch(_ object: AnyObject) -> Any {
        if let container = object as? _SwiftValue {
            return container.value
        } else if let val = object as? _StructBridgeable {
            return val._bridgeToAny()
        } else {
            return object
        }
    }
    
    static func store(_ value: Any?) -> NSObject? {
        if let val = value {
            return store(val)
        }
        return nil
    }
    
    static func store(_ value: Any) -> NSObject {
        if let val = value as? NSObject {
            return val
        } else if let val = value as? _ObjectBridgeable {
            return val._bridgeToAnyObject() as! NSObject
        } else {
            return _SwiftValue(value)
        }
    }
    
    init(_ value: Any) {
        self.value = value
    }
    
    override var hash: Int {
        if let hashable = value as? AnyHashable {
            return hashable.hashValue
        }
        return ObjectIdentifier(self).hashValue
    }
    
    override func isEqual(_ value: Any?) -> Bool {
        if let other = value as? _SwiftValue {
            if self === other {
                return true
            }
            if let otherHashable = other.value as? AnyHashable,
               let hashable = self.value as? AnyHashable {
                return otherHashable == hashable
            }
            
        } else if let otherHashable = value as? AnyHashable,
                  let hashable = self.value as? AnyHashable {
            return otherHashable == hashable
        }
        return false
    }
    
    public func copy(with zone: NSZone?) -> Any {
        return _SwiftValue(value)
    }
}

#endif
