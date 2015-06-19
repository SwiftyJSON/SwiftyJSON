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

// MARK: - Error

///Error domain
public let ErrorDomain: String! = "SwiftyJSONErrorDomain"

///Error code
public let ErrorUnsupportedType: Int! = 999
public let ErrorIndexOutOfBounds: Int! = 900
public let ErrorWrongType: Int! = 901
public let ErrorNotExist: Int! = 500

// MARK: - JSON Type

/**
JSON's type definitions.

See http://tools.ietf.org/html/rfc7231#section-4.3
*/
public enum Type :Int{
    
    case Number
    case String
    case Bool
    case Array
    case Dictionary
    case Null
    case Unknown
}

// MARK: - JSON Base

public struct JSON {

    /**
    Creates a JSON using the data.
    
    - parameter data:  The NSData used to convert to json.Top level object in data is an NSArray or NSDictionary
    - parameter opt:   The JSON serialization reading options. `.AllowFragments` by default.
    - parameter error: error The NSErrorPointer used to return the error. `nil` by default.
    
    - returns: The created JSON
    */
    public init(data:NSData, options opt: NSJSONReadingOptions = .AllowFragments, error: NSErrorPointer = nil) {
        do {
            let object: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: opt)
            self.init(object)
        } catch let aError as NSError {
            error.memory = aError
            self.init(NSNull())
        }
    }
    
    /**
    Creates a JSON using the object.
    
    - parameter object:  The object must have the following properties: All objects are NSString/String, NSNumber/Int/Float/Double/Bool, NSArray/Array, NSDictionary/Dictionary, or NSNull; All dictionary keys are NSStrings/String; NSNumbers are not NaN or infinity.
    
    - returns: The created JSON
    */
    public init(_ object: AnyObject) {
        self.object = object
    }

    /**
    Creates a JSON from a [JSON]
    
    - parameter jsonArray: A Swift array of JSON objects
    
    - returns: The created JSON
    */
    public init(_ jsonArray:[JSON]) {
        self.init(jsonArray.map { $0.object })
    }

    /// Private object
    private var _object: AnyObject = NSNull()
    /// Private type
    private var _type: Type = .Null
    /// prviate error
    private var _error: NSError?

    /// Object in JSON
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
            case  _ as NSString:
                _type = .String
            case  _ as NSNull:
                _type = .Null
            case _ as [AnyObject]:
                _type = .Array
            case _ as [String : AnyObject]:
                _type = .Dictionary
            default:
                _type = .Unknown
                _object = NSNull()
                _error = NSError(domain: ErrorDomain, code: ErrorUnsupportedType, userInfo: [NSLocalizedDescriptionKey: "It is a unsupported type"])
            }
        }
    }
    
    /// json type
    public var type: Type { get { return _type } }

    /// Error in JSON
    public var error: NSError? { get { return self._error } }
    
    /// The static null json
    @available(*, unavailable, renamed="null")
    public static var nullJSON: JSON { get { return null } }
    public static var null: JSON { get { return JSON(NSNull()) } }
}

// MARK: - SequenceType
extension JSON : Swift.SequenceType {
    
    /// If `type` is `.Array` or `.Dictionary`, return `array.empty` or `dictonary.empty` otherwise return `false`.
    public var isEmpty: Bool {
        get {
            switch self.type {
            case .Array:
                return (self.object as! [AnyObject]).isEmpty
            case .Dictionary:
                return (self.object as! [String : AnyObject]).isEmpty
            default:
                return false
            }
        }
    }
    
    /// If `type` is `.Array` or `.Dictionary`, return `array.count` or `dictonary.count` otherwise return `0`.
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
    
    /**
    If `type` is `.Array` or `.Dictionary`, return a generator over the elements like `Array` or `Dictionary`, otherwise return a generator over empty.
    
    - returns: Return a *generator* over the elements of this *sequence*.
    */
    public func generate() -> AnyGenerator<(String, JSON)> {
        switch self.type {
        case .Array:
            let array_ = object as! [AnyObject]
            var generate_ = array_.generate()
            var index_: Int = 0
            return anyGenerator {
                if let element_: AnyObject = generate_.next() {
                    return ("\(index_++)", JSON(element_))
                } else {
                    return nil
                }
            }
        case .Dictionary:
            let dictionary_ = object as! [String : AnyObject]
            var generate_ = dictionary_.generate()
            return anyGenerator {
                if let (key_, value_): (String, AnyObject) = generate_.next() {
                    return (key_, JSON(value_))
                } else {
                    return nil
                }
            }
        default:
            return anyGenerator {
                return nil
            }
        }
    }
}

// MARK: - Subscript

/**
*  To mark both String and Int can be used in subscript.
*/
public protocol SubscriptType {}

extension Int: SubscriptType {}

extension String: SubscriptType {}

extension JSON {
    
    /// If `type` is `.Array`, return json which's object is `array[index]`, otherwise return null json with error.
    private subscript(index index: Int) -> JSON {
        get {
            
            if self.type != .Array {
                var errorResult_ = JSON.null
                errorResult_._error = self._error ?? NSError(domain: ErrorDomain, code: ErrorWrongType, userInfo: [NSLocalizedDescriptionKey: "Array[\(index)] failure, It is not an array"])
                return errorResult_
            }
            
            let array_ = self.object as! [AnyObject]

            if index >= 0 && index < array_.count {
                return JSON(array_[index])
            }
            
            var errorResult_ = JSON.null
            errorResult_._error = NSError(domain: ErrorDomain, code:ErrorIndexOutOfBounds , userInfo: [NSLocalizedDescriptionKey: "Array[\(index)] is out of bounds"])
            return errorResult_
        }
        set {
            if self.type == .Array {
                var array_ = self.object as! [AnyObject]
                if array_.count > index {
                    array_[index] = newValue.object
                    self.object = array_
                }
            }
        }
    }

    /// If `type` is `.Dictionary`, return json which's object is `dictionary[key]` , otherwise return null json with error.
    private subscript(key key: String) -> JSON {
        get {
            var returnJSON = JSON.null
            if self.type == .Dictionary {
                let dictionary_ = self.object as! [String : AnyObject]
                if let object_: AnyObject = dictionary_[key] {
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
                var dictionary_ = self.object as! [String : AnyObject]
                dictionary_[key] = newValue.object
                self.object = dictionary_
            }
        }
    }
    
    /// If `sub` is `Int`, return `subscript(index:)`; If `sub` is `String`,  return `subscript(key:)`.
    private subscript(sub sub: SubscriptType) -> JSON {
        get {
            if sub is String {
                return self[key:sub as! String]
            } else {
                return self[index:sub as! Int]
            }
        }
        set {
            if sub is String {
                self[key:sub as! String] = newValue
            } else {
                self[index:sub as! Int] = newValue
            }
        }
    }
    
    /**
    Find a json in the complex data structuresby using the Int/String's array.
    
    - parameter path: The target json's path. Example: 
                   
            let json = JSON[data]
            let path = [9,"list","person","name"]
            let name = json[path]
    
            The same as: let name = json[9]["list"]["person"]["name"]
    
    - returns: Return a json found by the path or a null json with error
    */
    public subscript(path: [SubscriptType]) -> JSON {
        get {
            switch path.count {
            case 0: return JSON.null
            case 1: return self[sub: path[0]]
            default:
                var aPath = path; aPath.removeAtIndex(0)
                let nextJSON = self[sub: path[0]]
                return nextJSON[aPath]
            }
        }
        set {
            switch path.count {
            case 0: return
            case 1: self[sub:path[0]].object = newValue.object
            default:
                var aPath = path; aPath.removeAtIndex(0)
                var nextJSON = self[sub: path[0]]
                nextJSON[aPath] = newValue
                self[sub: path[0]] = nextJSON
            }
        }
    }
    
    /**
    Find a json in the complex data structuresby using the Int/String's array.
    
    - parameter path: The target json's path. Example:
    
            let name = json[9,"list","person","name"]
    
            The same as: let name = json[9]["list"]["person"]["name"]
    
    - returns: Return a json found by the path or a null json with error
    */
    public subscript(path: SubscriptType...) -> JSON {
        get {
            return self[path]
        }
        set {
            self[path] = newValue
        }
    }
}

// MARK: - LiteralConvertible

extension JSON: Swift.StringLiteralConvertible {
	
	public init(stringLiteral value: StringLiteralType) {
		self.init(value)
	}
	
	public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
		self.init(value)
	}
	
	public init(unicodeScalarLiteral value: StringLiteralType) {
		self.init(value)
	}
}

extension JSON: Swift.IntegerLiteralConvertible {

	public init(integerLiteral value: IntegerLiteralType) {
		self.init(value)
	}
}

extension JSON: Swift.BooleanLiteralConvertible {
	
	public init(booleanLiteral value: BooleanLiteralType) {
		self.init(value)
	}
}

extension JSON: Swift.FloatLiteralConvertible {
	
	public init(floatLiteral value: FloatLiteralType) {
		self.init(value)
	}
}

extension JSON: Swift.DictionaryLiteralConvertible {
	
	public init(dictionaryLiteral elements: (String, AnyObject)...) {
		var dictionary_ = [String : AnyObject]()
		for (key_, value) in elements {
			dictionary_[key_] = value
		}
		self.init(dictionary_)
	}
}

extension JSON: Swift.ArrayLiteralConvertible {
	
	public init(arrayLiteral elements: AnyObject...) {
		self.init(elements)
	}
}

extension JSON: Swift.NilLiteralConvertible {
	
	public init(nilLiteral: ()) {
		self.init(NSNull())
	}
}

// MARK: - Raw

extension JSON: Swift.RawRepresentable {
	
	public init?(rawValue: AnyObject) {
		if JSON(rawValue).type == .Unknown {
			return nil
		} else {
			self.init(rawValue)
		}
	}
	
	public var rawValue: AnyObject {
		return self.object
	}

    public func rawData(options opt: NSJSONWritingOptions = NSJSONWritingOptions(rawValue: 0)) throws -> NSData {
        return try NSJSONSerialization.dataWithJSONObject(self.object, options: opt)
    }
    
    public func rawString(encoding: UInt = NSUTF8StringEncoding, options opt: NSJSONWritingOptions = .PrettyPrinted) -> String? {
        switch self.type {
        case .Array, .Dictionary:
            do {
                let data = try self.rawData(options: opt)
                return NSString(data: data, encoding: encoding) as? String
            } catch _ {
                return nil
            }
        case .String:
            return (self.object as! String)
        case .Number:
            return (self.object as! NSNumber).stringValue
        case .Bool:
            return (self.object as! Bool).description
        case .Null:
            return "null"
        default:
            return nil
        }
    }
}

// MARK: - Printable, DebugPrintable

extension JSON: Swift.Printable, Swift.DebugPrintable {
    
    public var description: String {
        if let string = self.rawString(options:.PrettyPrinted) {
            return string
        } else {
            return "unknown"
        }
    }
    
    public var debugDescription: String {
        return description
    }
}

// MARK: - Array

extension JSON {

    //Optional [JSON]
    public var array: [JSON]? {
        get {
            if self.type == .Array {
                return (self.object as! [AnyObject]).map{ JSON($0) }
            } else {
                return nil
            }
        }
    }
    
    //Non-optional [JSON]
    public var arrayValue: [JSON] {
        get {
            return self.array ?? []
        }
    }
    
    //Optional [AnyObject]
    public var arrayObject: [AnyObject]? {
        get {
            switch self.type {
            case .Array:
                return self.object as? [AnyObject]
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
    
    private func _map<Key:Hashable ,Value, NewValue>(source: [Key: Value], transform: Value -> NewValue) -> [Key: NewValue] {
        var result = [Key: NewValue](minimumCapacity:source.count)
        for (key,value) in source {
            result[key] = transform(value)
        }
        return result
    }

    //Optional [String : JSON]
    public var dictionary: [String : JSON]? {
        get {
            if self.type == .Dictionary {
                return _map(self.object as! [String : AnyObject]){ JSON($0) }
            } else {
                return nil
            }
        }
    }
    
    //Non-optional [String : JSON]
    public var dictionaryValue: [String : JSON] {
        get {
            return self.dictionary ?? [:]
        }
    }
    
    //Optional [String : AnyObject]
    public var dictionaryObject: [String : AnyObject]? {
        get {
            switch self.type {
            case .Dictionary:
                return self.object as? [String : AnyObject]
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

// MARK: - Bool

extension JSON: Swift.BooleanType {
    
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
            default:
                return false
            }
        }
        set {
            self.object = NSNumber(bool: newValue)
        }
    }
}

// MARK: - String

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
                return self.object as! String
            case .Number:
                return self.object.stringValue
            case .Bool:
                return (self.object as! Bool).description
            default:
                return ""
            }
        }
        set {
            self.object = NSString(string:newValue)
        }
    }
}

// MARK: - Number
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
            self.object = newValue?.copy() ?? NSNull()
        }
    }
    
    //Non-optional number
    public var numberValue: NSNumber {
        get {
            switch self.type {
            case .String:
                let scanner = NSScanner(string: self.object as! String)
                if scanner.scanDouble(nil){
                    if (scanner.atEnd) {
                        return NSNumber(double:(self.object as! NSString).doubleValue)
                    }
                }
                return NSNumber(double: 0.0)
            case .Number, .Bool:
                return self.object as! NSNumber
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

// MARK: - Int, Double, Float, Int8, Int16, Int32, Int64

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
extension JSON: Swift.Comparable {}

public func ==(lhs: JSON, rhs: JSON) -> Bool {
    
    switch (lhs.type, rhs.type) {
    case (.Number, .Number):
        return (lhs.object as! NSNumber) == (rhs.object as! NSNumber)
    case (.String, .String):
        return (lhs.object as! String) == (rhs.object as! String)
    case (.Bool, .Bool):
        return (lhs.object as! Bool) == (rhs.object as! Bool)
    case (.Array, .Array):
        return (lhs.object as! NSArray) == (rhs.object as! NSArray)
    case (.Dictionary, .Dictionary):
        return (lhs.object as! NSDictionary) == (rhs.object as! NSDictionary)
    case (.Null, .Null):
        return true
    default:
        return false
    }
}

public func <=(lhs: JSON, rhs: JSON) -> Bool {
    
    switch (lhs.type, rhs.type) {
    case (.Number, .Number):
        return (lhs.object as! NSNumber) <= (rhs.object as! NSNumber)
    case (.String, .String):
        return (lhs.object as! String) <= (rhs.object as! String)
    case (.Bool, .Bool):
        return (lhs.object as! Bool) == (rhs.object as! Bool)
    case (.Array, .Array):
        return (lhs.object as! NSArray) == (rhs.object as! NSArray)
    case (.Dictionary, .Dictionary):
        return (lhs.object as! NSDictionary) == (rhs.object as! NSDictionary)
    case (.Null, .Null):
        return true
    default:
        return false
    }
}

public func >=(lhs: JSON, rhs: JSON) -> Bool {
    
    switch (lhs.type, rhs.type) {
    case (.Number, .Number):
        return (lhs.object as! NSNumber) >= (rhs.object as! NSNumber)
    case (.String, .String):
        return (lhs.object as! String) >= (rhs.object as! String)
    case (.Bool, .Bool):
        return (lhs.object as! Bool) == (rhs.object as! Bool)
    case (.Array, .Array):
        return (lhs.object as! NSArray) == (rhs.object as! NSArray)
    case (.Dictionary, .Dictionary):
        return (lhs.object as! NSDictionary) == (rhs.object as! NSDictionary)
    case (.Null, .Null):
        return true
    default:
        return false
    }
}

public func >(lhs: JSON, rhs: JSON) -> Bool {
    
    switch (lhs.type, rhs.type) {
    case (.Number, .Number):
        return (lhs.object as! NSNumber) > (rhs.object as! NSNumber)
    case (.String, .String):
        return (lhs.object as! String) > (rhs.object as! String)
    default:
        return false
    }
}

public func <(lhs: JSON, rhs: JSON) -> Bool {
    
    switch (lhs.type, rhs.type) {
    case (.Number, .Number):
        return (lhs.object as! NSNumber) < (rhs.object as! NSNumber)
    case (.String, .String):
        return (lhs.object as! String) < (rhs.object as! String)
    default:
        return false
    }
}

private let trueNumber = NSNumber(bool: true)
private let falseNumber = NSNumber(bool: false)
private let trueObjCType = String.fromCString(trueNumber.objCType)
private let falseObjCType = String.fromCString(falseNumber.objCType)

// MARK: - NSNumber: Comparable

extension NSNumber: Swift.Comparable {
    var isBool:Bool {
        get {
            let objCType = String.fromCString(self.objCType)
            if (self.compare(trueNumber) == NSComparisonResult.OrderedSame && objCType == trueObjCType)
                || (self.compare(falseNumber) == NSComparisonResult.OrderedSame && objCType == falseObjCType){
                return true
            } else {
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
    return !(lhs == rhs)
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

@available(*, unavailable, renamed="JSON")
public typealias JSONValue = JSON

extension JSON {
    
    @available(*, unavailable, message="use 'init(_ object:AnyObject)' instead")
    public init(object: AnyObject) {
        self = JSON(object)
    }
    
    @available(*, unavailable, renamed="dictionaryObject")
    public var dictionaryObjects: [String : AnyObject]? {
        get { return self.dictionaryObject }
    }
    
    @available(*, unavailable, renamed="arrayObject")
    public var arrayObjects: [AnyObject]? {
        get { return self.arrayObject }
    }
    
    @available(*, unavailable, renamed="int8")
    public var char: Int8? {
        get {
            return self.number?.charValue
        }
    }
    
    @available(*, unavailable, renamed="int8Value")
    public var charValue: Int8 {
        get {
            return self.numberValue.charValue
        }
    }
    
    @available(*, unavailable, renamed="uInt8")
    public var unsignedChar: UInt8? {
        get{
            return self.number?.unsignedCharValue
        }
    }
    
    @available(*, unavailable, renamed="uInt8Value")
    public var unsignedCharValue: UInt8 {
        get{
            return self.numberValue.unsignedCharValue
        }
    }
    
    @available(*, unavailable, renamed="int16")
    public var short: Int16? {
        get{
            return self.number?.shortValue
        }
    }
    
    @available(*, unavailable, renamed="int16Value")
    public var shortValue: Int16 {
        get{
            return self.numberValue.shortValue
        }
    }
    
    @available(*, unavailable, renamed="uInt16")
    public var unsignedShort: UInt16? {
        get{
            return self.number?.unsignedShortValue
        }
    }
    
    @available(*, unavailable, renamed="uInt16Value")
    public var unsignedShortValue: UInt16 {
        get{
            return self.numberValue.unsignedShortValue
        }
    }
    
    @available(*, unavailable, renamed="int")
    public var long: Int? {
        get{
            return self.number?.longValue
        }
    }
    
    @available(*, unavailable, renamed="intValue")
    public var longValue: Int {
        get{
            return self.numberValue.longValue
        }
    }
    
    @available(*, unavailable, renamed="uInt")
    public var unsignedLong: UInt? {
        get{
            return self.number?.unsignedLongValue
        }
    }
    
    @available(*, unavailable, renamed="uIntValue")
    public var unsignedLongValue: UInt {
        get{
            return self.numberValue.unsignedLongValue
        }
    }
    
    @available(*, unavailable, renamed="int64")
    public var longLong: Int64? {
        get{
            return self.number?.longLongValue
        }
    }
    
    @available(*, unavailable, renamed="int64Value")
    public var longLongValue: Int64 {
        get{
            return self.numberValue.longLongValue
        }
    }
    
    @available(*, unavailable, renamed="uInt64")
    public var unsignedLongLong: UInt64? {
        get{
            return self.number?.unsignedLongLongValue
        }
    }
    
    @available(*, unavailable, renamed="uInt64Value")
    public var unsignedLongLongValue: UInt64 {
        get{
            return self.numberValue.unsignedLongLongValue
        }
    }
    
    @available(*, unavailable, renamed="int")
    public var integer: Int? {
        get {
            return self.number?.integerValue
        }
    }
    
    @available(*, unavailable, renamed="intValue")
    public var integerValue: Int {
        get {
            return self.numberValue.integerValue
        }
    }
    
    @available(*, unavailable, renamed="uInt")
    public var unsignedInteger: Int? {
        get {
            return self.number?.unsignedIntegerValue
        }
    }
    
    @available(*, unavailable, renamed="uIntValue")
    public var unsignedIntegerValue: Int {
        get {
            return self.numberValue.unsignedIntegerValue
        }
    }
}
