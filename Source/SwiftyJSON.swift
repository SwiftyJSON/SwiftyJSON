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

#if os(Linux)
    /**
    Creates a JSON using the data.
    - parameter data:  The NSData used to convert to json.Top level object in data is an NSArray or NSDictionary
    - parameter opt:   The JSON serialization reading options. `.AllowFragments` by default.
    - returns: The created JSON
    */
    public init(data:NSData, options opt: NSJSONReadingOptions = .allowFragments) {
        do {
            let object: Any = try NSJSONSerialization.jsonObject(with: data, options: opt)
            self.init(object)
        }
        catch {
            // For now do nothing with the error
            self.init(NSNull())
        }
    }
#else
    public init(data:NSData, options opt: JSONSerialization.ReadingOptions = .allowFragments, error: NSErrorPointer = nil) {
        do {
            let object: AnyObject = try JSONSerialization.jsonObject(with: data as Data, options: opt)
            self.init(object)
        } catch let aError as NSError {
            if error != nil {
                error?.pointee = aError
            }
            self.init(NSNull())
        }
    }
#endif

    /**
     Create a JSON from JSON string
    - parameter string: Normal json string like '{"a":"b"}'

    - returns: The created JSON
    */
    public static func parse(string:String) -> JSON {
        #if os(Linux)
            return string.data(using: NSUTF8StringEncoding).flatMap({JSON(data: $0)}) ?? JSON(NSNull())
        #else
            return string.data(using: String.Encoding.utf8).flatMap({JSON(data: $0)}) ?? JSON(NSNull())
        #endif
    }

#if os(Linux)
    /**
    Creates a JSON using the object.

    - parameter object:  The object must have the following properties: All objects are NSString/String, NSNumber/Int/Float/Double/Bool, NSArray/Array, NSDictionary/Dictionary, or NSNull; All dictionary keys are NSStrings/String; NSNumbers are not NaN or infinity.

    - returns: The created JSON
    */
    public init(_ object: Any) {
        self.object = object
    }
#else
    public init(_ object: AnyObject) {
        self.object = object
    }
#endif
    /**
    Creates a JSON from a [JSON]

    - parameter jsonArray: A Swift array of JSON objects

    - returns: The created JSON
    */
    public init(_ jsonArray:[JSON]) {
#if os(Linux)
        self.init(jsonArray.map { $0.object } as Any)
#else
        self.init(jsonArray.map { $0.object } as AnyObject)
#endif
    }

    /**
    Creates a JSON from a [String: JSON]

    - parameter jsonDictionary: A Swift dictionary of JSON objects

    - returns: The created JSON
    */
    public init(_ jsonDictionary:[String: JSON]) {
#if os(Linux)
        var dictionary = [String: Any]()
#else
        var dictionary = [String: AnyObject](minimumCapacity: jsonDictionary.count)
#endif
        for (key, json) in jsonDictionary {
            dictionary[key] = json.object
        }
#if os(Linux)
        self.init(dictionary as Any)
#else
        self.init(dictionary as AnyObject)
#endif
    }

    /// Private object
    private var rawString: String = ""
    private var rawNumber: NSNumber = 0
    private var rawNull: NSNull = NSNull()
    /// Private type
    private var _type: Type = .Null
    /// prviate error
    private var _error: NSError? = nil

#if os(Linux)
    /// Private object
    private var rawArray: [Any] = []
    private var rawBool: Bool = false
    private var rawDictionary: [String : Any] = [:]

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

    private func setObjectHelper(_ newValue: Any) -> (Type, Any) {
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
          value = NSNumber(value: number)
      case let number as Int:
          type = .Number
          value = NSNumber(value: number)
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
#else
    private var rawArray: [AnyObject] = []
    private var rawDictionary: [String : AnyObject] = [:]

    /// Object in JSON
    public var object: AnyObject {
        get {
            switch self.type {
            case .Array:
                return self.rawArray as AnyObject
            case .Dictionary:
                return self.rawDictionary as AnyObject
            case .String:
                return self.rawString as AnyObject
            case .Number:
                return self.rawNumber
            case .Bool:
                return self.rawNumber
            default:
                return self.rawNull
            }
        }
        set {
            _error = nil
            switch newValue {
            case let number as NSNumber:
                if number.isBool {
                    _type = .Bool
                } else {
                    _type = .Number
                }
                self.rawNumber = number
            case  let string as String:
                _type = .String
                self.rawString = string
            case  _ as NSNull:
                _type = .Null
            case let array as [AnyObject]:
                _type = .Array
                self.rawArray = array
            case let dictionary as [String : AnyObject]:
                _type = .Dictionary
                self.rawDictionary = dictionary
            default:
                _type = .Unknown
                _error = NSError(domain: ErrorDomain, code: ErrorUnsupportedType, userInfo: [NSLocalizedDescriptionKey as NSObject: "It is a unsupported type"])
            }
        }
    }

#endif

    /// json type
    public var type: Type { get { return _type } }

    /// Error in JSON
    public var error: NSError? { get { return self._error } }

    /// The static null json
    @available(*, unavailable, renamed:"null")
    public static var nullJSON: JSON { get { return null } }
    public static var null: JSON { get { return JSON(NSNull() as AnyObject) } }
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

// MARK: - CollectionType, SequenceType, Indexable
extension JSON : Collection, Sequence, Indexable {

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

    public func index(after i: JSON.Index) -> JSON.Index {
        switch self.type {
        case .Array:
            return JSONIndex(arrayIndex: self.rawArray.index(after: i.arrayIndex!))
        case .Dictionary:
            return JSONIndex(dictionaryIndex: self.rawDictionary.index(after: i.dictionaryIndex!))
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

    /// If `type` is `.Array` or `.Dictionary`, return `array.isEmpty` or `dictonary.isEmpty` otherwise return `true`.
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

public struct JSONIndex: _Incrementable, Equatable, Comparable {
    let arrayIndex: Array<Any>.Index?
#if os(Linux)
    let dictionaryIndex: DictionaryIndex<String, Any>?
#else
    let dictionaryIndex: DictionaryIndex<String, AnyObject>?
#endif
    let type: Type

    init(){
        self.arrayIndex = nil
        self.dictionaryIndex = nil
        self.type = .Unknown
    }

    init(arrayIndex: Array<Any>.Index) {
        self.arrayIndex = arrayIndex
        self.dictionaryIndex = nil
        self.type = .Array
    }

#if os(Linux)
    init(dictionaryIndex: DictionaryIndex<String, Any>) {
        self.arrayIndex = nil
        self.dictionaryIndex = dictionaryIndex
        self.type = .Dictionary
    }
#else
    init(dictionaryIndex: DictionaryIndex<String, AnyObject>) {
        self.arrayIndex = nil
        self.dictionaryIndex = dictionaryIndex
        self.type = .Dictionary
    }
#endif
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
#if os(Linux) 
    private var dictionayGenerate: DictionaryIterator<String, Any>?
    private var arrayGenerate: IndexingIterator<[Any]>?
#else
    private var dictionayGenerate: DictionaryIterator<String, AnyObject>?
    private var arrayGenerate: IndexingIterator<[AnyObject]>?
#endif
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
                let i = self.arrayIndex
                self.arrayIndex += 1
                return (String(i), JSON(o))
            } else {
                return nil
            }
        case .Dictionary:
#if os(Linux)
            guard let (k, v): (String, Any) = self.dictionayGenerate?.next() else {
                return nil
            }
#else
            guard let (k, v): (String, AnyObject) = self.dictionayGenerate?.next() else {
                return nil
            }
#endif
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

    /// If `type` is `.Array`, return json whose object is `array[index]`, otherwise return null json with error.
    private subscript(index index: Int) -> JSON {
        get {
            if self.type != .Array {
                var r = JSON.null
#if os(Linux)
                r._error = self._error ?? NSError(domain: ErrorDomain, code: ErrorWrongType, userInfo: [NSLocalizedDescriptionKey: "Array[\(index)] failure, It is not an array" as Any])
#else
                r._error = self._error ?? NSError(domain: ErrorDomain, code: ErrorWrongType, userInfo: [NSLocalizedDescriptionKey as AnyObject as! NSObject: "Array[\(index)] failure, It is not an array" as AnyObject])
#endif
                return r
            } else if index >= 0 && index < self.rawArray.count {
                return JSON(self.rawArray[index])
            } else {
                var r = JSON.null
#if os(Linux)
                r._error = NSError(domain: ErrorDomain, code:ErrorIndexOutOfBounds , userInfo: [NSLocalizedDescriptionKey: "Array[\(index)] is out of bounds" as Any])
#else
                r._error = NSError(domain: ErrorDomain, code:ErrorIndexOutOfBounds , userInfo: [NSLocalizedDescriptionKey as AnyObject as! NSObject: "Array[\(index)] is out of bounds" as AnyObject])
#endif
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

    /// If `type` is `.Dictionary`, return json whose object is `dictionary[key]` , otherwise return null json with error.
    private subscript(key key: String) -> JSON {
        get {
            var r = JSON.null
            if self.type == .Dictionary {
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
#if os(Linux)
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
        self.init(elements.reduce([String : AnyObject](minimumCapacity: elements.count)){(dictionary: [String : AnyObject], element:(String, AnyObject)) -> [String : AnyObject] in
            var d = dictionary
            d[element.0] = element.1
            return d
            })
    }
}

extension JSON: Swift.ArrayLiteralConvertible {

    public init(arrayLiteral elements: AnyObject...) {
        self.init(elements)
    }
}
#else
extension JSON: Swift.StringLiteralConvertible {

    public init(stringLiteral value: StringLiteralType) {
        self.init(value as AnyObject)
    }

    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(value as AnyObject)
    }

    public init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(value as AnyObject)
    }
}

extension JSON: Swift.IntegerLiteralConvertible {

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value as AnyObject)
    }
}

extension JSON: Swift.BooleanLiteralConvertible {

    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value as AnyObject)
    }
}

extension JSON: Swift.FloatLiteralConvertible {

    public init(floatLiteral value: FloatLiteralType) {
        self.init(value as AnyObject)
    }
}

extension JSON: Swift.DictionaryLiteralConvertible {

    public init(dictionaryLiteral elements: (String, AnyObject)...) {
        self.init(elements.reduce([String : AnyObject](minimumCapacity: elements.count)){(dictionary: [String : AnyObject], element:(String, AnyObject)) -> [String : AnyObject] in
            var d = dictionary
            d[element.0] = element.1
            return d
            } as AnyObject)
    }
}

extension JSON: Swift.ArrayLiteralConvertible {

    public init(arrayLiteral elements: AnyObject...) {
        self.init(elements as AnyObject)
    }
}
#endif

extension JSON: Swift.NilLiteralConvertible {

    public init(nilLiteral: ()) {
        self.init(NSNull())
    }
}

// MARK: - Raw

extension JSON: Swift.RawRepresentable {

#if os(Linux)
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
#else
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
#endif

#if os(Linux)
    public func rawData(options opt: NSJSONWritingOptions = NSJSONWritingOptions(rawValue: 0)) throws -> NSData {
        guard LclJSONSerialization.isValidJSONObject(self.object) else {
            throw NSError(domain: ErrorDomain, code: ErrorInvalidJSON, userInfo: [NSLocalizedDescriptionKey: "JSON is invalid"])
        }
    
        return try LclJSONSerialization.dataWithJSONObject(self.object, options: opt)
    }
#else
    public func rawData(options opt: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions(rawValue: 0)) throws -> NSData {
        guard JSONSerialization.isValidJSONObject(self.object) else {
            throw NSError(domain: ErrorDomain, code: ErrorInvalidJSON, userInfo: [NSLocalizedDescriptionKey as NSObject: "JSON is invalid"])
        }
        
        return try JSONSerialization.data(withJSONObject: self.object, options: opt)
    }
#endif

#if os(Linux)
    public func rawString(encoding: UInt = NSUTF8StringEncoding, options opt: NSJSONWritingOptions = .prettyPrinted) -> String? {
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
#else
    public func rawString(encoding: UInt = String.Encoding.utf8.rawValue, options opt: JSONSerialization.WritingOptions = .prettyPrinted) -> String? {
        switch self.type {
        case .Array, .Dictionary:
            do {
                let data = try self.rawData(options: opt)
                return NSString(data: data as Data, encoding: encoding) as? String
            } catch _ {
                return nil
            }
        case .String:
            return self.rawString
        case .Number:
            return self.rawNumber.stringValue
        case .Bool:
            return self.rawNumber.boolValue.description
        case .Null:
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

#if os(Linux)
    //Optional [Any]
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
#else 
    //Optional [AnyObject]
    public var arrayObject: [AnyObject]? {
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
                self.object = array as AnyObject
            } else {
                self.object = NSNull()
            }
        }
    }    
#endif

}

// MARK: - Dictionary

extension JSON {

    //Optional [String : JSON]
    public var dictionary: [String : JSON]? {
        if self.type == .Dictionary {
#if os(Linux)
            return self.rawDictionary.reduce([String : JSON]()) { (dictionary: [String : JSON], element: (String, Any)) -> [String : JSON] in
                var d = dictionary
                d[element.0] = JSON(element.1)
                return d
            } 
#else 
            return self.rawDictionary.reduce([String : JSON](minimumCapacity: count)) { (dictionary: [String : JSON], element: (String, AnyObject)) -> [String : JSON] in
                var d = dictionary
                d[element.0] = JSON(element.1)
                return d
            }       
#endif

        } else {
            return nil
        }
    }

    //Non-optional [String : JSON]
    public var dictionaryValue: [String : JSON] {
        return self.dictionary ?? [:]
    }
#if os(Linux)
    //Optional [String : Any]
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
#else 
    //Optional [String : AnyObject]
    public var dictionaryObject: [String : AnyObject]? {
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
                self.object = v as AnyObject
            } else {
                self.object = NSNull()
            }
        }
    }     
#endif
}

// MARK: - Bool

extension JSON: Swift.BooleanType {

    //Optional bool
    public var bool: Bool? {
        get {
            switch self.type {
            case .Bool:
                return self.rawNumber.boolValue
            default:
                return nil
            }
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object = NSNull()
            }
        }
    }
#if os(Linux)
    //Non-optional bool
    public var boolValue: Bool {
        get {
            switch self.type {
            case .Bool:
                return self.rawBool
            case .Number:
                return self.rawNumber.boolValue
            case .String:
                return self.rawString.bridge().caseInsensitiveCompare("true") == .orderedSame
            default:
                return false
            }
        }
        set {
            self.object = newValue
        }
    }
#else
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
            self.object = NSNumber(value: newValue)
        }
    }
#endif
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
 
#if os(Linux)
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
#else 
           switch self.type {
            case .String:
                return self.object as? String ?? ""
            case .Number:
                return self.object.stringValue
            case .Bool:
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
            case .Number, .Bool:
                return self.rawNumber
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
#if os(Linux)
                if  let decimal = Double(self.object as! String)  {
                    return NSNumber(value: decimal)
                }
                else {  // indicates parse error
                    return NSNumber(value: 0.0)
                }   
#else 
               let decimal = NSDecimalNumber(string: self.object as? String)
                if decimal == NSDecimalNumber.notANumber() {  // indicates parse error
                    return NSDecimalNumber.zero()
                }
                return decimal     
#endif
            case .Number, .Bool:
                return self.object as? NSNumber ?? NSNumber(value: 0)
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
    public func exists() -> Bool{
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
#if os(Linux)
                guard let encodedString_ = self.rawString.bridge().stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) else {
                    return nil
                }
#else 
                guard let encodedString_ = self.rawString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
                    return nil
                }
#endif
                return NSURL(string: encodedString_)

            default:
                return nil
            }
        }
        set {
#if os(Linux)
            self.object = newValue?.absoluteString.bridge() ?? NSNull()
#else
            self.object = newValue?.absoluteString as? AnyObject ?? NSNull()
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
    case (.Number, .Number):
        return lhs.rawNumber == rhs.rawNumber
    case (.String, .String):
        return lhs.rawString == rhs.rawString
    case (.Bool, .Bool):
        return lhs.rawNumber.boolValue == rhs.rawNumber.boolValue
    case (.Array, .Array):
#if os(Linux)
        return lhs.rawArray.bridge() == rhs.rawArray.bridge()    
#else 
        return lhs.rawArray as NSArray == rhs.rawArray as NSArray
#endif
    case (.Dictionary, .Dictionary):
#if os(Linux)
        return lhs.rawDictionary.bridge() == rhs.rawDictionary.bridge()
#else 
        return lhs.rawDictionary as NSDictionary == rhs.rawDictionary as NSDictionary
#endif
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
        return lhs.rawNumber.boolValue == rhs.rawNumber.boolValue
    case (.Array, .Array):
#if os(Linux)
        return lhs.rawArray.bridge() == rhs.rawArray.bridge()    
#else 
        return lhs.rawArray as NSArray == rhs.rawArray as NSArray
#endif
    case (.Dictionary, .Dictionary):
#if os(Linux)
        return lhs.rawDictionary.bridge() == rhs.rawDictionary.bridge()
#else 
        return lhs.rawDictionary as NSDictionary == rhs.rawDictionary as NSDictionary
#endif
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
        return lhs.rawNumber.boolValue == rhs.rawNumber.boolValue
    case (.Array, .Array):
#if os(Linux)
        return lhs.rawArray.bridge() == rhs.rawArray.bridge()    
#else 
        return lhs.rawArray as NSArray == rhs.rawArray as NSArray
#endif
    case (.Dictionary, .Dictionary):
#if os(Linux)
        return lhs.rawDictionary.bridge() == rhs.rawDictionary.bridge()
#else 
        return lhs.rawDictionary as NSDictionary == rhs.rawDictionary as NSDictionary
#endif
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

private let trueNumber = NSNumber(value: true)
private let falseNumber = NSNumber(value: false)
private let trueObjCType = String(trueNumber.objCType)
private let falseObjCType = String(falseNumber.objCType)

// MARK: - NSNumber: Comparable

extension NSNumber {
    var isBool:Bool {
        get {
#if os(Linux)
            let type = CFNumberGetType(unsafeBitCast(self, to: CFNumber.self))
            if  type == kCFNumberSInt8Type  &&
                  (self.compare(trueNumber) == NSComparisonResult.orderedSame  ||
                   self.compare(falseNumber) == NSComparisonResult.orderedSame){
                    return true
            } else {
                return false
            }
#else
            let objCType = String(self.objCType)
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
        #if os(Linux)
            return lhs.compare(rhs) == NSComparisonResult.orderedSame
        #else
            return lhs.compare(rhs) == ComparisonResult.orderedSame
        #endif
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
        #if os(Linux)
            return lhs.compare(rhs) == NSComparisonResult.orderedAscending
        #else
            return lhs.compare(rhs) == ComparisonResult.orderedAscending
        #endif
    }
}

func >(lhs: NSNumber, rhs: NSNumber) -> Bool {

    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        #if os(Linux)
            return lhs.compare(rhs) == NSComparisonResult.orderedDescending
        #else
            return lhs.compare(rhs) == ComparisonResult.orderedDescending
        #endif
    }
}

func <=(lhs: NSNumber, rhs: NSNumber) -> Bool {

    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        #if os(Linux)
            return lhs.compare(rhs) == NSComparisonResult.orderedDescending
        #else
            return lhs.compare(rhs) == ComparisonResult.orderedDescending
        #endif
    }
}

func >=(lhs: NSNumber, rhs: NSNumber) -> Bool {

    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        #if os(Linux)
            return lhs.compare(rhs) == NSComparisonResult.orderedAscending
        #else
            return lhs.compare(rhs) == ComparisonResult.orderedAscending
        #endif
    }
}
