//
//  NSExtension.swift
//  SwiftyJSON
//
//  Created by Daniel Firsht on 4/13/16.
//
//

import Foundation

#if os(Linux)
extension NSNumber {
    convenience init(value: Bool) {
        self.init(bool: value)
    }
    
    convenience init(value: Double) {
        self.init(double: value)
    }
    
    convenience init(value: Float) {
        self.init(float: value)
    }
    
    convenience init(value: Int) {
        self.init(integer: value)
    }
    
    convenience init(value: UInt) {
        self.init(unsignedLong: value)
    }
    
    convenience init(value: Int8) {
        self.init(char: value)
    }
    
    convenience init(value: UInt8) {
        self.init(unsignedChar: value)
    }
    
    convenience init(value: Int16) {
        self.init(short: value)
    }
    
    convenience init(value: UInt16) {
        self.init(unsignedShort: value)
    }
    
    convenience init(value: Int32) {
        self.init(int: value)
    }
    
    convenience init(value: UInt32) {
        self.init(unsignedInt: value)
    }
    
    convenience init(value: Int64) {
        self.init(longLong: value)
    }
    
    convenience init(value: UInt64) {
        self.init(unsignedLongLong: value)
    }
    
    var intValue:Int {return self.longValue}
    
    var uintValue:UInt {return self.unsignedLongValue}
    
    var int8Value:Int8 {return self.charValue}
    
    var uint8Value:UInt8 {return self.unsignedCharValue}
    
    var int16Value:Int16 {return self.shortValue}
    
    var uint16Value:UInt16 {return self.unsignedShortValue}
    
    var int32Value:Int32 {return self.intValue}
    
    var uint32Value:UInt32 {return self.unsignedIntValue}
    
    var int64Value:Int64 {return self.longLongValue}
    
    var uint64Value:UInt64 {return self.unsignedLongLongValue}
}
#endif