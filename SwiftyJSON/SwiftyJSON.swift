//  JSON.swift
//
//  Copyright (c) 2014 Ruoyu Fu, Pinglin Tang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

//MARK:- Base
public enum JSON {
    
    case ScalarNumber(NSNumber)
    case ScalarString(String)
    case Sequence(Array<JSON>)
    case Mapping(Dictionary<String, JSON>)
    case Null(NSError?)
    
    public init(data:NSData, options opt: NSJSONReadingOptions = .AllowFragments, error: NSErrorPointer = nil) {
        if let object: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: opt, error: error){
            self = JSON(object: object)
        } else {
            self = .Null(nil)
        }
    }
    
    public init(object: AnyObject) {
        switch object {
        case let number as NSNumber:
            self = .ScalarNumber(number)
        case let string as NSString:
            self = .ScalarString(string)
        case let null as NSNull:
            self = .Null(nil)
        case let array as NSArray:
            var aJSONArray = Array<JSON>()
            for object : AnyObject in array {
                aJSONArray.append(JSON(object: object))
            }
            self = .Sequence(aJSONArray)
        case let dictionary as NSDictionary:
            var aJSONDictionary = Dictionary<String, JSON>()
            for (key : AnyObject, value : AnyObject) in dictionary {
                if let key = key as? NSString {
                    aJSONDictionary[key] = JSON(object: value)
                }
            }
            self = .Mapping(aJSONDictionary)
        case let null as NSNull:
            self = .Null(nil)
        default:
            self = .Null(NSError(domain: ErrorDomain, code: ErrorUnsupportedType, userInfo: [NSLocalizedDescriptionKey: "It is a unsupported type"]))
        }
    }
}

//MARK: - Return Error
public let ErrorDomain: String! = "SwiftyJSONErrorDomain"

public var ErrorUnsupportedType: Int { get { return 999 }}
public var ErrorIndexOutOfBounds: Int { get { return 900 }}
public var ErrorWrongType: Int { get { return 901 }}
public var ErrorNotExist: Int { get { return 500 }}

extension JSON {
    
    public var error: NSError? {
        get {
            switch self {
            case .Null(let error) where error != nil:
                return error
            default:
                return nil;
            }
        }
    }
    
}

//MARK:- Return the Raw object
extension JSON {
    
    public var object: AnyObject? {
        switch self {
        case .ScalarNumber(let number):
            return number
        case .ScalarString(let string):
            return string
        case .Null(let error) where error == nil:
            return NSNull()
        case .Sequence(let array):
            var retArray = [AnyObject]()
            for json in array {
                if let object: AnyObject = json.object {
                    retArray.append(object)
                }
            }
            return retArray
        case .Mapping(let dictionary):
            var retDicitonary = Dictionary<String, AnyObject>()
            for (key : String, value : JSON) in dictionary {
                if let object: AnyObject = value.object{
                    retDicitonary[key] = object
                }
            }
            return retDicitonary
        default:
            return nil
        }
    }
}

// MARK: - Subscript
extension JSON {
    
    public subscript(index: Int) -> JSON {
        get {
            switch self {
            case .Sequence(let array):
                if array.count > index {
                    return array[index]
                } else {
                    return .Null(NSError(domain: ErrorDomain, code:ErrorIndexOutOfBounds , userInfo: [NSLocalizedDescriptionKey: "Array[\(index)] is out of bounds"]))
                }
            default:
                return .Null(NSError(domain: ErrorDomain, code: ErrorWrongType, userInfo: [NSLocalizedDescriptionKey: "Wrong type, it is not an array"]))
            }
        }
    }
    
    public subscript(key: String) -> JSON {
        get {
            switch self {
            case .Mapping(let dictionary):
                if let value = dictionary[key] {
                    return dictionary[key]!
                } else {
                    return .Null(NSError(domain: ErrorDomain, code: ErrorNotExist, userInfo: [NSLocalizedDescriptionKey: "Dictionary[\"\(key)\"] does not exist"]))
                }
            default:
                return .Null(NSError(domain: ErrorDomain, code: ErrorWrongType, userInfo: [NSLocalizedDescriptionKey: "Wrong type, it is not an dictionary"]))
            }
        }
    }
}

//MARK: - Printable, DebugPrintable
extension JSON: Printable, DebugPrintable {
    
    public var description: String {
        switch self {
        case .ScalarNumber(let number):
            switch String.fromCString(number.objCType)! {
            case "c", "C":
                return number.boolValue.description
            default:
                return number.description
            }
        case .ScalarString(let string):
            return string
        case .Sequence(let array):
            return array.description
        case .Mapping(let dictionary):
            return dictionary.description
        case .Null(let error) where error != nil :
            return error!.description
        default:
            return "null"
        }
    }
    
    public var debugDescription: String {
        get {
            switch self {
            case .ScalarNumber(let number):
                switch String.fromCString(number.objCType)! {
                case "c", "C":
                    return number.boolValue.description
                default:
                    return number.debugDescription
                }
            case .ScalarString(let string):
                return string.debugDescription
            case .Sequence(let array):
                return array.debugDescription
            case .Mapping(let dictionary):
                return dictionary.debugDescription
            case .Null(let error) where error != nil :
                return error!.debugDescription
            default:
                return "null"
            }
        }
    }
}

// MARK: - Sequence: Array<JSON>
extension JSON {
    
    public var arrayValue: Array<JSON>? {
        get {
            switch self {
            case .Sequence(let array):
                return array
            default:
                return nil
            }
        }
    }
}

// MARK: - Mapping: Dictionary<String, JSON>
extension JSON {
    
    public var dictionaryValue: Dictionary<String, JSON>? {
        get {
            switch self {
            case .Mapping(let dictionary):
                return dictionary
            default:
                return nil
            }
        }
    }
}

//MARK: - Scalar: Bool
extension JSON: BooleanType {
    
    public var boolValue: Bool {
        switch self {
        case .ScalarNumber(let number):
            return number.boolValue
        case .ScalarString(let string):
            return (string as NSString).boolValue
        case .Sequence(let array):
            return array.count > 0
        case .Mapping(let dictionary):
            return dictionary.count > 0
        case .Null:
            return false
        default:
            return true
        }
    }
}

//MARK: - Scalar: String, NSNumber, NSURL, Int, ...
extension JSON {

    public var stringValue: String? {
        get {
            switch self {
            case .ScalarString(let string):
                return string
            case .ScalarNumber(let number):
                return number.stringValue
            default:
                return nil
            }
        }
    }

    public var numberValue: NSNumber? {
        get {
            switch self {
            case .ScalarString(let string):
                var ret: NSNumber? = nil
                let scanner = NSScanner(string: string)
                if scanner.scanDouble(nil){
                    if (scanner.atEnd) {
                        ret = NSNumber(double:(string as NSString).doubleValue)
                    }
                }
                return ret
            case .ScalarNumber(let number):
                return number
            default:
                return nil
            }
        }
    }

    public var URLValue: NSURL? {
        get {
            switch self {
            case .ScalarString(let string):
                if let encodedString = string.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
                    return NSURL(string: encodedString)
                } else {
                    return nil
                }
            default:
                return nil
            }
        }
    }

    public var charValue: Int8? {
        get {
            if let number = self.numberValue {
                return number.charValue
            } else {
                return nil
            }
        }
    }
    
    public var unsignedCharValue: UInt8? {
        get{
            if let number = self.numberValue {
                return number.unsignedCharValue
            } else {
                return nil
            }
        }
    }
    
    public var shortValue: Int16? {
        get{
            if let number = self.numberValue {
                return number.shortValue
            } else {
                return nil
            }
        }
    }
    
    public var unsignedShortValue: UInt16? {
        get{
            if let number = self.numberValue {
                return number.unsignedShortValue
            } else {
                return nil
            }
        }
    }
    
    public var longValue: Int? {
        get{
            if let number = self.numberValue {
                return number.longValue
            } else {
                return nil
            }
        }
    }
    
    public var unsignedLongValue: UInt? {
        get{
            if let number = self.numberValue {
                return number.unsignedLongValue
            } else {
                return nil
            }
        }
    }
    
    public var longLongValue: Int64? {
        get{
            if let number = self.numberValue {
                return number.longLongValue
            } else {
                return nil
            }
        }
    }
    
    public var unsignedLongLongValue: UInt64? {
        get{
            if let number = self.numberValue {
                return number.unsignedLongLongValue
            } else {
                return nil
            }
        }
    }
    
    public var floatValue: Float? {
        get {
            if let number = self.numberValue {
                return number.floatValue
            } else {
                return nil
            }
        }
    }
    
    public var doubleValue: Double? {
        get {
            if let number = self.numberValue {
                return number.doubleValue
            } else {
                return nil
            }
        }
    }

    public var integerValue: Int? {
        get {
            if let number = self.numberValue {
                return number.integerValue
            } else {
                return nil
            }
        }
    }
    
    public var unsignedIntegerValue: Int? {
        get {
            if let number = self.numberValue {
                return number.unsignedIntegerValue
            } else {
                return nil
            }
        }
    }
}

//MARK: - Comparable
extension JSON: Comparable {
    
   private var type: Int {
        get {
            switch self {
            case .ScalarNumber(let number):
                return 1
            case .ScalarString(let string):
                return 2
            case .Sequence(let array):
                return 3
            case .Mapping(let dictionary):
                return 4
            case .Null:
                return 0
            default:
                return -1
            }
        }
    }
}

public func ==(lhs: JSON, rhs: JSON) -> Bool {
    
    if lhs.numberValue != nil && rhs.numberValue != nil {
        return lhs.numberValue == rhs.numberValue
    }
    
    if lhs.type != rhs.type {
        return false
    }
    
    switch lhs {
    case JSON.ScalarNumber:
        return lhs.numberValue! == rhs.numberValue!
    case JSON.ScalarString:
        return lhs.stringValue! == rhs.stringValue!
    case .Sequence:
        return lhs.arrayValue! == rhs.arrayValue!
    case .Mapping:
        return lhs.dictionaryValue! == rhs.dictionaryValue!
    case .Null:
        return true
    default:
        return false
    }
}

public func <=(lhs: JSON, rhs: JSON) -> Bool {

    if lhs.numberValue != nil && rhs.numberValue != nil {
        return lhs.numberValue <= rhs.numberValue
    }
    
    if lhs.type != rhs.type {
        return false
    }

    switch lhs {
    case JSON.ScalarNumber:
        return lhs.numberValue! <= rhs.numberValue!
    case JSON.ScalarString:
        return lhs.stringValue! <= rhs.stringValue!
    case .Sequence:
        return lhs.arrayValue! == rhs.arrayValue!
    case .Mapping:
        return lhs.dictionaryValue! == rhs.dictionaryValue!
    case .Null:
        return true
    default:
        return false
    }
}

public func >=(lhs: JSON, rhs: JSON) -> Bool {
    
    if lhs.numberValue != nil && rhs.numberValue != nil {
        return lhs.numberValue >= rhs.numberValue
    }
    
    if lhs.type != rhs.type {
        return false
    }
    
    switch lhs {
    case JSON.ScalarNumber:
        return lhs.numberValue! >= rhs.numberValue!
    case JSON.ScalarString:
        return lhs.stringValue! >= rhs.stringValue!
    case .Sequence:
        return lhs.arrayValue! == rhs.arrayValue!
    case .Mapping:
        return lhs.dictionaryValue! == rhs.dictionaryValue!
    case .Null:
        return true
    default:
        return false
    }
}

public func >(lhs: JSON, rhs: JSON) -> Bool {
    
    if lhs.numberValue != nil && rhs.numberValue != nil {
        return lhs.numberValue > rhs.numberValue
    }
    
    if lhs.type != rhs.type {
        return false
    }
    
    switch lhs {
    case JSON.ScalarNumber:
        return lhs.numberValue! > rhs.numberValue!
    case JSON.ScalarString:
        return lhs.stringValue! > rhs.stringValue!
    case .Sequence:
        return false
    case .Mapping:
        return false
    case .Null:
        return false
    default:
        return false
    }
}

public func <(lhs: JSON, rhs: JSON) -> Bool {
    
    if lhs.numberValue != nil && rhs.numberValue != nil {
        return lhs.numberValue < rhs.numberValue
    }
    
    if lhs.type != rhs.type {
        return false
    }
    
    switch lhs {
    case JSON.ScalarNumber:
        return lhs.numberValue! < rhs.numberValue!
    case JSON.ScalarString:
        return lhs.stringValue! < rhs.stringValue!
    case .Sequence:
        return false
    case .Mapping:
        return false
    case .Null:
        return false
    default:
        return false
    }
}

// MARK: - NSNumber: Comparable
extension NSNumber: Comparable {
}

public func ==(lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedSame
}

public func <(lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedAscending
}

public func >(lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedDescending
}

public func <=(lhs: NSNumber, rhs: NSNumber) -> Bool {
    return !(lhs > rhs)
}

public func >=(lhs: NSNumber, rhs: NSNumber) -> Bool {
    return !(lhs < rhs)
}