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

public enum SwiftyJSONError: Error {
    case empty
    case errorInvalidJSON(String)
}

// MARK: - JSON Type

/**
JSON's type definitions.

See http://www.json.org
*/
public enum Type :Int{

    case number
    case string
    case bool
    case array
    case dictionary
    case null
    case unknown
}

// MARK: - JSON Base

public struct JSON {


    /**
    Creates a JSON using the data.
    - parameter data:  The Data used to convert to json.Top level object in data is an NSArray or NSDictionary
    - parameter opt:   The JSON serialization reading options. `.AllowFragments` by default.
    - returns: The created JSON
    */
    public init(data: Data, options opt: JSONSerialization.ReadingOptions = .allowFragments) {
        do {
            let object: Any = try JSONSerialization.jsonObject(with: data, options: opt)
            self.init(object)
        }
        catch {
            // For now do nothing with the error
            self.init(NSNull() as Any)
        }
    }


    /**
     Create a JSON from JSON string
    - parameter string: Normal json string like '{"a":"b"}'

    - returns: The created JSON
    */
    public static func parse(string:String) -> JSON {
        return string.data(using: String.Encoding.utf8).flatMap({JSON(data: $0)}) ?? JSON(NSNull())
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
        self.init(jsonArray.map { $0.object } as Any)
    }

    /**
    Creates a JSON from a [String: JSON]

    - parameter jsonDictionary: A Swift dictionary of JSON objects

    - returns: The created JSON
    */
    public init(_ jsonDictionary:[String: JSON]) {
        var dictionary = [String: Any](minimumCapacity: jsonDictionary.count)

        for (key, json) in jsonDictionary {
            dictionary[key] = json.object
        }
        self.init(dictionary as Any)
    }

    /// Private object
    var rawString: String = ""
    var rawNumber: NSNumber = 0
    var rawNull: NSNull = NSNull()
    var rawArray: [Any] = []
    var rawDictionary: [String : Any] = [:]
    var rawBool: Bool = false
    /// Private type
    var _type: Type = .null
    /// prviate error
    var _error: NSError? = nil


    /// Object in JSON
    public var object: Any {
        get {
            switch self.type {
            case .array:
                return self.rawArray
            case .dictionary:
                return self.rawDictionary
            case .string:
                return self.rawString
            case .number:
                return self.rawNumber
            case .bool:
                return self.rawBool
            default:
                return self.rawNull
            }
        }

        set {
            _error = nil

#if os(Linux)
            let (type, value) = self.setObjectHelper(newValue)

            _type = type
            switch (type) {
                case .array:
                    self.rawArray = value as! [Any]
                case .bool:
                    self.rawBool = value as! Bool
                    if let number = newValue as? NSNumber {
                        self.rawNumber = number
                    }
                    else {
                        self.rawNumber = self.rawBool ? NSNumber(value: 1) : NSNumber(value: 0)
                    }
                case .dictionary:
                    self.rawDictionary = value as! [String:Any]
                case .null:
                    break
                case .number:
                    self.rawNumber = value as! NSNumber
                case .string:
                    self.rawString = value as! String
                case .unknown:
                    _error = NSError(domain: ErrorDomain, code: ErrorUnsupportedType, userInfo: [NSLocalizedDescriptionKey: "It is a unsupported type"])
                    print("==> error=\(_error). type=\(type(of: newValue))")
            }
#else
            if  type(of: newValue) == Bool.self {
                _type = .bool
                self.rawBool = newValue as! Bool
            }
            else {
                switch newValue {
                case let number as NSNumber:
                    if number.isBool {
                        _type = .bool
                        self.rawBool = number.boolValue
                    } else {
                        _type = .number
                        self.rawNumber = number
                    }
                case  let string as String:
                    _type = .string
                    self.rawString = string
                case  _ as NSNull:
                    _type = .null
                case let array as [Any]:
                    _type = .array
                    self.rawArray = array
                case let dictionary as [String : Any]:
                    _type = .dictionary
                    self.rawDictionary = dictionary
                default:
                    _type = .unknown
                    _error = NSError(domain: ErrorDomain, code: ErrorUnsupportedType, userInfo: [NSLocalizedDescriptionKey as NSObject: "It is a unsupported type"])
                }
            }

#endif
        }
    }

#if os(Linux)
    private func setObjectHelper(_ newValue: Any) -> (Type, Any) {
      var type: Type
      var value: Any

      switch newValue {
      case let bool as Bool:
          type = .bool
          value = bool
      case let number as NSNumber:
          if number.isBool {
            type = .bool
            value = number.boolValue
          } else {
            type = .number
            value = number
          }
      case let number as Double:
          type = .number
          value = NSNumber(value: number)
      case let number as Int:
          type = .number
          value = NSNumber(value: number)
      case  let string as String:
          type = .string
          value = string
      case  let string as NSString:
          type = .string
          value = string._bridgeToSwift()
      case  _ as NSNull:
          type = .null
          value = ""
      case let array as NSArray:
          type = .array
          value = array._bridgeToSwift().map { $0 as Any }
      case let dictionary as NSDictionary:
          type = .dictionary
          var dict = [String: Any]()
          dictionary.enumerateKeysAndObjects(using: {(key: Any, val: Any, stop: UnsafeMutablePointer<ObjCBool>) in
                let keyStr = key as! String
                dict[keyStr] = val
          })
          value = dict
      default:
          let mirror = Mirror(reflecting: newValue)
          if  mirror.displayStyle == .collection  {
              type = .array
              value = mirror.children.map { $0.value as Any }
          }
          else if  mirror.displayStyle == .dictionary  {
              let children = mirror.children.map { $0.value }
              let elems = convertToKeyValues(children)
              if  children.count == elems.count  {
                  type = .dictionary
                  var dict = [String: Any]()
                  for (key, val) in elems {
                      dict[key] = val as Any
                  }
                  value = dict
              }
              else {
                  type = .unknown
                  value = ""
              }
          }
          else {
              type = .unknown
              value = ""
          }
      }
      return (type, value)
    }

    private func convertToKeyValues(_ pairs: [Any]) -> [(String, Any)] {
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

#endif

    /// json type
    public var type: Type { get { return _type } }

    /// Error in JSON
    public var error: NSError? { get { return self._error } }

    /// The static null json
    @available(*, unavailable, renamed:"null")
    public static var nullJSON: JSON { get { return null } }
    public static var null: JSON { get { return JSON(NSNull() as Any) } }
#if os(Linux)
    internal static func stringFromNumber(_ number: NSNumber) -> String {
        let type = CFNumberGetType(unsafeBitCast(number, to: CFNumber.self))
        switch(type) {
            case kCFNumberFloat32Type:
                return String(number.floatValue)
            case kCFNumberFloat64Type:
                return String(number.doubleValue)
            default:
                return String(number.int64Value)
        }
    }
#endif
}

// MARK: - CollectionType, SequenceType
extension JSON : Collection, Sequence {

    public typealias Generator = JSONGenerator

    public typealias Index = JSONIndex

    public var startIndex: JSON.Index {
        switch self.type {
        case .array:
            return JSONIndex(arrayIndex: self.rawArray.startIndex)
        case .dictionary:
            return JSONIndex(dictionaryIndex: self.rawDictionary.startIndex)
        default:
            return JSONIndex()
        }
    }

    public var endIndex: JSON.Index {
        switch self.type {
        case .array:
            return JSONIndex(arrayIndex: self.rawArray.endIndex)
        case .dictionary:
            return JSONIndex(dictionaryIndex: self.rawDictionary.endIndex)
        default:
            return JSONIndex()
        }
    }

    public func index(after i: JSON.Index) -> JSON.Index {
        switch self.type {
        case .array:
            return JSONIndex(arrayIndex: self.rawArray.index(after: i.arrayIndex!))
        case .dictionary:
            return JSONIndex(dictionaryIndex: self.rawDictionary.index(after: i.dictionaryIndex!))
        default:
            return JSONIndex()
        }
    }

    public subscript (position: JSON.Index) -> Generator.Element {
        switch self.type {
        case .array:
            return (String(describing: position.arrayIndex), JSON(self.rawArray[position.arrayIndex!]))
        case .dictionary:
            let (key, value) = self.rawDictionary[position.dictionaryIndex!]
            return (key, JSON(value))
        default:
            return ("", JSON.null)
        }
    }

    /// If `type` is `.Array` or `.Dictionary`, return `array.isEmpty` or `dictonary.isEmpty` otherwise return `true`.
    public var isEmpty: Bool {
        get {
            switch self.type {
            case .array:
                return self.rawArray.isEmpty
            case .dictionary:
                return self.rawDictionary.isEmpty
            default:
                return true
            }
        }
    }

    /// If `type` is `.Array` or `.Dictionary`, return `array.count` or `dictonary.count` otherwise return `0`.
    public var count: Int {
        switch self.type {
        case .array:
            return self.rawArray.count
        case .dictionary:
            return self.rawDictionary.count
        default:
            return 0
        }
    }

    public func underestimateCount() -> Int {
        switch self.type {
        case .array:
            return self.rawArray.underestimatedCount
        case .dictionary:
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

public struct JSONIndex: _Incrementable, Equatable, Comparable {
    let arrayIndex: Array<Any>.Index?
    let dictionaryIndex: DictionaryIndex<String, Any>?
    let type: Type

    init(){
        self.arrayIndex = nil
        self.dictionaryIndex = nil
        self.type = .unknown
    }

    init(arrayIndex: Array<Any>.Index) {
        self.arrayIndex = arrayIndex
        self.dictionaryIndex = nil
        self.type = .array
    }

    init(dictionaryIndex: DictionaryIndex<String, Any>) {
        self.arrayIndex = nil
        self.dictionaryIndex = dictionaryIndex
        self.type = .dictionary
    }
}

public func ==(lhs: JSONIndex, rhs: JSONIndex) -> Bool {
    switch (lhs.type, rhs.type) {
    case (.array, .array):
        return lhs.arrayIndex == rhs.arrayIndex
    case (.dictionary, .dictionary):
        return lhs.dictionaryIndex == rhs.dictionaryIndex
    default:
        return false
    }
}

public func <(lhs: JSONIndex, rhs: JSONIndex) -> Bool {
    switch (lhs.type, rhs.type) {
    case (.array, .array):
        guard let lhsArrayIndex = lhs.arrayIndex,
                    let rhsArrayIndex = rhs.arrayIndex  else { return false }
        return lhsArrayIndex < rhsArrayIndex
    case (.dictionary, .dictionary):
        guard let lhsDictionaryIndex = lhs.dictionaryIndex,
            let rhsDictionaryIndex = rhs.dictionaryIndex  else { return false }
        return lhsDictionaryIndex < rhsDictionaryIndex
    default:
        return false
    }
}

public func <=(lhs: JSONIndex, rhs: JSONIndex) -> Bool {
    switch (lhs.type, rhs.type) {
    case (.array, .array):
        guard let lhsArrayIndex = lhs.arrayIndex,
            let rhsArrayIndex = rhs.arrayIndex  else { return false }
        return lhsArrayIndex < rhsArrayIndex
    case (.dictionary, .dictionary):
        guard let lhsDictionaryIndex = lhs.dictionaryIndex,
            let rhsDictionaryIndex = rhs.dictionaryIndex  else { return false }
        return lhsDictionaryIndex < rhsDictionaryIndex
    default:
        return false
    }
}

public func >=(lhs: JSONIndex, rhs: JSONIndex) -> Bool {
    switch (lhs.type, rhs.type) {
    case (.array, .array):
        guard let lhsArrayIndex = lhs.arrayIndex,
            let rhsArrayIndex = rhs.arrayIndex  else { return false }
        return lhsArrayIndex < rhsArrayIndex
    case (.dictionary, .dictionary):
        guard let lhsDictionaryIndex = lhs.dictionaryIndex,
            let rhsDictionaryIndex = rhs.dictionaryIndex  else { return false }
        return lhsDictionaryIndex < rhsDictionaryIndex
    default:
        return false
    }
}

public func >(lhs: JSONIndex, rhs: JSONIndex) -> Bool {
    switch (lhs.type, rhs.type) {
    case (.array, .array):
        guard let lhsArrayIndex = lhs.arrayIndex,
            let rhsArrayIndex = rhs.arrayIndex  else { return false }
        return lhsArrayIndex < rhsArrayIndex
    case (.dictionary, .dictionary):
        guard let lhsDictionaryIndex = lhs.dictionaryIndex,
            let rhsDictionaryIndex = rhs.dictionaryIndex  else { return false }
        return lhsDictionaryIndex < rhsDictionaryIndex
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
        if type == .array {
            self.arrayGenerate = json.rawArray.makeIterator()
        }else {
            self.dictionayGenerate = json.rawDictionary.makeIterator()
        }
    }

    public mutating func next() -> JSONGenerator.Element? {
        switch self.type {
        case .array:
            if let o = self.arrayGenerate?.next() {
                let i = self.arrayIndex
                self.arrayIndex += 1
                return (String(i), JSON(o))
            } else {
                return nil
            }
        case .dictionary:
            guard let (k, v): (String, Any) = self.dictionayGenerate?.next() else {
                return nil
            }
            return (k, JSON(v))

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
    case index(Int)
    case key(String)
}

public protocol JSONSubscriptType {
    var jsonKey:JSONKey { get }
}

extension Int: JSONSubscriptType {
    public var jsonKey:JSONKey {
        return JSONKey.index(self)
    }
}

extension String: JSONSubscriptType {
    public var jsonKey:JSONKey {
        return JSONKey.key(self)
    }
}

extension JSON {

    /// If `type` is `.Array`, return json whose object is `array[index]`, otherwise return null json with error.
    private subscript(index index: Int) -> JSON {
        get {
            if self.type != .array {
                var r = JSON.null
                r._error = self._error ?? NSError(domain: ErrorDomain, code: ErrorWrongType, userInfo: [NSLocalizedDescriptionKey: "Array[\(index)] failure, It is not an array" as Any])
                return r
            } else if index >= 0 && index < self.rawArray.count {
                return JSON(self.rawArray[index])
            } else {
                var r = JSON.null
#if os(Linux)
                r._error = NSError(domain: ErrorDomain, code:ErrorIndexOutOfBounds, userInfo: [NSLocalizedDescriptionKey: "Array[\(index)] is out of bounds" as Any])
#else
                r._error = NSError(domain: ErrorDomain, code:ErrorIndexOutOfBounds, userInfo: [NSLocalizedDescriptionKey as AnyObject as! NSObject: "Array[\(index)] is out of bounds" as AnyObject])
#endif
                return r
            }
        }
        set {
            if self.type == .array {
                if self.rawArray.count > index && newValue.error == nil {
                    self.rawArray[index] = newValue.object
                }
            }
        }
    }

    /// If `type` is `.Dictionary`, return json whose object is `dictionary[key]` , otherwise return null json with error.
    private subscript(key key: String) -> JSON {
        get {
            var r = JSON.null
            if self.type == .dictionary {
                if let o = self.rawDictionary[key] {
                    r = JSON(o)
                } else {
#if os(Linux)
                    r._error = NSError(domain: ErrorDomain, code: ErrorNotExist, userInfo: [NSLocalizedDescriptionKey: "Dictionary[\"\(key)\"] does not exist" as Any])
#else
                    r._error = NSError(domain: ErrorDomain, code: ErrorNotExist, userInfo: [NSLocalizedDescriptionKey as NSObject: "Dictionary[\"\(key)\"] does not exist" as AnyObject])
#endif
                }
            } else {
#if os(Linux)
                r._error = self._error ?? NSError(domain: ErrorDomain, code: ErrorWrongType, userInfo: [NSLocalizedDescriptionKey: "Dictionary[\"\(key)\"] failure, It is not an dictionary" as Any])
#else
                r._error = self._error ?? NSError(domain: ErrorDomain, code: ErrorWrongType, userInfo: [NSLocalizedDescriptionKey as NSObject: "Dictionary[\"\(key)\"] failure, It is not an dictionary" as AnyObject])
#endif
            }
            return r
        }
        set {
            if self.type == .dictionary && newValue.error == nil {
                self.rawDictionary[key] = newValue.object
            }
        }
    }

    /// If `sub` is `Int`, return `subscript(index:)`; If `sub` is `String`,  return `subscript(key:)`.
    private subscript(sub sub: JSONSubscriptType) -> JSON {
        get {
            switch sub.jsonKey {
            case .index(let index): return self[index: index]
            case .key(let key): return self[key: key]
            }
        }
        set {
            switch sub.jsonKey {
            case .index(let index): self[index: index] = newValue
            case .key(let key): self[key: key] = newValue
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
                self.object = newValue.object
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
    Find a json in the complex data structures by using the Int/String's array.

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
        self.init(value as Any)
    }

    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(value as Any)
    }

    public init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(value as Any)
    }
}

extension JSON: Swift.IntegerLiteralConvertible {

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value as Any)
    }
}

extension JSON: Swift.BooleanLiteralConvertible {

    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value as Any)
    }
}

extension JSON: Swift.FloatLiteralConvertible {

    public init(floatLiteral value: FloatLiteralType) {
        self.init(value as Any)
    }
}

extension JSON: Swift.DictionaryLiteralConvertible {

    public init(dictionaryLiteral elements: (String, Any)...) {
        self.init(elements.reduce([String : Any](minimumCapacity: elements.count)){(dictionary: [String : Any], element:(String, Any)) -> [String : Any] in
            var d = dictionary
            d[element.0] = element.1
            return d
            } as Any)
    }
}

extension JSON: Swift.ArrayLiteralConvertible {

    public init(arrayLiteral elements: Any...) {
        self.init(elements as Any)
    }
}

extension JSON: Swift.NilLiteralConvertible {

    public init(nilLiteral: ()) {
        self.init(NSNull() as Any)
    }
}

// MARK: - Raw

extension JSON: Swift.RawRepresentable {

    public init?(rawValue: Any) {
        if JSON(rawValue).type == .unknown {
            return nil
        } else {
            self.init(rawValue)
        }
    }

    public var rawValue: Any {
        return self.object
    }
#if os(Linux)
    public func rawData(options opt: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions(rawValue: 0)) throws -> Data {
        guard LclJSONSerialization.isValidJSONObject(self.object) else {
            throw SwiftyJSONError.errorInvalidJSON("JSON is invalid")
        }

        return try LclJSONSerialization.dataWithJSONObject(self.object, options: opt)
    }
#else
    public func rawData(options opt: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions(rawValue: 0)) throws -> Data {
        guard JSONSerialization.isValidJSONObject(self.object) else {
            throw SwiftyJSONError.errorInvalidJSON("JSON is invalid")
        }

        return try JSONSerialization.data(withJSONObject: self.object, options: opt)
    }
#endif

#if os(Linux)
    public func rawString(encoding: String.Encoding = String.Encoding.utf8, options opt: JSONSerialization.WritingOptions = .prettyPrinted) -> String? {
        switch self.type {
        case .array, .dictionary:
            do {
                let data = try self.rawData(options: opt)
                return String(data: data, encoding: encoding)
            } catch _ {
                return nil
            }
        case .string:
            return self.rawString
        case .number:
            return JSON.stringFromNumber(self.rawNumber)
        case .bool:
            return self.rawBool.description
        case .null:
            return "null"
        default:
            return nil
        }
    }
#else
    public func rawString(encoding: String.Encoding = String.Encoding.utf8, options opt: JSONSerialization.WritingOptions = .prettyPrinted) -> String? {
        switch self.type {
        case .array, .dictionary:
            do {
                let data = try self.rawData(options: opt)
                return String(data: data, encoding: encoding)
            } catch _ {
                return nil
            }
        case .string:
            return self.rawString
        case .number:
            return self.rawNumber.stringValue
        case .bool:
            return self.rawBool.description
        case .null:
            return "null"
        default:
            return nil
        }
    }
#endif
}

// MARK: - Printable, DebugPrintable

extension JSON {

    public var description: String {
        let prettyString = self.rawString(options:.prettyPrinted)
        if let string = prettyString {
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
            if self.type == .array {
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

    //Optional [AnyType]
    public var arrayObject: [Any]? {
        get {
            switch self.type {
            case .array:
                return self.rawArray
            default:
                return nil
            }
        }
        set {
            if let array = newValue {
                self.object = array as Any
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
        if self.type == .dictionary {
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

    //Optional [String : AnyType]
    public var dictionaryObject: [String : Any]? {
        get {
            switch self.type {
            case .dictionary:
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

extension JSON {

    //Optional bool
    public var bool: Bool? {
        get {
            switch self.type {
            case .bool:
                return self.rawBool
            default:
                return nil
            }
        }
        set {
            if let newValue = newValue {
                self.object = newValue as Bool
            } else {
                self.object = NSNull()
            }
        }
    }

    //Non-optional bool
    public var boolValue: Bool {
        get {
            switch self.type {
            case .bool:
                return self.rawBool
            case .number:
                return self.rawNumber.boolValue
            case .string:
                return self.rawString.caseInsensitiveCompare("true") == .orderedSame
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
            case .string:
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

#if os(Linux)
           switch self.type {
            case .string:
                return self.object as? String ?? ""
            case .number:
                return JSON.stringFromNumber(self.object as! NSNumber)
            case .bool:
                return String(self.object as! Bool)
            default:
                return ""
            }
#else
           switch self.type {
            case .string:
                return self.object as? String ?? ""
            case .number:
                return self.rawNumber.stringValue
            case .bool:
                return (self.object as? Bool).map { String($0) } ?? ""
            default:
                return ""
            }
#endif
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
            case .number:
                return self.rawNumber
            case .bool:
            return NSNumber(value: self.rawBool ? 1 : 0)
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
            case .string:
#if os(Linux)
                if  let decimal = Double(self.object as! String)  {
                    return NSNumber(value: decimal)
                }
                else {  // indicates parse error
                    return NSNumber(value: 0.0)
                }
#else
               let decimal = NSDecimalNumber(string: self.object as? String)
                if decimal == NSDecimalNumber.notANumber {  // indicates parse error
                    return NSDecimalNumber.zero
                }
                return decimal
#endif
            case .number:
                return self.object as? NSNumber ?? NSNumber(value: 0)
            case .bool:
                return NSNumber(value: self.rawBool ? 1 : 0)
            default:
                return NSNumber(value: 0.0)
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
            case .null:
                return self.rawNull
            default:
                return nil
            }
        }
        set {
            self.object = NSNull()
        }
    }
    public func exists() -> Bool{
        if let errorValue = error, errorValue.code == ErrorNotExist{
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
            case .string:
                guard let encodedString_ = self.rawString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
                    return nil
                }
                return NSURL(string: encodedString_)

            default:
                return nil
            }
        }
        set {
#if os(Linux)
            self.object = newValue?.absoluteString._bridgeToObjectiveC()
#else
            self.object = newValue?.absoluteString
#endif
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
                self.object = NSNumber(value: newValue)
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
            self.object = NSNumber(value: newValue)
        }
    }

    public var float: Float? {
        get {
            return self.number?.floatValue
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
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
            self.object = NSNumber(value: newValue)
        }
    }

    public var int: Int? {
        get {
            return self.number?.intValue
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object = NSNull()
            }
        }
    }

    public var intValue: Int {
        get {
            return self.numberValue.intValue
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }

    public var uInt: UInt? {
        get {
            return self.number?.uintValue
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object = NSNull()
            }
        }
    }

    public var uIntValue: UInt {
        get {
            return self.numberValue.uintValue
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }

    public var int8: Int8? {
        get {
            return self.number?.int8Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }

    public var int8Value: Int8 {
        get {
            return self.numberValue.int8Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }

    public var uInt8: UInt8? {
        get {
            return self.number?.uint8Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }

    public var uInt8Value: UInt8 {
        get {
            return self.numberValue.uint8Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }

    public var int16: Int16? {
        get {
            return self.number?.int16Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }

    public var int16Value: Int16 {
        get {
            return self.numberValue.int16Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }

    public var uInt16: UInt16? {
        get {
            return self.number?.uint16Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }

    public var uInt16Value: UInt16 {
        get {
            return self.numberValue.uint16Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }

    public var int32: Int32? {
        get {
            return self.number?.int32Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }

    public var int32Value: Int32 {
        get {
            return self.numberValue.int32Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }

    public var uInt32: UInt32? {
        get {
            return self.number?.uint32Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }

    public var uInt32Value: UInt32 {
        get {
            return self.numberValue.uint32Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }

    public var int64: Int64? {
        get {
            return self.number?.int64Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }

    public var int64Value: Int64 {
        get {
            return self.numberValue.int64Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }

    public var uInt64: UInt64? {
        get {
            return self.number?.uint64Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }

    public var uInt64Value: UInt64 {
        get {
            return self.numberValue.uint64Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }
}

//MARK: - Comparable
extension JSON : Swift.Comparable {}

public func ==(lhs: JSON, rhs: JSON) -> Bool {

    switch (lhs.type, rhs.type) {
    case (.number, .number):
        return lhs.rawNumber == rhs.rawNumber
    case (.string, .string):
        return lhs.rawString == rhs.rawString
    case (.bool, .bool):
        return lhs.rawBool == rhs.rawBool
    case (.array, .array):
#if os(Linux)
        return lhs.rawArray._bridgeToObjectiveC() == rhs.rawArray._bridgeToObjectiveC()
#else
        return lhs.rawArray as NSArray == rhs.rawArray as NSArray
#endif
    case (.dictionary, .dictionary):
#if os(Linux)
        return lhs.rawDictionary._bridgeToObjectiveC() == rhs.rawDictionary._bridgeToObjectiveC()
#else
        return lhs.rawDictionary as NSDictionary == rhs.rawDictionary as NSDictionary
#endif
    case (.null, .null):
        return true
    default:
        return false
    }
}

public func <=(lhs: JSON, rhs: JSON) -> Bool {

    switch (lhs.type, rhs.type) {
    case (.number, .number):
        return lhs.rawNumber <= rhs.rawNumber
    case (.string, .string):
        return lhs.rawString <= rhs.rawString
    case (.bool, .bool):
        return lhs.rawBool == rhs.rawBool
    case (.array, .array):
#if os(Linux)
        return lhs.rawArray._bridgeToObjectiveC() == rhs.rawArray._bridgeToObjectiveC()
#else
        return lhs.rawArray as NSArray == rhs.rawArray as NSArray
#endif
    case (.dictionary, .dictionary):
#if os(Linux)
        return lhs.rawDictionary._bridgeToObjectiveC() == rhs.rawDictionary._bridgeToObjectiveC()
#else
        return lhs.rawDictionary as NSDictionary == rhs.rawDictionary as NSDictionary
#endif
    case (.null, .null):
        return true
    default:
        return false
    }
}

public func >=(lhs: JSON, rhs: JSON) -> Bool {

    switch (lhs.type, rhs.type) {
    case (.number, .number):
        return lhs.rawNumber >= rhs.rawNumber
    case (.string, .string):
        return lhs.rawString >= rhs.rawString
    case (.bool, .bool):
        return lhs.rawBool == rhs.rawBool
    case (.array, .array):
#if os(Linux)
        return lhs.rawArray._bridgeToObjectiveC() == rhs.rawArray._bridgeToObjectiveC()
#else
        return lhs.rawArray as NSArray == rhs.rawArray as NSArray
#endif
    case (.dictionary, .dictionary):
#if os(Linux)
        return lhs.rawDictionary._bridgeToObjectiveC() == rhs.rawDictionary._bridgeToObjectiveC()
#else
        return lhs.rawDictionary as NSDictionary == rhs.rawDictionary as NSDictionary
#endif
    case (.null, .null):
        return true
    default:
        return false
    }
}

public func >(lhs: JSON, rhs: JSON) -> Bool {

    switch (lhs.type, rhs.type) {
    case (.number, .number):
        return lhs.rawNumber > rhs.rawNumber
    case (.string, .string):
        return lhs.rawString > rhs.rawString
    default:
        return false
    }
}

public func <(lhs: JSON, rhs: JSON) -> Bool {

    switch (lhs.type, rhs.type) {
    case (.number, .number):
        return lhs.rawNumber < rhs.rawNumber
    case (.string, .string):
        return lhs.rawString < rhs.rawString
    default:
        return false
    }
}

private let trueNumber = NSNumber(value: true)
private let falseNumber = NSNumber(value: false)
private let trueObjCType = String(describing: trueNumber.objCType)
private let falseObjCType = String(describing: falseNumber.objCType)

// MARK: - NSNumber: Comparable

extension NSNumber {
    var isBool:Bool {
        get {
#if os(Linux)
            let type = CFNumberGetType(unsafeBitCast(self, to: CFNumber.self))
            if  type == kCFNumberSInt8Type  &&
                  (self.compare(trueNumber) == ComparisonResult.orderedSame  ||
                   self.compare(falseNumber) == ComparisonResult.orderedSame){
                    return true
            } else {
                return false
            }
#else
            let objCType = String(describing: self.objCType)
            if (self.compare(trueNumber) == ComparisonResult.orderedSame && objCType == trueObjCType)
                || (self.compare(falseNumber) == ComparisonResult.orderedSame && objCType == falseObjCType){
                    return true
            } else {
                return false
            }
#endif
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
        return lhs.compare(rhs) == ComparisonResult.orderedSame
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
        return lhs.compare(rhs) == ComparisonResult.orderedAscending
    }
}

func >(lhs: NSNumber, rhs: NSNumber) -> Bool {

    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) == ComparisonResult.orderedDescending
    }
}

func <=(lhs: NSNumber, rhs: NSNumber) -> Bool {

    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) != ComparisonResult.orderedDescending
    }
}

func >=(lhs: NSNumber, rhs: NSNumber) -> Bool {

    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) != ComparisonResult.orderedAscending

    }
}
