///  SwiftyJSON.swift
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
import CoreFoundation

// MARK: - Error

///Error domain
public let ErrorDomain: String = "SwiftyJSONErrorDomain"

///Error code
public let ErrorUnsupportedType: Int = 999
public let ErrorIndexOutOfBounds: Int = 900
public let ErrorWrongType: Int = 901
public let ErrorNotExist: Int = 500
public let ErrorInvalidJSON: Int = 490

// MARK: - JSON Type

/**
JSON's type definitions.

See http://www.json.org
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
    public init(data:NSData, options opt: NSJSONReadingOptions = .AllowFragments) {
        do {
            let object: Any = try NSJSONSerialization.JSONObjectWithData(data, options: opt)
            self.init(object)
        }
        catch {
            // For now do nothing with the error
            self.init(NSNull())
        }
    }

    /**
     Create a JSON from JSON string
    - parameter string: Normal json string like '{"a":"b"}'

    - returns: The created JSON
    */
    public static func parse(string:String) -> JSON {
        let data = string.bridge().dataUsingEncoding(NSUTF8StringEncoding)
        return data != nil ? JSON(data: data!) : JSON(NSNull())
    }

    /**
    Creates a JSON using the object.

    - parameter object:  The object must have the following properties: All objects are NSString/String, NSNumber/Int/Float/Double/Bool, NSArray/Array, NSDictionary/Dictionary, or NSNull; All dictionary keys are NSStrings/String; NSNumbers are not NaN or infinity.

    - returns: The created JSON
    */
    public init(_ object: Any) {
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

    /**
    Creates a JSON from a [String: JSON]

    - parameter jsonDictionary: A Swift dictionary of JSON objects

    - returns: The created JSON
    */
    public init(_ jsonDictionary:[String: JSON]) {
        var dictionary = [String: Any]()
        for (key, json) in jsonDictionary {
            dictionary[key] = json.object
        }
        self.init(dictionary.bridge())
    }

    /// Private object
    private var rawArray: [Any] = []
    private var rawBool: Bool = false
    private var rawDictionary: [String : Any] = [:]
    private var rawString: String = ""
    private var rawNumber: NSNumber = 0
    private var rawNull: NSNull = NSNull()
    /// Private type
    private var _type: Type = .Null
    /// prviate error
    private var _error: NSError? = nil

    /// Object in JSON
    public var object: Any {
        get {
            switch self.type {
            case .Array:
                return self.rawArray
            case .Dictionary:
                return self.rawDictionary
            case .String:
                return self.rawString
            case .Number:
                return self.rawNumber
            case .Bool:
                return self.rawBool
            default:
                return self.rawNull
            }
        }
        set {
            _error = nil
            let (type, value) = self.setObjectHelper(newValue)

            _type = type
            switch (type) {
                case .Array:
                    self.rawArray = value as! [Any]
                case .Bool:
                    self.rawBool = value as! Bool
                case .Dictionary:
                    self.rawDictionary = value as! [String:Any]
                case .Null:
                    break
                case .Number:
                    self.rawNumber = value as! NSNumber
                case .String:
                    self.rawString = value as! String
                case .Unknown:
                    _error = NSError(domain: ErrorDomain, code: ErrorUnsupportedType, userInfo: [NSLocalizedDescriptionKey: "It is a unsupported type"])
                    print("==> error=\(_error). type=\(newValue.dynamicType)")
            }
        }
    }

    private func setObjectHelper(newValue: Any) -> (Type, Any) {
      var type: Type
      var value: Any

      switch newValue {
      case let bool as Bool:
          type = .Bool
          value = bool
      case let number as NSNumber:
          type = .Number
          value = number
      case let number as Double:
          type = .Number
          value = NSNumber(double: number)
      case let number as Int:
          type = .Number
          value = NSNumber(long: number)
      case  let string as String:
          type = .String
          value = string
      case  let string as NSString:
          type = .String
          value = string.bridge()
      case  _ as NSNull:
          type = .Null
          value = ""
      case let array as NSArray:
          type = .Array
          value = array.bridge().map { $0 as Any }
      case let dictionary as NSDictionary:
          type = .Dictionary
          var dict = [String: Any]()
          dictionary.enumerateKeysAndObjectsUsingBlock() {(key: AnyObject, val: AnyObject, stop: UnsafeMutablePointer<ObjCBool>) in
            let keyStr = key as! NSString
            dict[keyStr.bridge()] = val
          }
          value = dict
      default:
          let mirror = Mirror(reflecting: newValue)
          if  mirror.displayStyle == .collection  {
              type = .Array
              value = mirror.children.map { $0.value as Any }
          }
          else if  mirror.displayStyle == .dictionary  {
              let children = mirror.children.map { $0.value }
              let elems = convertToKeyValues(children)
              if  children.count == elems.count  {
                  type = .Dictionary
                  var dict = [String: Any]()
                  for (key, val) in elems {
                      dict[key] = val as Any
                  }
                  value = dict
              }
              else {
                  type = .Unknown
                  value = ""
              }
          }
          else {
              type = .Unknown
              value = ""
          }
      }
      return (type, value)
    }

    private func convertToKeyValues(pairs: [Any]) -> [(String, Any)] {
       var result = [(String, Any)]()
       for pair in pairs {
          let pairMirror = Mirror(reflecting: pair)
          if  pairMirror.displayStyle == .tuple  &&  pairMirror.children.count == 2 {
              let generator = pairMirror.children.makeIterator()
              if  let key = generator.next()!.value as? String {
                  result.append((key, generator.next()!.value))
              }
              else {
                  break
              }
          }
       }
       return result
    }

    /// json type
    public var type: Type { get { return _type } }

    /// Error in JSON
    public var error: NSError? { get { return self._error } }

    /// The static null json
    @available(*, unavailable, renamed:"null")
    public static var nullJSON: JSON { get { return null } }
    public static var null: JSON { get { return JSON(NSNull() as AnyObject) } }

    internal static func stringFromNumber(number: NSNumber) -> String {
        let type = CFNumberGetType(unsafeBitCast(number, to: CFNumber.self))
        switch(type) {
            case kCFNumberFloat32Type:
                return String(number.floatValue)
            case kCFNumberFloat64Type:
                return String(number.doubleValue)
            default:
                return String(number.longLongValue)
        }
    }
}

// MARK: - CollectionType, SequenceType, Indexable
extension JSON : Swift.CollectionType, Swift.SequenceType, Swift.Indexable {

    public typealias Generator = JSONGenerator

    public typealias Index = JSONIndex

    public var startIndex: JSON.Index {
        switch self.type {
        case .Array:
            return JSONIndex(arrayIndex: self.rawArray.startIndex)
        case .Dictionary:
            return JSONIndex(dictionaryIndex: self.rawDictionary.startIndex)
        default:
            return JSONIndex()
        }
    }

    public var endIndex: JSON.Index {
        switch self.type {
        case .Array:
            return JSONIndex(arrayIndex: self.rawArray.endIndex)
        case .Dictionary:
            return JSONIndex(dictionaryIndex: self.rawDictionary.endIndex)
        default:
            return JSONIndex()
        }
    }

    public subscript (position: JSON.Index) -> Generator.Element {
        switch self.type {
        case .Array:
            return (String(position.arrayIndex), JSON(self.rawArray[position.arrayIndex!]))
        case .Dictionary:
            let (key, value) = self.rawDictionary[position.dictionaryIndex!]
            return (key, JSON(value))
        default:
            return ("", JSON.null)
        }
    }

    /// If `type` is `.Array` or `.Dictionary`, return `array.empty` or `dictonary.empty` otherwise return `true`.
    public var isEmpty: Bool {
        get {
            switch self.type {
            case .Array:
                return self.rawArray.isEmpty
            case .Dictionary:
                return self.rawDictionary.isEmpty
            default:
                return true
            }
        }
    }

    /// If `type` is `.Array` or `.Dictionary`, return `array.count` or `dictonary.count` otherwise return `0`.
    public var count: Int {
        switch self.type {
        case .Array:
            return self.rawArray.count
        case .Dictionary:
            return self.rawDictionary.count
        default:
            return 0
        }
    }

    public func underestimateCount() -> Int {
        switch self.type {
        case .Array:
            return self.rawArray.underestimatedCount
        case .Dictionary:
            return self.rawDictionary.underestimatedCount
        default:
            return 0
        }
    }

    /**
    If `type` is `.Array` or `.Dictionary`, return a generator over the elements like `Array` or `Dictionary`, otherwise return a generator over empty.

    - returns: Return a *generator* over the elements of JSON.
    */
    public func generate() -> Generator {
        return JSON.Generator(self)
    }
}

public struct JSONIndex: ForwardIndex, _Incrementable, Equatable, Comparable {

    let arrayIndex: Int?
    let dictionaryIndex: DictionaryIndex<String, Any>?

    let type: Type

    init(){
        self.arrayIndex = nil
        self.dictionaryIndex = nil
        self.type = .Unknown
    }

    init(arrayIndex: Int) {
        self.arrayIndex = arrayIndex
        self.dictionaryIndex = nil
        self.type = .Array
    }

    init(dictionaryIndex: DictionaryIndex<String, Any>) {
        self.arrayIndex = nil
        self.dictionaryIndex = dictionaryIndex
        self.type = .Dictionary
    }

    public func successor() -> JSONIndex {
        switch self.type {
        case .Array:
            return JSONIndex(arrayIndex: self.arrayIndex!.successor())
        case .Dictionary:
            return JSONIndex(dictionaryIndex: self.dictionaryIndex!.successor())
        default:
            return JSONIndex()
        }
    }
}

public func ==(lhs: JSONIndex, rhs: JSONIndex) -> Bool {
    switch (lhs.type, rhs.type) {
    case (.Array, .Array):
        return lhs.arrayIndex == rhs.arrayIndex
    case (.Dictionary, .Dictionary):
        return lhs.dictionaryIndex == rhs.dictionaryIndex
    default:
        return false
    }
}

public func <(lhs: JSONIndex, rhs: JSONIndex) -> Bool {
    switch (lhs.type, rhs.type) {
    case (.Array, .Array):
        return lhs.arrayIndex < rhs.arrayIndex
    case (.Dictionary, .Dictionary):
        return lhs.dictionaryIndex < rhs.dictionaryIndex
    default:
        return false
    }
}

public func <=(lhs: JSONIndex, rhs: JSONIndex) -> Bool {
    switch (lhs.type, rhs.type) {
    case (.Array, .Array):
        return lhs.arrayIndex <= rhs.arrayIndex
    case (.Dictionary, .Dictionary):
        return lhs.dictionaryIndex <= rhs.dictionaryIndex
    default:
        return false
    }
}

public func >=(lhs: JSONIndex, rhs: JSONIndex) -> Bool {
    switch (lhs.type, rhs.type) {
    case (.Array, .Array):
        return lhs.arrayIndex >= rhs.arrayIndex
    case (.Dictionary, .Dictionary):
        return lhs.dictionaryIndex >= rhs.dictionaryIndex
    default:
        return false
    }
}

public func >(lhs: JSONIndex, rhs: JSONIndex) -> Bool {
    switch (lhs.type, rhs.type) {
    case (.Array, .Array):
        return lhs.arrayIndex > rhs.arrayIndex
    case (.Dictionary, .Dictionary):
        return lhs.dictionaryIndex > rhs.dictionaryIndex
    default:
        return false
    }
}

public struct JSONGenerator : IteratorProtocol {

    public typealias Element = (String, JSON)

    private let type: Type
    private var dictionayGenerate: DictionaryIterator<String, Any>?
    private var arrayGenerate: IndexingIterator<[Any]>?
    private var arrayIndex: Int = 0

    init(_ json: JSON) {
        self.type = json.type
        if type == .Array {
            self.arrayGenerate = json.rawArray.makeIterator()
        }else {
            self.dictionayGenerate = json.rawDictionary.makeIterator()
        }
    }

    public mutating func next() -> JSONGenerator.Element? {
        switch self.type {
        case .Array:
            if let o = self.arrayGenerate?.next() {
                let result = (String(self.arrayIndex), JSON(o))
                self.arrayIndex += 1
                return result
            } else {
                return nil
            }
        case .Dictionary:
            if let (k, v): (String, Any) = self.dictionayGenerate?.next() {
                return (k, JSON(v))
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}

// MARK: - Subscript

/**
*  To mark both String and Int can be used in subscript.
*/
public enum JSONKey {
    case Index(Int)
    case Key(String)
}

public protocol JSONSubscriptType {
    var jsonKey:JSONKey { get }
}

extension Int: JSONSubscriptType {
    public var jsonKey:JSONKey {
        return JSONKey.Index(self)
    }
}

extension String: JSONSubscriptType {
    public var jsonKey:JSONKey {
        return JSONKey.Key(self)
    }
}

extension JSON {

    /// If `type` is `.Array`, return json which's object is `array[index]`, otherwise return null json with error.
    private subscript(index index: Int) -> JSON {
        get {
            if self.type != .Array {
                var r = JSON.null
                r._error = self._error ?? NSError(domain: ErrorDomain, code: ErrorWrongType, userInfo: [NSLocalizedDescriptionKey: "Array[\(index)] failure, It is not an array"])
                return r
            } else if index >= 0 && index < self.rawArray.count {
                return JSON(self.rawArray[index])
            } else {
                var r = JSON.null
                r._error = NSError(domain: ErrorDomain, code:ErrorIndexOutOfBounds , userInfo: [NSLocalizedDescriptionKey: "Array[\(index)] is out of bounds"])
                return r
            }
        }
        set {
            if self.type == .Array {
                if self.rawArray.count > index && newValue.error == nil {
                    self.rawArray[index] = newValue.object
                }
            }
        }
    }

    /// If `type` is `.Dictionary`, return json which's object is `dictionary[key]` , otherwise return null json with error.
    private subscript(key key: String) -> JSON {
        get {
            var r = JSON.null
            if self.type == .Dictionary {
                if let o = self.rawDictionary[key] {
                    r = JSON(o)
                } else {
                    r._error = NSError(domain: ErrorDomain, code: ErrorNotExist, userInfo: [NSLocalizedDescriptionKey: "Dictionary[\"\(key)\"] does not exist"])
                }
            } else {
                r._error = self._error ?? NSError(domain: ErrorDomain, code: ErrorWrongType, userInfo: [NSLocalizedDescriptionKey: "Dictionary[\"\(key)\"] failure, It is not an dictionary"])
            }
            return r
        }
        set {
            if self.type == .Dictionary && newValue.error == nil {
                self.rawDictionary[key] = newValue.object
            }
        }
    }

    /// If `sub` is `Int`, return `subscript(index:)`; If `sub` is `String`,  return `subscript(key:)`.
    private subscript(sub sub: JSONSubscriptType) -> JSON {
        get {
            switch sub.jsonKey {
            case .Index(let index): return self[index: index]
            case .Key(let key): return self[key: key]
            }
        }
        set {
            switch sub.jsonKey {
            case .Index(let index): self[index: index] = newValue
            case .Key(let key): self[key: key] = newValue
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
    public subscript(path: [JSONSubscriptType]) -> JSON {
        get {
            return path.reduce(self) { $0[sub: $1] }
        }
        set {
            switch path.count {
            case 0:
                return
            case 1:
                self[sub:path[0]].object = newValue.object
            default:
                var aPath = path; aPath.remove(at: 0)
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
    public subscript(path: JSONSubscriptType...) -> JSON {
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

    public init(dictionaryLiteral elements: (String, Any)...) {
        self.init(elements.reduce([String : Any]()){(dictionary: [String : Any], element:(String, Any)) -> [String : Any] in
            var d = dictionary
            d[element.0] = element.1
            return d
            })
    }
}

extension JSON: Swift.ArrayLiteralConvertible {

    public init(arrayLiteral elements: Any...) {
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

    public init?(rawValue: Any) {
        if JSON(rawValue).type == .Unknown {
            return nil
        } else {
            self.init(rawValue)
        }
    }

    public var rawValue: Any {
        return self.object
    }

    public func rawData(options opt: NSJSONWritingOptions = NSJSONWritingOptions(rawValue: 0)) throws -> NSData {
        guard LclJSONSerialization.isValidJSONObject(self.object) else {
            throw NSError(domain: ErrorDomain, code: ErrorInvalidJSON, userInfo: [NSLocalizedDescriptionKey: "JSON is invalid"])
        }
        return try LclJSONSerialization.dataWithJSONObject(self.object, options: opt)
    }

    public func rawString(encoding: UInt = NSUTF8StringEncoding, options opt: NSJSONWritingOptions = .PrettyPrinted) -> String? {
        switch self.type {
        case .Array, .Dictionary:
            do {
                let data = try self.rawData(options: opt)
                return NSString(data: data, encoding: encoding)?.bridge()
            } catch _ {
                return nil
            }
        case .String:
            return self.rawString
        case .Number:
            return JSON.stringFromNumber(self.rawNumber)
        case .Bool:
            return self.rawBool.description
        case .Null:
            return "null"
        default:
            return nil
        }
    }
}

// MARK: - Printable, DebugPrintable

extension JSON {

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
                return self.rawArray.map{ JSON($0) }
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
    public var arrayObject: [Any]? {
        get {
            switch self.type {
            case .Array:
                return self.rawArray
            default:
                return nil
            }
        }
        set {
            if let array = newValue {
                self.object = array
            } else {
                self.object = NSNull()
            }
        }
    }
}

// MARK: - Dictionary

extension JSON {

    //Optional [String : JSON]
    public var dictionary: [String : JSON]? {
        if self.type == .Dictionary {
            return self.rawDictionary.reduce([String : JSON]()) { (dictionary: [String : JSON], element: (String, Any)) -> [String : JSON] in
                var d = dictionary
                d[element.0] = JSON(element.1)
                return d
            }
        } else {
            return nil
        }
    }

    //Non-optional [String : JSON]
    public var dictionaryValue: [String : JSON] {
        return self.dictionary ?? [:]
    }

    //Optional [String : AnyObject]
    public var dictionaryObject: [String : Any]? {
        get {
            switch self.type {
            case .Dictionary:
                return self.rawDictionary
            default:
                return nil
            }
        }
        set {
            if let v = newValue {
                self.object = v as Any
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
                return self.rawBool
            default:
                return nil
            }
        }
        set {
            if let newValue = newValue {
                self.object = newValue
            } else {
                self.object = NSNull()
            }
        }
    }

    //Non-optional bool
    public var boolValue: Bool {
        get {
            switch self.type {
            case .Bool:
                return self.rawBool
            case .Number:
                return self.rawNumber.boolValue
            case .String:
                return self.rawString.bridge().caseInsensitiveCompare("true") == .OrderedSame
            default:
                return false
            }
        }
        set {
            self.object = newValue
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
            if let newValue = newValue {
                self.object = NSString(string:newValue)
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
                return self.object as? String ?? ""
            case .Number:
                return JSON.stringFromNumber(self.object as! NSNumber)
            case .Bool:
                return String(self.object as! Bool) ?? ""
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
            case .Number:
                return self.rawNumber
            case .Bool:
                return NSNumber(bool: self.rawBool)
            default:
                return nil
            }
        }
        set {
            self.object = newValue ?? NSNull()
        }
    }

    //Non-optional number
    public var numberValue: NSNumber {
        get {
            switch self.type {
            case .String:
                if  let decimal = Double(self.object as! String)  {
                    return NSNumber(double: decimal)
                }
                else {  // indicates parse error
                    return NSNumber(double: 0.0)
                }
            case .Number:
                return self.object as? NSNumber ?? NSNumber(int: 0)
            case .Bool:
                return NSNumber(bool: self.object as! Bool)
            default:
                return NSNumber(double: 0.0)
            }
        }
        set {
            self.object = newValue
        }
    }
}

//MARK: - Null
extension JSON {

    public var null: NSNull? {
        get {
            switch self.type {
            case .Null:
                return self.rawNull
            default:
                return nil
            }
        }
        set {
            self.object = NSNull()
        }
    }
    public func isExists() -> Bool{
        if let errorValue = error where errorValue.code == ErrorNotExist{
            return false
        }
        return true
    }
}

//MARK: - URL
extension JSON {

    //Optional URL
    public var URL: NSURL? {
        get {
            switch self.type {
            case .String:
                if let encodedString_ = self.rawString.bridge().stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
                    return NSURL(string: encodedString_)
                } else {
                    return nil
                }
            default:
                return nil
            }
        }
        set {
            self.object = newValue?.absoluteString.bridge() ?? NSNull()
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
            if let newValue = newValue {
                self.object = NSNumber(double: newValue)
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
            if let newValue = newValue {
                self.object = NSNumber(float: newValue)
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
            if let newValue = newValue {
                self.object = NSNumber(integer: newValue)
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
            if let newValue = newValue {
                self.object = NSNumber(unsignedLong: newValue)
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
            if let newValue = newValue {
                self.object = NSNumber(char: newValue)
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
            if let newValue = newValue {
                self.object = NSNumber(unsignedChar: newValue)
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
            if let newValue = newValue {
                self.object = NSNumber(short: newValue)
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
            if let newValue = newValue {
                self.object = NSNumber(unsignedShort: newValue)
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
            if let newValue = newValue {
                self.object = NSNumber(int: newValue)
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
            if let newValue = newValue {
                self.object = NSNumber(unsignedInt: newValue)
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
            if let newValue = newValue {
                self.object = NSNumber(longLong: newValue)
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
            if let newValue = newValue {
                self.object = NSNumber(unsignedLongLong: newValue)
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
extension JSON : Swift.Comparable {}

public func ==(lhs: JSON, rhs: JSON) -> Bool {

    switch (lhs.type, rhs.type) {
    case (.Number, .Number):
        return lhs.rawNumber == rhs.rawNumber
    case (.String, .String):
        return lhs.rawString == rhs.rawString
    case (.Bool, .Bool):
        return lhs.rawBool == rhs.rawBool
    case (.Array, .Array):
        return lhs.rawArray.bridge() == rhs.rawArray.bridge()
    case (.Dictionary, .Dictionary):
        return lhs.rawDictionary.bridge() == rhs.rawDictionary.bridge()
    case (.Null, .Null):
        return true
    default:
        return false
    }
}

public func <=(lhs: JSON, rhs: JSON) -> Bool {

    switch (lhs.type, rhs.type) {
    case (.Number, .Number):
        return lhs.rawNumber <= rhs.rawNumber
    case (.String, .String):
        return lhs.rawString <= rhs.rawString
    case (.Bool, .Bool):
        return lhs.rawBool == rhs.rawBool
    case (.Array, .Array):
        return lhs.rawArray.bridge() == rhs.rawArray.bridge()
    case (.Dictionary, .Dictionary):
        return lhs.rawDictionary.bridge() == rhs.rawDictionary.bridge()
    case (.Null, .Null):
        return true
    default:
        return false
    }
}

public func >=(lhs: JSON, rhs: JSON) -> Bool {

    switch (lhs.type, rhs.type) {
    case (.Number, .Number):
        return lhs.rawNumber >= rhs.rawNumber
    case (.String, .String):
        return lhs.rawString >= rhs.rawString
    case (.Bool, .Bool):
        return lhs.rawBool == rhs.rawBool
    case (.Array, .Array):
        return lhs.rawArray.bridge() == rhs.rawArray.bridge()
    case (.Dictionary, .Dictionary):
        return lhs.rawDictionary.bridge() == rhs.rawDictionary.bridge()
    case (.Null, .Null):
        return true
    default:
        return false
    }
}

public func >(lhs: JSON, rhs: JSON) -> Bool {

    switch (lhs.type, rhs.type) {
    case (.Number, .Number):
        return lhs.rawNumber > rhs.rawNumber
    case (.String, .String):
        return lhs.rawString > rhs.rawString
    default:
        return false
    }
}

public func <(lhs: JSON, rhs: JSON) -> Bool {

    switch (lhs.type, rhs.type) {
    case (.Number, .Number):
        return lhs.rawNumber < rhs.rawNumber
    case (.String, .String):
        return lhs.rawString < rhs.rawString
    default:
        return false
    }
}

private let trueNumber = NSNumber(bool: true)
private let falseNumber = NSNumber(bool: false)

// MARK: - NSNumber: Comparable

extension NSNumber {
    var isBool:Bool {
        get {
            let type = CFNumberGetType(unsafeBitCast(self, to: CFNumber.self))
            if  type == kCFNumberSInt8Type  &&
                  (self.compare(trueNumber) == NSComparisonResult.OrderedSame  ||
                   self.compare(falseNumber) == NSComparisonResult.OrderedSame){
                    return true
            } else {
                return false
            }
        }
    }
}

func ==(lhs: NSNumber, rhs: NSNumber) -> Bool {
    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) == NSComparisonResult.OrderedSame
    }
}

func !=(lhs: NSNumber, rhs: NSNumber) -> Bool {
    return !(lhs == rhs)
}

func <(lhs: NSNumber, rhs: NSNumber) -> Bool {

    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) == NSComparisonResult.OrderedAscending
    }
}

func >(lhs: NSNumber, rhs: NSNumber) -> Bool {

    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) == NSComparisonResult.OrderedDescending
    }
}

func <=(lhs: NSNumber, rhs: NSNumber) -> Bool {

    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) != NSComparisonResult.OrderedDescending
    }
}

func >=(lhs: NSNumber, rhs: NSNumber) -> Bool {

    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) != NSComparisonResult.OrderedAscending
    }
}
