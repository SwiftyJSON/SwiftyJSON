//  SwiftyJSON.swift
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

//MARK: - Return Error
//The SwiftyJSON's error domain
public let ErrorDomain = "SwiftyJSONErrorDomain"
//The error code
public let ErrorUnsupportedType = 999
public let ErrorIndexOutOfBounds = 900
public let ErrorWrongType = 901
public let ErrorNotExist = 500

public enum Type :Int{
    
    case Number
    case String
    case Bool
    case Array
    case Dictionary
    case Null
    case Unknow
}

//MARK:- Base
//http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-262.pdf
public struct JSON {
    
    public var type: Type {
        get {
            return _type
        }
        set {
            _type = newValue
        }
    }
    public var object: AnyObject {
        get {
            return _object
        }
        set {
            _object = newValue
            switch newValue {
            case let number as NSNumber:
                if number.isBool {
                    _type = .Bool
                } else {
                    _type = .Number
                }
            case let string as NSString:
                _type = .String
            case let null as NSNull:
                _type = .Null
            case let array as Array<AnyObject>:
                _type = .Array
            case let dictionary as Dictionary<String, AnyObject>:
                _type = .Dictionary
            default:
                _type = .Unknow
                _object = NSNull()
                _error = NSError(domain: ErrorDomain, code: ErrorUnsupportedType, userInfo: [NSLocalizedDescriptionKey: "It is a unsupported type"])
            }
        }
    }
    
    public var error: NSError? { get { return self._error } }
    public static var nullJSON: JSON { get { return JSON(NSNull()) } }

    /**
        :param: data The NSData used to convert to json.Top level object in data is an NSArray or NSDictionary
        :param: options The JSON serialization reading options. `.AllowFragments` by default.
        :param: error The NSErrorPointer used to return the error. `nil` by default.
     */
    public init(data:NSData, options opt: NSJSONReadingOptions = .AllowFragments, error: NSErrorPointer = nil) {
        if let object: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: opt, error: error) {
            self.init(object)
        } else {
            self.init(NSNull())
        }
    }
    
    /**
        :param: object The object must have the following properties:
        - All objects are NSString, NSNumber, NSArray, NSDictionary, or NSNull
        - All dictionary keys are NSStrings
        - NSNumbers are not NaN or infinity
        In swift
        - String as NSString
        - Bool, Int, Float, Double... as NSNumber
        - Array<AnyObject> as NSArray
        - Dictionary<String, AnyObject> as NSDictionary with NSString keys
    */
    public init(_ object: AnyObject) {
        self.object = object
    }
    
    private var _object: AnyObject = NSNull()
    private var _type: Type = .Null
    private var _error: NSError?

}

// MARK: - SequenceType
extension JSON: SequenceType{
    
    /// `true` if and only if self's type is `.Array` or `.Dictionary` and it is empty
    var isEmpty: Bool {
        get {
            switch self.type {
            case .Array:
                return (self.object as Array<AnyObject>).isEmpty
            case .Dictionary:
                return (self.object as Dictionary<String, AnyObject>).isEmpty
            default:
                return false
            }
        }
    }
    
    /// `count` value if self's type is `.Array` or `.Dictionary` otherwise is `0`
    public var count: Int {
        get {
            switch self.type {
            case .Array:
                return self.arrayValue.count
            case .Dictionary:
                return self.dictionaryValue.count
            default:
                return 0
            }
        }
    }

    /// - If self's type is .Array return GeneratorOf<(index, JSON(element))> otherwise return `nil`
    /// - If self's type is .Dictionary return GeneratorOf<(index, JSON(element))> otherwise return `nil`
    public func generate() -> GeneratorOf <(String, JSON)> {
        switch self.type {
        case .Array:
            let array_ = object as Array<AnyObject>
            var generate_ = array_.generate()
            var index_: Int = 0
            return GeneratorOf<(String, JSON)> {
                if let element_: AnyObject = generate_.next() {
                    return ("\(index_++)", JSON(element_))
                } else {
                    return nil
                }
            }
        case .Dictionary:
            let dictionary_ = object as Dictionary<String, AnyObject>
            var generate_ = dictionary_.generate()
            return GeneratorOf<(String, JSON)> {
                if let (key_: String, value_: AnyObject) = generate_.next() {
                    return (key_, JSON(value_))
                } else {
                    return nil
                }
            }
        default:
            return GeneratorOf<(String, JSON)> {
                return nil
            }
        }
    }
}

// MARK: - Subscript
extension JSON {
    
    /**
       If self is .Sequence return the array[index]'s json else return .Null with error
     */
    public subscript(idx: Int) -> JSON {
        get {
            var returnJSON = JSON.nullJSON
            if self.type == .Array {
                let array_ = self.object as Array<AnyObject>
                if array_.count > idx {
                    returnJSON = JSON(array_[idx])
                } else {
                    returnJSON._error = NSError(domain: ErrorDomain, code:ErrorIndexOutOfBounds , userInfo: [NSLocalizedDescriptionKey: "Array[\(index)] is out of bounds"])
                }
            } else {
                returnJSON._error = self._error ?? NSError(domain: ErrorDomain, code: ErrorWrongType, userInfo: [NSLocalizedDescriptionKey: "Array[\(index)] failure, It is not an array"])
            }
            return returnJSON
        }
        set {
            if self.type == .Array {
                var array_ = self.object as Array<AnyObject>
                if array_.count > idx {
                    array_[idx] = newValue.object
                    self.object = array_
                }
            }
        }
    }

    /**
       If self is .Sequence return the dictionary[key]'s JSON else return .Null with error
     */
    public subscript(key: String) -> JSON {
        get {
            var returnJSON = JSON.nullJSON
            if self.type == .Dictionary {
                if let object_: AnyObject = self.object[key] {
                    returnJSON = JSON(object_)
                } else {
                    returnJSON._error = NSError(domain: ErrorDomain, code: ErrorNotExist, userInfo: [NSLocalizedDescriptionKey: "Dictionary[\"\(key)\"] does not exist"])
                }
            } else {
                returnJSON._error = self._error ?? NSError(domain: ErrorDomain, code: ErrorWrongType, userInfo: [NSLocalizedDescriptionKey: "Dictionary[\"\(key)\"] failure, It is not an dictionary"])
            }
            return returnJSON
        }
        set {
            if self.type == .Dictionary {
                var dictionary_ = self.object as Dictionary<String, AnyObject>
                dictionary_[key] = newValue.object
                self.object = dictionary_
            }
        }
    }
}

//MARK:- LiteralConvertible
extension JSON: StringLiteralConvertible {
    
    public static func convertFromStringLiteral(value: StringLiteralType) -> JSON {
        return JSON(value)
    }
    
    public static func convertFromExtendedGraphemeClusterLiteral(value: StringLiteralType) -> JSON {
        return JSON(value)
    }
}

extension JSON: IntegerLiteralConvertible {
    public static func convertFromIntegerLiteral(value: IntegerLiteralType) -> JSON {
        return JSON(value)
    }
}

extension JSON: BooleanLiteralConvertible {
    public static func convertFromBooleanLiteral(value: BooleanLiteralType) -> JSON {
        return JSON(value)
    }
}

extension JSON: FloatLiteralConvertible {
    public static func convertFromFloatLiteral(value: FloatLiteralType) -> JSON {
        return JSON(value)
    }
}

extension JSON: DictionaryLiteralConvertible {
    public static func convertFromDictionaryLiteral(elements: (String, AnyObject)...) -> JSON {
        var dictionary_ = [String : AnyObject]()
        for (key_, value) in elements {
            dictionary_[key_] = value
        }
        return JSON(dictionary_)
    }
}

extension JSON: ArrayLiteralConvertible {
    public static func convertFromArrayLiteral(elements: AnyObject...) -> JSON {
        return JSON(elements)
    }
}

extension JSON: NilLiteralConvertible {
    public static func convertFromNilLiteral() -> JSON {
        return JSON(NSNull())
    }
}

//MARK:- RawRepresentable
extension JSON: RawRepresentable {
    
    public static func fromRaw(raw: AnyObject) -> JSON? {
        let json = JSON(raw)
        if json.type == .Unknow {
            return nil
        } else {
            return json
        }
    }
    
    public func toRaw() -> AnyObject {
        return self.object
    }
}

//MARK: - Printable, DebugPrintable
extension JSON: Printable, DebugPrintable {
    
    public var description: String {
        get {
            switch type {
            case .Number:
                return self.object.description
            case .String:
                return self.object as String
            case .Array:
                return (self.object as Array<AnyObject>).description
            case .Dictionary:
                return (self.object as Dictionary<String, AnyObject>).description
            case .Bool:
                return (self.object as Bool).description
            case .Null:
                return self.error?.description ?? "null"
            default:
                return self.error?.description ?? "unknown"
            }
        }
    }
    
    public var debugDescription: String {
        get {
            switch type {
            case .Number:
                return (self.object as NSNumber).debugDescription
            case .String:
                return self.object as String
            case .Array:
                return (self.object as Array<AnyObject>).debugDescription
            case .Dictionary:
                return (self.object as Dictionary<String, AnyObject>).debugDescription
            case .Bool:
                return (self.object as Bool).description
            case .Null:
                return self.error?.debugDescription ?? "null"
            default:
                return self.error?.debugDescription ?? "unknown"
            }
        }
    }
}

// MARK: - Array
extension JSON {
    
    //Optional Array<JSON>
    public var array: Array<JSON>? {
        get {
            if self.type == .Array {
                let array_ = self.object as Array<AnyObject>
                var returnArray_ = Array<JSON>()
                for subObject_ in array_ {
                    returnArray_.append(JSON(subObject_))
                }
                return returnArray_
            }
            return nil
        }
    }
    
    //Non-optional Array<JSON>
    public var arrayValue: Array<JSON> {
        get {
            return self.array ?? []
        }
    }
    
    //Optional Array<AnyObject>
    public var arrayObject: Array<AnyObject>? {
        get {
            switch self.type {
            case .Array:
                return self.object as? Array<AnyObject>
            default:
                return nil
            }
        }
        set {
            if newValue != nil {
                self.object = NSMutableArray(array: newValue!, copyItems: true)
            } else {
                self.object = NSNull()
            }
        }
    }
}

// MARK: - Dictionary
extension JSON {
    
    //Optional Dictionary<String, JSON>
    public var dictionary: Dictionary<String, JSON>? {
        get {
            switch self.type {
            case .Dictionary:
                var jsonDictionary_ = Dictionary<String, JSON>()
                for (key_, value_) in self.object as Dictionary<String, AnyObject> {
                    jsonDictionary_[key_] = JSON( value_)
                }
                return jsonDictionary_
            default:
                return nil
            }
        }
    }
    
    //Non-optional Dictionary<String, JSON>
    public var dictionaryValue: Dictionary<String, JSON> {
        get {
            return self.dictionary ?? [:]
        }
    }
    
    //Optional Dictionary<String, AnyObject>
    public var dictionaryObject: Dictionary<String, AnyObject>? {
        get {
            switch self.type {
            case .Dictionary:
                return self.object as? Dictionary<String, AnyObject>
            default:
                return nil
            }
        }
        set {
            if newValue != nil {
                self.object = NSMutableDictionary(dictionary: newValue!, copyItems: true)
            } else {
                self.object = NSNull()
            }
        }
    }
}

//MARK: - Bool
extension JSON: BooleanType {
    
    //Optional bool
    public var bool: Bool? {
        get {
            switch self.type {
            case .Bool:
                return self.object.boolValue
            default:
                return nil
            }
        }
        set {
            if newValue != nil {
                self.object = NSNumber(bool: newValue!)
            } else {
                self.object = NSNull()
            }
        }
    }

    //Non-optional bool
    public var boolValue: Bool {
        get {
            switch self.type {
            case .Bool, .Number, .String:
                return self.object.boolValue
            case .Array:
                return self.arrayValue.count > 0
            case .Dictionary:
                return self.dictionaryValue.count > 0
            case .Null:
                return false
            default:
                return false
            }
        }
        set {
            self.object = NSNumber(bool: newValue)
        }
    }
}

//MARK: - String
extension JSON {

    //Optional string
    public var string: String? {
        get {
            switch self.type {
            case .String:
                return self.object as? String
            default:
                return nil
            }
        }
        set {
            if newValue != nil {
                self.object = NSString(string:newValue!)
            } else {
                self.object = NSNull()
            }
        }
    }
    
    //Non-optional string
    public var stringValue: String {
        get {
            switch self.type {
            case .String:
                return self.object as String
            case .Number:
                return self.object.stringValue
            case .Bool:
                return (self.object as Bool).description
            default:
                return ""
            }
        }
        set {
            self.object = NSString(string:newValue)
        }
    }
}

//MARK: - Number
extension JSON {
    
    //Optional number
    public var number: NSNumber? {
        get {
            switch self.type {
            case .Number, .Bool:
                return self.object as? NSNumber
            default:
                return nil
            }
        }
        set {
            if newValue != nil {
                self.object = newValue!.copy()
            } else {
                self.object = NSNull()
            }
        }
    }
    
    //Non-optional number
    public var numberValue: NSNumber {
        get {
            switch self.type {
            case .String:
                let scanner = NSScanner(string: self.object as String)
                if scanner.scanDouble(nil){
                    if (scanner.atEnd) {
                        return NSNumber(double:(self.object as NSString).doubleValue)
                    }
                }
                return NSNumber(double: 0.0)
            case .Number, .Bool:
                return self.object as NSNumber
            default:
                return NSNumber(double: 0.0)
            }
        }
        set {
            self.object = newValue.copy()
        }
    }
}

//MARK: - Null
extension JSON {
 
    public var null: NSNull? {
        get {
            switch self.type {
            case .Null:
                return NSNull()
            default:
                return nil
            }
        }
        set {
            self.object = NSNull()
        }
    }
}

//MARK: - URL
extension JSON {
    
    //Optional URL
    public var URL: NSURL? {
        get {
            switch self.type {
            case .String:
                if let encodedString_ = self.object.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
                    return NSURL(string: encodedString_)
                } else {
                    return nil
                }
            default:
                return nil
            }
        }
        set {
            self.object = newValue?.absoluteString ?? NSNull()
        }
    }
}

//MARK: - Int, Double, Float, Int8, Int16, Int32, Int64
extension JSON {
    
    public var double: Double? {
        get {
            return self.number?.doubleValue
        }
        set {
            if newValue != nil {
                self.object = NSNumber(double: newValue!)
            } else {
                self.object = NSNull()
            }
        }
    }
    
    public var doubleValue: Double {
        get {
            return self.numberValue.doubleValue
        }
        set {
            self.object = NSNumber(double: newValue)
        }
    }
    
    public var float: Float? {
        get {
            return self.number?.floatValue
        }
        set {
            if newValue != nil {
                self.object = NSNumber(float: newValue!)
            } else {
                self.object = NSNull()
            }
        }
    }
    
    public var floatValue: Float {
        get {
            return self.numberValue.floatValue
        }
        set {
            self.object = NSNumber(float: newValue)
        }
    }
    
    public var int: Int? {
        get {
            return self.number?.longValue
        }
        set {
            if newValue != nil {
                self.object = NSNumber(integer: newValue!)
            } else {
                self.object = NSNull()
            }
        }
    }
    
    public var intValue: Int {
        get {
            return self.numberValue.integerValue
        }
        set {
            self.object = NSNumber(integer: newValue)
        }
    }
    
    public var uInt: UInt? {
        get {
            return self.number?.unsignedLongValue
        }
        set {
            if newValue != nil {
                self.object = NSNumber(unsignedLong: newValue!)
            } else {
                self.object = NSNull()
            }
        }
    }
    
    public var uIntValue: UInt {
        get {
            return self.numberValue.unsignedLongValue
        }
        set {
            self.object = NSNumber(unsignedLong: newValue)
        }
    }

    public var int8: Int8? {
        get {
            return self.number?.charValue
        }
        set {
            if newValue != nil {
                self.object = NSNumber(char: newValue!)
            } else {
                self.object =  NSNull()
            }
        }
    }
    
    public var int8Value: Int8 {
        get {
            return self.numberValue.charValue
        }
        set {
            self.object = NSNumber(char: newValue)
        }
    }
    
    public var uInt8: UInt8? {
        get {
            return self.number?.unsignedCharValue
        }
        set {
            if newValue != nil {
                self.object = NSNumber(unsignedChar: newValue!)
            } else {
                self.object =  NSNull()
            }
        }
    }
    
    public var uInt8Value: UInt8 {
        get {
            return self.numberValue.unsignedCharValue
        }
        set {
            self.object = NSNumber(unsignedChar: newValue)
        }
    }
    
    public var int16: Int16? {
        get {
            return self.number?.shortValue
        }
        set {
            if newValue != nil {
                self.object = NSNumber(short: newValue!)
            } else {
                self.object =  NSNull()
            }
        }
    }
    
    public var int16Value: Int16 {
        get {
            return self.numberValue.shortValue
        }
        set {
            self.object = NSNumber(short: newValue)
        }
    }
    
    public var uInt16: UInt16? {
        get {
            return self.number?.unsignedShortValue
        }
        set {
            if newValue != nil {
                self.object = NSNumber(unsignedShort: newValue!)
            } else {
                self.object =  NSNull()
            }
        }
    }
    
    public var uInt16Value: UInt16 {
        get {
            return self.numberValue.unsignedShortValue
        }
        set {
            self.object = NSNumber(unsignedShort: newValue)
        }
    }

    public var int32: Int32? {
        get {
            return self.number?.intValue
        }
        set {
            if newValue != nil {
                self.object = NSNumber(int: newValue!)
            } else {
                self.object =  NSNull()
            }
        }
    }
    
    public var int32Value: Int32 {
        get {
            return self.numberValue.intValue
        }
        set {
            self.object = NSNumber(int: newValue)
        }
    }
    
    public var uInt32: UInt32? {
        get {
            return self.number?.unsignedIntValue
        }
        set {
            if newValue != nil {
                self.object = NSNumber(unsignedInt: newValue!)
            } else {
                self.object =  NSNull()
            }
        }
    }
    
    public var uInt32Value: UInt32 {
        get {
            return self.numberValue.unsignedIntValue
        }
        set {
            self.object = NSNumber(unsignedInt: newValue)
        }
    }
    
    public var int64: Int64? {
        get {
            return self.number?.longLongValue
        }
        set {
            if newValue != nil {
                self.object = NSNumber(longLong: newValue!)
            } else {
                self.object =  NSNull()
            }
        }
    }
    
    public var int64Value: Int64 {
        get {
            return self.numberValue.longLongValue
        }
        set {
            self.object = NSNumber(longLong: newValue)
        }
    }
    
    public var uInt64: UInt64? {
        get {
            return self.number?.unsignedLongLongValue
        }
        set {
            if newValue != nil {
                self.object = NSNumber(unsignedLongLong: newValue!)
            } else {
                self.object =  NSNull()
            }
        }
    }
    
    public var uInt64Value: UInt64 {
        get {
            return self.numberValue.unsignedLongLongValue
        }
        set {
            self.object = NSNumber(unsignedLongLong: newValue)
        }
    }
}

//MARK: - Comparable
extension JSON: Comparable {}

public func ==(lhs: JSON, rhs: JSON) -> Bool {
    
    switch (lhs.type, rhs.type) {
    case (.Number, .Number):
        return (lhs.object as NSNumber) == (rhs.object as NSNumber)
    case (.String, .String):
        return (lhs.object as String) == (rhs.object as String)
    case (.Bool, .Bool):
        return (lhs.object as Bool) == (rhs.object as Bool)
    case (.Array, .Array):
        return (lhs.object as NSArray) == (rhs.object as NSArray)
    case (.Dictionary, .Dictionary):
        return (lhs.object as NSDictionary) == (rhs.object as NSDictionary)
    case (.Null, .Null):
        return true
    default:
        return false
    }
}

public func <=(lhs: JSON, rhs: JSON) -> Bool {
    
    switch (lhs.type, rhs.type) {
    case (.Number, .Number):
        return (lhs.object as NSNumber) <= (rhs.object as NSNumber)
    case (.String, .String):
        return (lhs.object as String) <= (rhs.object as String)
    case (.Bool, .Bool):
        return (lhs.object as Bool) == (rhs.object as Bool)
    case (.Array, .Array):
        return (lhs.object as NSArray) == (rhs.object as NSArray)
    case (.Dictionary, .Dictionary):
        return (lhs.object as NSDictionary) == (rhs.object as NSDictionary)
    case (.Null, .Null):
        return true
    default:
        return false
    }
}

public func >=(lhs: JSON, rhs: JSON) -> Bool {
    
    switch (lhs.type, rhs.type) {
    case (.Number, .Number):
        return (lhs.object as NSNumber) >= (rhs.object as NSNumber)
    case (.String, .String):
        return (lhs.object as String) >= (rhs.object as String)
    case (.Bool, .Bool):
        return (lhs.object as Bool) == (rhs.object as Bool)
    case (.Array, .Array):
        return (lhs.object as NSArray) == (rhs.object as NSArray)
    case (.Dictionary, .Dictionary):
        return (lhs.object as NSDictionary) == (rhs.object as NSDictionary)
    case (.Null, .Null):
        return true
    default:
        return false
    }
}

public func >(lhs: JSON, rhs: JSON) -> Bool {
    
    switch (lhs.type, rhs.type) {
    case (.Number, .Number):
        return (lhs.object as NSNumber) > (rhs.object as NSNumber)
    case (.String, .String):
        return (lhs.object as String) > (rhs.object as String)
    default:
        return false
    }
}

public func <(lhs: JSON, rhs: JSON) -> Bool {
    
    switch (lhs.type, rhs.type) {
    case (.Number, .Number):
        return (lhs.object as NSNumber) < (rhs.object as NSNumber)
    case (.String, .String):
        return (lhs.object as String) < (rhs.object as String)
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
                if self.compare(NSNumber(bool: true)) == NSComparisonResult.OrderedSame || self.compare(NSNumber(bool: false)) == NSComparisonResult.OrderedSame {
                    return true
                } else {
                    return false
                }
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

//MARK:- Unavailable
extension JSON {
    
    @availability(*, unavailable, message="use 'init(_ object:AnyObject)' instead")
    public init(object: AnyObject) {
        self = JSON(object)
    }
    
    @availability(*, unavailable, renamed="dictionaryObject")
    public var dictionaryObjects: Dictionary<String, AnyObject>? {
        get { return self.dictionaryObject }
    }
    
    @availability(*, unavailable, renamed="arrayObject")
    public var arrayObjects: Array<AnyObject>? {
        get { return self.arrayObject }
    }
    
    @availability(*, unavailable, renamed="int8")
    public var char: Int8? {
        get {
            return self.number?.charValue
        }
    }
    
    @availability(*, unavailable, renamed="int8Value")
    public var charValue: Int8 {
        get {
            return self.numberValue.charValue
        }
    }
    
    @availability(*, unavailable, renamed="uInt8")
    public var unsignedChar: UInt8? {
        get{
            return self.number?.unsignedCharValue
        }
    }
    
    @availability(*, unavailable, renamed="uInt8Value")
    public var unsignedCharValue: UInt8 {
        get{
            return self.numberValue.unsignedCharValue
        }
    }
    
    @availability(*, unavailable, renamed="int16")
    public var short: Int16? {
        get{
            return self.number?.shortValue
        }
    }
    
    @availability(*, unavailable, renamed="int16Value")
    public var shortValue: Int16 {
        get{
            return self.numberValue.shortValue
        }
    }
    
    @availability(*, unavailable, renamed="uInt16")
    public var unsignedShort: UInt16? {
        get{
            return self.number?.unsignedShortValue
        }
    }
    
    @availability(*, unavailable, renamed="uInt16Value")
    public var unsignedShortValue: UInt16 {
        get{
            return self.numberValue.unsignedShortValue
        }
    }
    
    @availability(*, unavailable, renamed="int")
    public var long: Int? {
        get{
            return self.number?.longValue
        }
    }
    
    @availability(*, unavailable, renamed="intValue")
    public var longValue: Int {
        get{
            return self.numberValue.longValue
        }
    }
    
    @availability(*, unavailable, renamed="uInt")
    public var unsignedLong: UInt? {
        get{
            return self.number?.unsignedLongValue
        }
    }
    
    @availability(*, unavailable, renamed="uIntValue")
    public var unsignedLongValue: UInt {
        get{
            return self.numberValue.unsignedLongValue
        }
    }
    
    @availability(*, unavailable, renamed="int64")
    public var longLong: Int64? {
        get{
            return self.number?.longLongValue
        }
    }
    
    @availability(*, unavailable, renamed="int64Value")
    public var longLongValue: Int64 {
        get{
            return self.numberValue.longLongValue
        }
    }
    
    @availability(*, unavailable, renamed="uInt64")
    public var unsignedLongLong: UInt64? {
        get{
            return self.number?.unsignedLongLongValue
        }
    }
    
    @availability(*, unavailable, renamed="uInt64Value")
    public var unsignedLongLongValue: UInt64 {
        get{
            return self.numberValue.unsignedLongLongValue
        }
    }
    
    @availability(*, unavailable, renamed="int")
    public var integer: Int? {
        get {
            return self.number?.integerValue
        }
    }
    
    @availability(*, unavailable, renamed="intValue")
    public var integerValue: Int {
        get {
            return self.numberValue.integerValue
        }
    }
    
    @availability(*, unavailable, renamed="uInt")
    public var unsignedInteger: Int? {
        get {
            return self.number?.unsignedIntegerValue
        }
    }
    
    @availability(*, unavailable, renamed="uIntValue")
    public var unsignedIntegerValue: Int {
        get {
            return self.numberValue.unsignedIntegerValue
        }
    }
}
