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

@availability(*, unavailable, renamed="JSON")
public typealias JSONValue = JSON

//MARK:- Base
//http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-262.pdf
public enum JSON {
    
    //private type number
    case ScalarNumber(NSNumber)
    //private type string
    case ScalarString(String)
    //private type sequence
    case Sequence(Array<JSON>)
    //private type mapping
    case Mapping(Dictionary<String, JSON>)
    //private type null
    case Null(NSError?)
    //super private type for raw object and lazy wrapping into other cases
    case PrivateRaw(AnyObject)
    
    /**
       :param: data The NSData used to convert to json.
       :param: options The JSON serialization reading options. `.AllowFragments` by default.
       :param: error The NSErrorPointer used to return the error.
     */
    public init(data:NSData, options opt: NSJSONReadingOptions = .AllowFragments, error: NSErrorPointer = nil) {
        if let object: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: opt, error: error){
            self = JSON(object: object)
        } else {
            self = .Null(nil)
        }
    }
    
    /**
       :param: object The JSON object following the JSON's definition
    */
    public init(object: AnyObject) {
        switch object {
        case let number as NSNumber:
            self = .ScalarNumber(number)
        case let string as NSString:
            self = .ScalarString(string)
        case let null as NSNull:
            self = .Null(nil)
        case let array as Array<AnyObject>:
            var jsonArray = Array<JSON>()
            for object : AnyObject in array {
                jsonArray.append(.PrivateRaw(object))
            }
            self = .Sequence(jsonArray)
        case let dictionary as Dictionary<String, AnyObject>:
            var jsonDictionary = Dictionary<String, JSON>()
            for (key : String, value : AnyObject) in dictionary {
                jsonDictionary[key] = .PrivateRaw(value)
            }
            self = .Mapping(jsonDictionary)
        case let null as NSNull:
            self = .Null(nil)
        default:
            self = .Null(NSError(domain: ErrorDomain, code: ErrorUnsupportedType, userInfo: [NSLocalizedDescriptionKey: "It is a unsupported type"]))
        }
    }
}

//MARK: - Return Error
//The SwiftyJSON's error domain
public let ErrorDomain: String! = "SwiftyJSONErrorDomain"
//The error code
public var ErrorUnsupportedType: Int { get { return 999 }}
public var ErrorIndexOutOfBounds: Int { get { return 900 }}
public var ErrorWrongType: Int { get { return 901 }}
public var ErrorNotExist: Int { get { return 500 }}

extension JSON {

    // The error in the .Null enmu
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
    
    // The rawObject in the .PrivateRaw enmu
    private var rawObject: AnyObject? {
        get {
            switch self {
            case .PrivateRaw(let object):
                return object
            default:
                return nil;
            }
        }
    }
    
}

//MARK:- Object
extension JSON {
    
    // The json object which is init(object:)'s parameter
    public var object: AnyObject? {
        switch self {
        case .ScalarNumber(let number):
            return number
        case .ScalarString(let string):
            return string
        case .Null(let error) where error == nil:
            return NSNull()
        case .Sequence(let array):
            var retArray = Array<AnyObject>()
            for json in array {
                retArray.append(json.rawObject!)
            }
            return retArray
        case .Mapping(let dictionary):
            var retDicitonary = Dictionary<String, AnyObject>()
            for (key : String, value : JSON) in dictionary {
                retDicitonary[key] = value.rawObject
            }
            return retDicitonary
        case .PrivateRaw(let object):
            return object
        default:
            return nil
        }
    }
}

// MARK: - Subscript
extension JSON {
    
    //if an array return the array[index]'s JSON else return .Null with error
    public subscript(index: Int) -> JSON {
        get {
            switch self {
            case .Sequence(let array):
                if array.count > index {
                    return JSON(object: array[index].rawObject!)
                } else {
                    return .Null(NSError(domain: ErrorDomain, code:ErrorIndexOutOfBounds , userInfo: [NSLocalizedDescriptionKey: "Array[\(index)] is out of bounds"]))
                }
            default:
                return .Null(NSError(domain: ErrorDomain, code: ErrorWrongType, userInfo: [NSLocalizedDescriptionKey: "Wrong type, It is not an array"]))
            }
        }
    }
    
    //if an array return the dictionary[key]'s JSON else return .Null with error
    public subscript(key: String) -> JSON {
        get {
            switch self {
            case .Mapping(let dictionary):
                if let value = dictionary[key] {
                    return JSON(object: value.rawObject!)
                } else {
                    return .Null(NSError(domain: ErrorDomain, code: ErrorNotExist, userInfo: [NSLocalizedDescriptionKey: "Dictionary[\"\(key)\"] does not exist"]))
                }
            default:
                return .Null(NSError(domain: ErrorDomain, code: ErrorWrongType, userInfo: [NSLocalizedDescriptionKey: "Wrong type, It is not an dictionary"]))
            }
        }
    }
}

//MARK: - Printable, DebugPrintable
extension JSON: Printable, DebugPrintable {
    
    public var description: String {
        switch self {
        case .ScalarNumber(let number):
            if number.isBool {
                return number.boolValue.description
            } else {
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
        case .PrivateRaw(let object):
            return JSON(object: object).description
        default:
            return "null"
        }
    }
    
    public var debugDescription: String {
        get {
            switch self {
            case .ScalarNumber(let number):
                if number.isBool {
                    return number.boolValue.description
                } else {
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
            case .PrivateRaw(let object):
                return JSON(object: object).debugDescription
            default:
                return "null"
            }
        }
    }
}

// MARK: - Sequence: Array<JSON>
extension JSON {
    
    //Optional array
    public var array: Array<JSON>? {
        get {
            switch self {
            case .Sequence(let array):
                var retArray = Array<JSON>()
                for json in array {
                    retArray.append(JSON(object: json.rawObject!))
                }
                return retArray
            default:
                return nil
            }
        }
    }
    
    //Non-optional array
    public var arrayValue: Array<JSON> {
        get {
            return self.array ?? []
        }
    }
}

// MARK: - Mapping: Dictionary<String, JSON>
extension JSON {
    
    //Optional dictionary
    public var dictionary: Dictionary<String, JSON>? {
        get {
            switch self {
            case .Mapping(let dictionary):
                var retDicitonary = Dictionary<String, JSON>()
                for (key : String, value : JSON) in dictionary {
                    retDicitonary[key] = JSON(object: value.rawObject!)
                }
                return retDicitonary
            default:
                return nil
            }
        }
    }
    
    //Non-optional dictionary
    public var dictionaryValue: Dictionary<String, JSON> {
        get {
            return self.dictionary ?? [:]
        }
    }
}

//MARK: - Scalar: Bool
extension JSON: BooleanType {
    
    //Optional bool
    public var bool: Bool? {
        get {
            switch self {
            case .ScalarNumber(let number) where number.isBool:
                return number.boolValue
            default:
                return nil
            }
        }
    }

    //Non-optional bool
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

//MARK: - Scalar: String
extension JSON {

    //Optional string
    public var string: String? {
        get {
            switch self {
            case .ScalarString(let string):
                return string
            default:
                return nil
            }
        }
    }
    
    //Non-optional string
    public var stringValue: String {
        get {
            switch self {
            case .ScalarString(let string):
                return string
            case .ScalarNumber(let number):
                if number.isBool {
                    return number.boolValue.description
                } else {
                    return number.stringValue
                }
            default:
                return ""
            }
        }
    }
}

//MARK: - Scalar: Number
extension JSON {
    
    //Optional number
    public var number: NSNumber? {
        get {
            switch self {
            case .ScalarNumber(let number):
                return number
            default:
                return nil
            }
        }
    }
    
    //Non-optional number
    public var numberValue: NSNumber {
        get {
            switch self {
            case .ScalarString(let string):
                let scanner = NSScanner(string: string)
                if scanner.scanDouble(nil){
                    if (scanner.atEnd) {
                        return NSNumber(double:(string as NSString).doubleValue)
                    }
                }
                return NSNumber(double: 0.0)
            case .ScalarNumber(let number):
                return number
            default:
                return NSNumber(double: 0.0)
            }
        }
    }
}

//MARK: - Null
extension JSON {
 
    public var null: NSNull? {
        get {
            switch self {
            case .Null(let error) where error == nil:
                return NSNull()
            default:
                return nil
            }
        }
    }
}

//MARK: - URL
extension JSON {
    
    //Optional URL
    public var URL: NSURL? {
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
}

//MARK: - Int, Double, Float, Int8, Int16, Int32, Int64
extension JSON {
    
    //Optional Int8
    public var char: Int8? {
        get {
            return self.number?.charValue
        }
    }

    //Optional Int8
    public var charValue: Int8 {
        get {
            return self.numberValue.charValue
        }
    }
    
    //Optional UInt8
    public var unsignedChar: UInt8? {
        get{
            return self.number?.unsignedCharValue
        }
    }
    
    //Non-optional UInt8
    public var unsignedCharValue: UInt8 {
        get{
            return self.numberValue.unsignedCharValue
        }
    }
    
    //Optional Int16
    public var short: Int16? {
        get{
            return self.number?.shortValue
        }
    }
    
    //Non-optional UInt8
    public var shortValue: Int16 {
        get{
            return self.numberValue.shortValue
        }
    }
    
    //Optional UInt16
    public var unsignedShort: UInt16? {
        get{
            return self.number?.unsignedShortValue
        }
    }
    
    //Non-optional UInt16
    public var unsignedShortValue: UInt16 {
        get{
            return self.numberValue.unsignedShortValue
        }
    }
    
    //Optional Int
    public var long: Int? {
        get{
            return self.number?.longValue
        }
    }
    
    //Non-optional Int
    public var longValue: Int {
        get{
            return self.numberValue.longValue
        }
    }
    
    //Optional UInt
    public var unsignedLong: UInt? {
        get{
            return self.number?.unsignedLongValue
        }
    }
    
    //Non-optional UInt
    public var unsignedLongValue: UInt {
        get{
            return self.numberValue.unsignedLongValue
        }
    }
    
    //Optional Int64
    public var longLong: Int64? {
        get{
            return self.number?.longLongValue
        }
    }

    //Non-optional Int64
    public var longLongValue: Int64 {
        get{
            return self.numberValue.longLongValue
        }
    }
    
    //Optional UInt64
    public var unsignedLongLong: UInt64? {
        get{
            return self.number?.unsignedLongLongValue
        }
    }

    //Non-optional UInt64
    public var unsignedLongLongValue: UInt64 {
        get{
            return self.numberValue.unsignedLongLongValue
        }
    }
    
    //Optional Float
    public var float: Float? {
        get {
            return self.number?.floatValue
        }
    }
    
    //Non-optional Float
    public var floatValue: Float {
        get {
            return self.numberValue.floatValue
        }
    }
    
    //Optional Double
    public var double: Double? {
        get {
            return self.number?.doubleValue
        }
    }

    //Non-optional Double
    public var doubleValue: Double {
        get {
            return self.numberValue.doubleValue
        }
    }

    //Optional Int
    public var integer: Int? {
        get {
            return self.number?.integerValue
        }
    }

    //Non-optional Int
    public var integerValue: Int {
        get {
            return self.numberValue.integerValue
        }
    }
    
    //Optional Int
    public var unsignedInteger: Int? {
        get {
            return self.number?.unsignedIntegerValue
        }
    }
    
    //Non-optional Int
    public var unsignedIntegerValue: Int {
        get {
            return self.numberValue.unsignedIntegerValue
        }
    }
    
    //Optional Int32
    public var int: Int32? {
        get {
            return self.number?.intValue
        }
    }
    
    //non-optional Int32
    public var intValue: Int32 {
        get {
            return self.numberValue.intValue
        }
    }
}

//MARK: - Comparable
extension JSON: Comparable {}

public func ==(lhs: JSON, rhs: JSON) -> Bool {
    
    switch (lhs, rhs) {
    case (.ScalarNumber(let l), .ScalarNumber(let r)):
        return l == r
    case (.ScalarString(let l), .ScalarString(let r)):
        return l == r
    case (.Sequence(let l), .Sequence(let r)):
        return l == r
    case (.Mapping(let l), .Mapping(let r)):
        return l == r
    case (.Mapping(let l), .Mapping(let r)):
        return l == r
    case (.Null(let l), .Null(let r)):
        let lcode = l?.code ?? 0
        let rcode = l?.code ?? 0
        return lcode == rcode
    case (.PrivateRaw(let l), .PrivateRaw(let r)):
        return JSON(object: l) == JSON(object: r)
    default:
        return false
    }
}

public func !=(lhs: JSON, rhs: JSON) -> Bool {
    return !(lhs == rhs)
}

public func <=(lhs: JSON, rhs: JSON) -> Bool {
    
    switch (lhs, rhs) {
    case (.ScalarNumber(let l), .ScalarNumber(let r)):
        return l <= r
    case (.ScalarString(let l), .ScalarString(let r)):
        return l <= r
    case (.Sequence(let l), .Sequence(let r)):
        return l == r
    case (.Mapping(let l), .Mapping(let r)):
        return l == r
    case (.Null(let l), .Null(let r)):
        let lcode = l?.code ?? 0
        let rcode = l?.code ?? 0
        return lcode == rcode
    case (.PrivateRaw(let l), .PrivateRaw(let r)):
        return JSON(object: l) <= JSON(object: r)
    default:
        return false
    }
}

public func >=(lhs: JSON, rhs: JSON) -> Bool {
    
    switch (lhs, rhs) {
    case (.ScalarNumber(let l), .ScalarNumber(let r)):
        return l >= r
    case (.ScalarString(let l), .ScalarString(let r)):
        return l >= r
    case (.Sequence(let l), .Sequence(let r)):
        return l == r
    case (.Mapping(let l), .Mapping(let r)):
        return l == r
    case (.Null(let l), .Null(let r)):
        let lcode = l?.code ?? 0
        let rcode = l?.code ?? 0
        return lcode == rcode
    case (.PrivateRaw(let l), .PrivateRaw(let r)):
        return JSON(object: l) >= JSON(object: r)
    default:
        return false
    }
}

public func >(lhs: JSON, rhs: JSON) -> Bool {
    
    switch (lhs, rhs) {
    case (.ScalarNumber(let l), .ScalarNumber(let r)):
        return l > r
    case (.ScalarString(let l), .ScalarString(let r)):
        return l > r
    default:
        return false
    }
}

public func <(lhs: JSON, rhs: JSON) -> Bool {
    
    switch (lhs, rhs) {
    case (.ScalarNumber(let l), .ScalarNumber(let r)):
        return l < r
    case (.ScalarString(let l), .ScalarString(let r)):
        return l < r
    default:
        return false
    }
}

// MARK: - NSNumber: Comparable
extension NSNumber: Comparable {
    var isBool:Bool {
        get {
            switch String.fromCString(self.objCType)! {
            case "c", "C":
                return true
            default:
                return false
            }
        }
    }
}

public func ==(lhs: NSNumber, rhs: NSNumber) -> Bool {
    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) == NSComparisonResult.OrderedSame
    }
}

public func !=(lhs: NSNumber, rhs: NSNumber) -> Bool {
    return !(rhs == rhs)
}

public func <(lhs: NSNumber, rhs: NSNumber) -> Bool {
    
    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) == NSComparisonResult.OrderedAscending
    }
}

public func >(lhs: NSNumber, rhs: NSNumber) -> Bool {
    
    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) == NSComparisonResult.OrderedDescending
    }
}

public func <=(lhs: NSNumber, rhs: NSNumber) -> Bool {

    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) != NSComparisonResult.OrderedDescending
    }
}

public func >=(lhs: NSNumber, rhs: NSNumber) -> Bool {

    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) != NSComparisonResult.OrderedAscending
    }
}