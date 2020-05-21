//  SwiftyJSON.swift
//
//  Copyright (c) 2014 - 2017 Ruoyu Fu, Pinglin Tang
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
// swiftlint:disable line_length
public enum SwiftyJSONError: Int, Swift.Error {
    case unsupportedType = 999
    case indexOutOfBounds = 900
    case elementTooDeep = 902
    case wrongType = 901
    case notExist = 500
    case invalidJSON = 490
}

extension SwiftyJSONError: CustomNSError {

    /// return the error domain of SwiftyJSONError
    public static var errorDomain: String { return "com.swiftyjson.SwiftyJSON" }

    /// return the error code of SwiftyJSONError
    public var errorCode: Int { return self.rawValue }

    /// return the userInfo of SwiftyJSONError
    public var errorUserInfo: [String: Any] {
        switch self {
        case .unsupportedType:
            return [NSLocalizedDescriptionKey: "It is an unsupported type."]
        case .indexOutOfBounds:
            return [NSLocalizedDescriptionKey: "Array Index is out of bounds."]
        case .wrongType:
            return [NSLocalizedDescriptionKey: "Couldn't merge, because the JSONs differ in type on top level."]
        case .notExist:
            return [NSLocalizedDescriptionKey: "Dictionary key does not exist."]
        case .invalidJSON:
            return [NSLocalizedDescriptionKey: "JSON is invalid."]
        case .elementTooDeep:
            return [NSLocalizedDescriptionKey: "Element too deep. Increase maxObjectDepth and make sure there is no reference loop."]
        }
    }
}

// MARK: - JSON Type

/**
JSON's type definitions.

See http://www.json.org
*/

/// Options of JSON content
fileprivate enum Content {
    case number(NSNumber)
    case bool(Bool)
    case string(String)
    case null
    case array([Any])
    case dictionary([String: Any])
    case unknown
}

/// Type of JSON content
public enum Type: Int {
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
	
	 - parameter data: The NSData used to convert to json.Top level object in data is an NSArray or NSDictionary
	 - parameter opt: The JSON serialization reading options. `[]` by default.
	
	 - returns: The created JSON
	 */
    public init(data: Data, options opt: JSONSerialization.ReadingOptions = []) throws {
        let object: Any = try JSONSerialization.jsonObject(with: data, options: opt)
        self.init(jsonObject: object)
    }

    /**
	 Creates a JSON object
	 - note: this does not parse a `String` into JSON, instead use `init(parseJSON: String)`
	
	 - parameter object: the object

	 - returns: the created JSON object
	 */
    public init(_ object: Any) {
        switch object {
        case let object as Data:
            do {
                try self.init(data: object)
            } catch {
                self.init(jsonObject: NSNull())
            }
        default:
            self.init(jsonObject: object)
        }
    }

	/**
	 Parses the JSON string into a JSON object
	
	 - parameter json: the JSON string
	
	 - returns: the created JSON object
	*/
	public init(parseJSON jsonString: String) {
		if let data = jsonString.data(using: .utf8) {
			self.init(data)
		} else {
			self.init(NSNull())
		}
	}
    
    // TODO: - add documentation
    
    fileprivate init(error: SwiftyJSONError) {
        self.content = .null
        self.error = error
    }

	/**
	 Creates a JSON using the object.
	
	 - parameter jsonObject:  The object must have the following properties: All objects are NSString/String, NSNumber/Int/Float/Double/Bool, NSArray/Array, NSDictionary/Dictionary, or NSNull; All dictionary keys are NSStrings/String; NSNumbers are not NaN or infinity.
	
	 - returns: The created JSON
	 */
    fileprivate init(jsonObject: Any) {
        (self.content, self.error) = resolveContentAndError(for: jsonObject)
    }

	/**
	 Merges another JSON into this JSON, whereas primitive values which are not present in this JSON are getting added,
	 present values getting overwritten, array values getting appended and nested JSONs getting merged the same way.
 
	 - parameter other: The JSON which gets merged into this JSON
	
	 - throws `ErrorWrongType` if the other JSONs differs in type on the top level.
	 */
    public mutating func merge(with other: JSON) throws {
        try self.merge(with: other, typecheck: true)
    }

	/**
	 Merges another JSON into this JSON and returns a new JSON, whereas primitive values which are not present in this JSON are getting added,
	 present values getting overwritten, array values getting appended and nested JSONS getting merged the same way.
	
	 - parameter other: The JSON which gets merged into this JSON
	
	 - throws `ErrorWrongType` if the other JSONs differs in type on the top level.
	
	 - returns: New merged JSON
	 */
    public func merged(with other: JSON) throws -> JSON {
        var merged = self
        try merged.merge(with: other, typecheck: true)
        return merged
    }

    /**
     Private woker function which does the actual merging
     Typecheck is set to true for the first recursion level to prevent total override of the source JSON
 	*/
 	fileprivate mutating func merge(with other: JSON, typecheck: Bool) throws {
        if type == other.type {
            switch type {
            case .dictionary:
                for (key, _) in other {
                    try self[key].merge(with: other[key], typecheck: false)
                }
            case .array:
                self = JSON(arrayValue + other.arrayValue)
            default:
                self = other
            }
        } else {
            if typecheck {
                throw SwiftyJSONError.wrongType
            } else {
                self = other
            }
        }
    }

    /// JSON type, fileprivate setter
    public var type: Type {
        switch content {
        case .array: return .array
        case .bool: return .bool
        case .dictionary: return .dictionary
        case .null: return .null
        case .number: return .number
        case .string: return .string
        case .unknown: return .unknown
        }
    }
    fileprivate var content: Content

    /// Error in JSON, fileprivate setter
    public fileprivate(set) var error: SwiftyJSONError?

    /// Object in JSON
    public var object: Any {
        get {
            switch content {
            case .array(let rawArray): return rawArray
            case .dictionary(let rawDictionary): return rawDictionary
            case .string(let rawString): return rawString
            case .number(let rawNumber): return rawNumber
            case .bool(let rawBool): return rawBool
            case .null, .unknown: return NSNull()
            }
        }
        set {
            (content, error) = resolveContentAndError(for: newValue)
        }
    }
    
    private mutating func updateContent(to newContent: Content, error: SwiftyJSONError?) {
        self.content = newContent
        self.error = error
    }

    /// The static null JSON
    @available(*, unavailable, renamed:"null")
    public static var nullJSON: JSON { return null }
    public static var null: JSON { return JSON(NSNull()) }
}

/// Private method to unwarp an object recursively
private func resolveContentAndError(for jsonObject: Any) -> (Content, SwiftyJSONError?) {
    let content = resolveContent(for: jsonObject)
    let error: SwiftyJSONError? = (content == .unknown) ? .unsupportedType : nil
    return (content, error)
}

private func resolveContent(for jsonObject: Any) -> Content {
    switch unwrap(jsonObject) {
    case let number as NSNumber:
        return number.isBool ? .bool(number.boolValue) : .number(number)
    case let string as String:
        return .string(string)
    case _ as NSNull:
        return .null
    case nil:
        return .null
    case let array as [Any]:
        return .array(array)
    case let dictionary as [String: Any]:
        return .dictionary(dictionary)
    default:
        return .unknown
    }
}

private func unwrap(_ object: Any) -> Any {
    switch object {
    case let json as JSON:
        return unwrap(json.object)
    case let array as [Any]:
        return array.map(unwrap)
    case let dictionary as [String: Any]:
        var d = dictionary
        dictionary.forEach { pair in
            d[pair.key] = unwrap(pair.value)
        }
        return d
    default:
        return object
    }
}

public enum Index<T: Any>: Comparable {
    case array(Int)
    case dictionary(DictionaryIndex<String, T>)
    case null

    static public func == (lhs: Index, rhs: Index) -> Bool {
        switch (lhs, rhs) {
        case (.array(let left), .array(let right)):           return left == right
        case (.dictionary(let left), .dictionary(let right)): return left == right
        case (.null, .null):                                  return true
        default:                                              return false
        }
    }

    static public func < (lhs: Index, rhs: Index) -> Bool {
        switch (lhs, rhs) {
        case (.array(let left), .array(let right)):           return left < right
        case (.dictionary(let left), .dictionary(let right)): return left < right
        default:                                              return false
        }
    }
}

public typealias JSONIndex = Index<JSON>
public typealias JSONRawIndex = Index<Any>

extension JSON: Swift.Collection {

    public typealias Index = JSONRawIndex

    public var startIndex: Index {
        switch content {
        case .array(let rawArray): return .array(rawArray.startIndex)
        case .dictionary(let rawDictionary): return .dictionary(rawDictionary.startIndex)
        default:          return .null
        }
    }

    public var endIndex: Index {
        switch content {
        case .array(let rawArray):      return .array(rawArray.endIndex)
        case .dictionary(let rawDictionary): return .dictionary(rawDictionary.endIndex)
        default:          return .null
        }
    }

    public func index(after i: Index) -> Index {
        switch content {
        case .array(let rawArray):
            guard case .array(let idx) = i else { return .null }
            return .array(rawArray.index(after: idx))
        case .dictionary(let rawDictionary):
            guard case .dictionary(let idx) = i else { return .null }
            return .dictionary(rawDictionary.index(after: idx))
        default:
            return .null
        }
    }

    public subscript (position: Index) -> (String, JSON) {
        switch content {
        case .array(let rawArray):
            guard case .array(let idx) = position else { return ("", JSON.null) }
            return (String(idx), JSON(rawArray[idx]))
        case .dictionary(let rawDictionary):
            guard case .dictionary(let idx) = position else { return ("", JSON.null) }
            return (rawDictionary[idx].key, JSON(rawDictionary[idx].value))
        default:
            return ("", JSON.null)
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
    var jsonKey: JSONKey { get }
}

extension Int: JSONSubscriptType {
    public var jsonKey: JSONKey {
        return JSONKey.index(self)
    }
}

extension String: JSONSubscriptType {
    public var jsonKey: JSONKey {
        return JSONKey.key(self)
    }
}

extension JSON {

    /// If `type` is `.array`, return json whose object is `array[index]`, otherwise return null json with error.
    fileprivate subscript(index index: Int) -> JSON {
        get {
            guard case .array(let rawArray) = content else {
                return JSON(error: self.error ?? .wrongType)
            }
            guard rawArray.indices.contains(index) else {
                return JSON(error: .indexOutOfBounds)
            }
            return JSON(rawArray[index])
        }
        set {
            guard
                case .array(let rawArray) = content,
                rawArray.indices.contains(index),
                newValue.error == nil
            else {
                return
            }
            var copy = rawArray
            copy[index] = newValue.object
            content = .array(copy)
        }
    }

    /// If `type` is `.dictionary`, return json whose object is `dictionary[key]` , otherwise return null json with error.
    fileprivate subscript(key key: String) -> JSON {
        get {
            guard case .dictionary(let rawDictionary) = content else {
                return JSON(error: self.error ?? .wrongType)
            }
            guard let obj = rawDictionary[key] else {
                return JSON(error: .notExist)
            }
            return JSON(obj)
        }
        set {
            guard
                newValue.error == nil,
                case .dictionary(let rawDictionary) = content
            else {
                return
            }
            var copy = rawDictionary
            copy[key] = newValue.object
            content = .dictionary(copy)
        }
    }

    /// If `sub` is `Int`, return `subscript(index:)`; If `sub` is `String`,  return `subscript(key:)`.
    fileprivate subscript(sub sub: JSONSubscriptType) -> JSON {
        get {
            switch sub.jsonKey {
            case .index(let index): return self[index: index]
            case .key(let key):     return self[key: key]
            }
        }
        set {
            switch sub.jsonKey {
            case .index(let index): self[index: index] = newValue
            case .key(let key):     self[key: key] = newValue
            }
        }
    }

	/**
	 Find a json in the complex data structures by using array of Int and/or String as path.
	
	 Example:
	
	 ```
	 let json = JSON[data]
	 let path = [9,"list","person","name"]
	 let name = json[path]
	 ```
	
	 The same as: let name = json[9]["list"]["person"]["name"]
	
	 - parameter path: The target json's path.
	
	 - returns: Return a json found by the path or a null json with error
	 */
    public subscript(path: [JSONSubscriptType]) -> JSON {
        get {
            return path.reduce(self) { $0[sub: $1] }
        }
        set {
            switch path.count {
            case 0: return
            case 1: self[sub:path[0]].object = newValue.object
            default:
                var aPath = path
                aPath.remove(at: 0)
                var nextJSON = self[sub: path[0]]
                nextJSON[aPath] = newValue
                self[sub: path[0]] = nextJSON
            }
        }
    }

    /**
     Find a json in the complex data structures by using array of Int and/or String as path.

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

extension JSON: Swift.ExpressibleByStringLiteral {

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

extension JSON: Swift.ExpressibleByIntegerLiteral {

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

extension JSON: Swift.ExpressibleByBooleanLiteral {

    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
}

extension JSON: Swift.ExpressibleByFloatLiteral {

    public init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
}

extension JSON: Swift.ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any)...) {
        let dictionary = elements.reduce(into: [String: Any](), { $0[$1.0] = $1.1})
        self.init(dictionary)
    }
}

extension JSON: Swift.ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
}

// MARK: - Raw

extension JSON: Swift.RawRepresentable {

    public init?(rawValue: Any) {
        let json = JSON(rawValue)
        guard json.type != .unknown else { return nil }
        self = json
    }

    public var rawValue: Any {
        return object
    }

    public func rawData(options opt: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions(rawValue: 0)) throws -> Data {
        guard JSONSerialization.isValidJSONObject(object) else {
            throw SwiftyJSONError.invalidJSON
        }

        return try JSONSerialization.data(withJSONObject: object, options: opt)
	}

	public func rawString(_ encoding: String.Encoding = .utf8, options opt: JSONSerialization.WritingOptions = .prettyPrinted) -> String? {
		do {
			return try _rawString(encoding, options: [.jsonSerialization: opt])
		} catch {
			print("Could not serialize object to JSON because:", error.localizedDescription)
			return nil
		}
	}

	public func rawString(_ options: [writingOptionsKeys: Any]) -> String? {
		let encoding = options[.encoding] as? String.Encoding ?? String.Encoding.utf8
		let maxObjectDepth = options[.maxObjextDepth] as? Int ?? 10
		do {
			return try _rawString(encoding, options: options, maxObjectDepth: maxObjectDepth)
		} catch {
			print("Could not serialize object to JSON because:", error.localizedDescription)
			return nil
		}
	}

	fileprivate func _rawString(_ encoding: String.Encoding = .utf8, options: [writingOptionsKeys: Any], maxObjectDepth: Int = 10) throws -> String? {
        guard maxObjectDepth > 0 else { throw SwiftyJSONError.invalidJSON }
        switch content {
        case .dictionary:
			do {
				if !(options[.castNilToNSNull] as? Bool ?? false) {
					let jsonOption = options[.jsonSerialization] as? JSONSerialization.WritingOptions ?? JSONSerialization.WritingOptions.prettyPrinted
					let data = try rawData(options: jsonOption)
					return String(data: data, encoding: encoding)
				}

				guard let dict = object as? [String: Any?] else {
					return nil
				}
				let body = try dict.keys.map { key throws -> String in
					guard let value = dict[key] else {
						return "\"\(key)\": null"
					}
					guard let unwrappedValue = value else {
						return "\"\(key)\": null"
					}

					let nestedValue = JSON(unwrappedValue)
					guard let nestedString = try nestedValue._rawString(encoding, options: options, maxObjectDepth: maxObjectDepth - 1) else {
						throw SwiftyJSONError.elementTooDeep
					}
					if nestedValue.type == .string {
						return "\"\(key)\": \"\(nestedString.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\""
					} else {
						return "\"\(key)\": \(nestedString)"
					}
				}

				return "{\(body.joined(separator: ","))}"
			} catch _ {
				return nil
			}
        case .array:
            do {
				if !(options[.castNilToNSNull] as? Bool ?? false) {
					let jsonOption = options[.jsonSerialization] as? JSONSerialization.WritingOptions ?? JSONSerialization.WritingOptions.prettyPrinted
					let data = try rawData(options: jsonOption)
					return String(data: data, encoding: encoding)
				}

                guard let array = object as? [Any?] else {
                    return nil
                }
                let body = try array.map { value throws -> String in
                    guard let unwrappedValue = value else {
                        return "null"
                    }

                    let nestedValue = JSON(unwrappedValue)
                    guard let nestedString = try nestedValue._rawString(encoding, options: options, maxObjectDepth: maxObjectDepth - 1) else {
                        throw SwiftyJSONError.invalidJSON
                    }
                    if nestedValue.type == .string {
                        return "\"\(nestedString.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\""
                    } else {
                        return nestedString
                    }
                }

                return "[\(body.joined(separator: ","))]"
            } catch _ {
                return nil
            }
        case .string(let rawString): return rawString
        case .number(let rawNumber): return rawNumber.stringValue
        case .bool(let rawBool): return rawBool.description
        case .null: return "null"
        case .unknown: return nil
        }
    }
}

// MARK: - Printable, DebugPrintable

extension JSON: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible {

    public var description: String {
        return rawString(options: .prettyPrinted) ?? "unknown"
    }

    public var debugDescription: String {
        return description
    }
}

// MARK: - Array

extension JSON {

    //Optional [JSON]
    public var array: [JSON]? {
        guard case .array(let rawArray) = content else { return nil }
        return rawArray.map { JSON($0) }
    }

    //Non-optional [JSON]
    public var arrayValue: [JSON] {
        return self.array ?? []
    }

    //Optional [Any]
    public var arrayObject: [Any]? {
        get {
            switch content {
            case .array(let rawArray): return rawArray
            default: return nil
            }
        }
        set {
            if let newValue = newValue {
                self.updateContent(to: .array(newValue), error: nil)
            } else {
                self.updateContent(to: .null, error: nil)
            }
        }
    }
}

// MARK: - Dictionary

extension JSON {

    //Optional [String : JSON]
    public var dictionary: [String: JSON]? {
        guard case .dictionary(let rawDictionary) = content else { return nil }
        return rawDictionary.mapValues { JSON($0) }
    }

    //Non-optional [String : JSON]
    public var dictionaryValue: [String: JSON] {
        return dictionary ?? [:]
    }

    //Optional [String : Any]

    public var dictionaryObject: [String: Any]? {
        get {
            guard case .dictionary(let rawDictionary) = content else { return nil }
            return rawDictionary
        }
        set {
            if let newValue = newValue {
                updateContent(to: .dictionary(newValue), error: nil)
            } else {
                updateContent(to: .null, error: nil)
            }
        }
    }
}

// MARK: - Bool

extension JSON { // : Swift.Bool

    //Optional bool
    public var bool: Bool? {
        get {
            switch content {
            case .bool(let rawBool): return rawBool
            default:    return nil
            }
        }
        set {
            if let newValue = newValue {
                updateContent(to: .bool(newValue), error: nil)
            } else {
                updateContent(to: .null, error: nil)
            }
        }
    }

    //Non-optional bool
    public var boolValue: Bool {
        get {
            switch content {
            case .bool(let rawBool): return rawBool
            case .number(let rawNumber): return rawNumber.boolValue
            case .string(let rawString): return ["true", "y", "t", "yes", "1"].contains { rawString.caseInsensitiveCompare($0) == .orderedSame }
            default: return false
            }
        }
        set {
            updateContent(to: .bool(newValue), error: nil)
        }
    }
}

// MARK: - String

extension JSON {

    //Optional string
    public var string: String? {
        get {
            switch content {
            case .string(let rawString): return rawString
            default: return nil
            }
        }
        set {
            if let rawString = newValue {
                updateContent(to: .string(rawString), error: nil)
            } else {
                updateContent(to: .null, error: nil)
            }
        }
    }

    //Non-optional string
    public var stringValue: String {
        get {
            switch content {
            case .string(let rawString):    return rawString
            case .number(let rawNumber):    return rawNumber.stringValue
            case .bool(let rawBool):        return String(rawBool)
            default:                        return ""
            }
        }
        set {
            updateContent(to: .string(newValue), error: nil)
        }
    }
}

// MARK: - Number

extension JSON {

    //Optional number
    public var number: NSNumber? {
        get {
            switch content {
            case .number(let rawNumber):    return rawNumber
            case .bool(let rawBool):        return NSNumber(value: rawBool ? 1 : 0)
            default:                        return nil
            }
        }
        set {
            if let rawNumber = newValue {
                updateContent(to: .number(rawNumber), error: nil)
            } else {
                updateContent(to: .null, error: nil)
            }
        }
    }

    //Non-optional number
    public var numberValue: NSNumber {
        get {
            switch content {
            case .string(let rawString):
                let decimal = NSDecimalNumber(string: rawString)
                return decimal == .notANumber ? .zero : decimal
            case .number(let rawNumber):    return rawNumber
            case .bool(let rawBool):        return NSNumber(value: rawBool ? 1 : 0)
            default:                        return NSNumber(value: 0.0)
            }
        }
        set {
            updateContent(to: .number(newValue), error: nil)
        }
    }
}

// MARK: - Null

extension JSON {

    public var null: NSNull? {
        set {
            updateContent(to: .null, error: nil)
        }
        get {
            switch content {
            case .null: return NSNull()
            default:    return nil
            }
        }
    }
    public func exists() -> Bool {
        if let errorValue = error, (400...1000).contains(errorValue.errorCode) {
            return false
        }
        return true
    }
}

// MARK: - URL

extension JSON {

    //Optional URL
    public var url: URL? {
        get {
            switch content {
            case .string(let rawString):
                // Check for existing percent escapes first to prevent double-escaping of % character
                if rawString.range(of: "%[0-9A-Fa-f]{2}", options: .regularExpression, range: nil, locale: nil) != nil {
                    return Foundation.URL(string: rawString)
                } else if let encodedString_ = rawString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                    // We have to use `Foundation.URL` otherwise it conflicts with the variable name.
                    return Foundation.URL(string: encodedString_)
                } else {
                    return nil
                }
            default:
                return nil
            }
        }
        set {
            if let newValue = newValue {
                updateContent(to: .string(newValue.absoluteString), error: nil)
            } else {
                updateContent(to: .null, error: nil)
            }
        }
    }
}

// MARK: - Int, Double, Float, Int8, Int16, Int32, Int64

extension JSON {

    public var double: Double? {
        get {
            return number?.doubleValue
        }
        set {
            number = newValue.map { NSNumber(value: $0) }
        }
    }

    public var doubleValue: Double {
        get {
            return numberValue.doubleValue
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }

    public var float: Float? {
        get {
            return number?.floatValue
        }
        set {
            number = newValue.map { NSNumber(value: $0) }
        }
    }

    public var floatValue: Float {
        get {
            return numberValue.floatValue
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }

    public var int: Int? {
        get {
            return number?.intValue
        }
        set {
            number = newValue.map { NSNumber(value: $0) }
        }
    }

    public var intValue: Int {
        get {
            return numberValue.intValue
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }

    public var uInt: UInt? {
        get {
            return number?.uintValue
        }
        set {
            number = newValue.map { NSNumber(value: $0) }
        }
    }

    public var uIntValue: UInt {
        get {
            return numberValue.uintValue
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }

    public var int8: Int8? {
        get {
            return number?.int8Value
        }
        set {
            number = newValue.map { NSNumber(value: Int($0)) }
        }
    }

    public var int8Value: Int8 {
        get {
            return numberValue.int8Value
        }
        set {
            numberValue = NSNumber(value: Int(newValue))
        }
    }

    public var uInt8: UInt8? {
        get {
            return number?.uint8Value
        }
        set {
            number = newValue.map { NSNumber(value: $0) }
        }
    }

    public var uInt8Value: UInt8 {
        get {
            return numberValue.uint8Value
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }

    public var int16: Int16? {
        get {
            return number?.int16Value
        }
        set {
            number = newValue.map { NSNumber(value: $0) }
        }
    }

    public var int16Value: Int16 {
        get {
            return numberValue.int16Value
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }

    public var uInt16: UInt16? {
        get {
            return number?.uint16Value
        }
        set {
            number = newValue.map { NSNumber(value: $0) }
        }
    }

    public var uInt16Value: UInt16 {
        get {
            return numberValue.uint16Value
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }

    public var int32: Int32? {
        get {
            return number?.int32Value
        }
        set {
            number = newValue.map { NSNumber(value: $0) }
        }
    }

    public var int32Value: Int32 {
        get {
            return numberValue.int32Value
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }

    public var uInt32: UInt32? {
        get {
            return number?.uint32Value
        }
        set {
            number = newValue.map { NSNumber(value: $0) }
        }
    }

    public var uInt32Value: UInt32 {
        get {
            return numberValue.uint32Value
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }

    public var int64: Int64? {
        get {
            return number?.int64Value
        }
        set {
            number = newValue.map { NSNumber(value: $0) }
        }
    }

    public var int64Value: Int64 {
        get {
            return numberValue.int64Value
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }

    public var uInt64: UInt64? {
        get {
            return number?.uint64Value
        }
        set {
            number = newValue.map { NSNumber(value: $0) }
        }
    }

    public var uInt64Value: UInt64 {
        get {
            return numberValue.uint64Value
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }
}
// MARK: - Content: Comparable

extension Content: Comparable {
    
    static func == (lhs: Content, rhs: Content) -> Bool {

        switch (lhs, rhs) {
        case let (.number(l), .number(r)): return l == r
        case let (.string(l), .string(r)): return l == r
        case let (.bool(l), .bool(r)): return l == r
        case let (.array(l), .array(r)): return l as NSArray == r as NSArray
        case let (.dictionary(l), .dictionary(r)): return l as NSDictionary == r as NSDictionary
        case (.null, .null):     return true
        default:                 return false
        }
    }

    static func <= (lhs: Content, rhs: Content) -> Bool {
        
        switch (lhs, rhs) {
        case let (.number(l), .number(r)): return l <= r
        case let (.string(l), .string(r)): return l <= r
        case let (.bool(l), .bool(r)): return l == r
        case let (.array(l), .array(r)): return l as NSArray == r as NSArray
        case let (.dictionary(l), .dictionary(r)): return l as NSDictionary == r as NSDictionary
        case (.null, .null):     return true
        default:                 return false
        }
    }

    static func >= (lhs: Content, rhs: Content) -> Bool {

        switch (lhs, rhs) {
        case let (.number(l), .number(r)): return l >= r
        case let (.string(l), .string(r)): return l >= r
        case let (.bool(l), .bool(r)): return l == r
        case let (.array(l), .array(r)): return l as NSArray == r as NSArray
        case let (.dictionary(l), .dictionary(r)): return l as NSDictionary == r as NSDictionary
        case (.null, .null):     return true
        default:                 return false
        }
    }

    static func > (lhs: Content, rhs: Content) -> Bool {

        switch (lhs, rhs) {
        case let (.number(l), .number(r)): return l > r
        case let (.string(l), .string(r)): return l > r
        default:                 return false
        }
    }

    static func < (lhs: Content, rhs: Content) -> Bool {

        switch (lhs, rhs) {
        case let (.number(l), .number(r)): return l < r
        case let (.string(l), .string(r)): return l < r
        default:                 return false
        }
    }
}

// MARK: - Comparable

extension JSON: Swift.Comparable {}

public func == (lhs: JSON, rhs: JSON) -> Bool {

    switch (lhs.type, rhs.type) {
    case (.number, .number): return lhs.rawNumber == rhs.rawNumber
    case (.string, .string): return lhs.rawString == rhs.rawString
    case (.bool, .bool):     return lhs.rawBool == rhs.rawBool
    case (.array, .array):   return lhs.rawArray as NSArray == rhs.rawArray as NSArray
    case (.dictionary, .dictionary): return lhs.rawDictionary as NSDictionary == rhs.rawDictionary as NSDictionary
    case (.null, .null):     return true
    default:                 return false
    }
}

public func <= (lhs: JSON, rhs: JSON) -> Bool {

    switch (lhs.type, rhs.type) {
    case (.number, .number): return lhs.rawNumber <= rhs.rawNumber
    case (.string, .string): return lhs.rawString <= rhs.rawString
    case (.bool, .bool):     return lhs.rawBool == rhs.rawBool
    case (.array, .array):   return lhs.rawArray as NSArray == rhs.rawArray as NSArray
    case (.dictionary, .dictionary): return lhs.rawDictionary as NSDictionary == rhs.rawDictionary as NSDictionary
    case (.null, .null):     return true
    default:                 return false
    }
}

public func >= (lhs: JSON, rhs: JSON) -> Bool {

    switch (lhs.type, rhs.type) {
    case (.number, .number): return lhs.rawNumber >= rhs.rawNumber
    case (.string, .string): return lhs.rawString >= rhs.rawString
    case (.bool, .bool):     return lhs.rawBool == rhs.rawBool
    case (.array, .array):   return lhs.rawArray as NSArray == rhs.rawArray as NSArray
    case (.dictionary, .dictionary): return lhs.rawDictionary as NSDictionary == rhs.rawDictionary as NSDictionary
    case (.null, .null):     return true
    default:                 return false
    }
}

public func > (lhs: JSON, rhs: JSON) -> Bool {

    switch (lhs.type, rhs.type) {
    case (.number, .number): return lhs.rawNumber > rhs.rawNumber
    case (.string, .string): return lhs.rawString > rhs.rawString
    default:                 return false
    }
}

public func < (lhs: JSON, rhs: JSON) -> Bool {

    switch (lhs.type, rhs.type) {
    case (.number, .number): return lhs.rawNumber < rhs.rawNumber
    case (.string, .string): return lhs.rawString < rhs.rawString
    default:                 return false
    }
}

private let trueNumber = NSNumber(value: true)
private let falseNumber = NSNumber(value: false)
private let trueObjCType = String(cString: trueNumber.objCType)
private let falseObjCType = String(cString: falseNumber.objCType)

// MARK: - NSNumber: Comparable

extension NSNumber {
    fileprivate var isBool: Bool {
        let objCType = String(cString: self.objCType)
        if (self.compare(trueNumber) == .orderedSame && objCType == trueObjCType) || (self.compare(falseNumber) == .orderedSame && objCType == falseObjCType) {
            return true
        } else {
            return false
        }
    }
}

func == (lhs: NSNumber, rhs: NSNumber) -> Bool {
    switch (lhs.isBool, rhs.isBool) {
    case (false, true): return false
    case (true, false): return false
    default:            return lhs.compare(rhs) == .orderedSame
    }
}

func != (lhs: NSNumber, rhs: NSNumber) -> Bool {
    return !(lhs == rhs)
}

func < (lhs: NSNumber, rhs: NSNumber) -> Bool {

    switch (lhs.isBool, rhs.isBool) {
    case (false, true): return false
    case (true, false): return false
    default:            return lhs.compare(rhs) == .orderedAscending
    }
}

func > (lhs: NSNumber, rhs: NSNumber) -> Bool {

    switch (lhs.isBool, rhs.isBool) {
    case (false, true): return false
    case (true, false): return false
    default:            return lhs.compare(rhs) == ComparisonResult.orderedDescending
    }
}

func <= (lhs: NSNumber, rhs: NSNumber) -> Bool {

    switch (lhs.isBool, rhs.isBool) {
    case (false, true): return false
    case (true, false): return false
    default:            return lhs.compare(rhs) != .orderedDescending
    }
}

func >= (lhs: NSNumber, rhs: NSNumber) -> Bool {

    switch (lhs.isBool, rhs.isBool) {
    case (false, true): return false
    case (true, false): return false
    default:            return lhs.compare(rhs) != .orderedAscending
    }
}

public enum writingOptionsKeys {
	case jsonSerialization
	case castNilToNSNull
	case maxObjextDepth
	case encoding
}

// MARK: - JSON: Codable
extension JSON: Codable {
    private static var codableTypes: [Codable.Type] {
        return [
            Bool.self,
            Int.self,
            Int8.self,
            Int16.self,
            Int32.self,
            Int64.self,
            UInt.self,
            UInt8.self,
            UInt16.self,
            UInt32.self,
            UInt64.self,
            Double.self,
            String.self,
            [JSON].self,
            [String: JSON].self
        ]
    }
    public init(from decoder: Decoder) throws {
        var object: Any?

        if let container = try? decoder.singleValueContainer(), !container.decodeNil() {
            for type in JSON.codableTypes {
                if object != nil {
                    break
                }
                // try to decode value
                switch type {
                case let boolType as Bool.Type:
                    object = try? container.decode(boolType)
                case let intType as Int.Type:
                    object = try? container.decode(intType)
                case let int8Type as Int8.Type:
                    object = try? container.decode(int8Type)
                case let int32Type as Int32.Type:
                    object = try? container.decode(int32Type)
                case let int64Type as Int64.Type:
                    object = try? container.decode(int64Type)
                case let uintType as UInt.Type:
                    object = try? container.decode(uintType)
                case let uint8Type as UInt8.Type:
                    object = try? container.decode(uint8Type)
                case let uint16Type as UInt16.Type:
                    object = try? container.decode(uint16Type)
                case let uint32Type as UInt32.Type:
                    object = try? container.decode(uint32Type)
                case let uint64Type as UInt64.Type:
                    object = try? container.decode(uint64Type)
                case let doubleType as Double.Type:
                    object = try? container.decode(doubleType)
                case let stringType as String.Type:
                    object = try? container.decode(stringType)
                case let jsonValueArrayType as [JSON].Type:
                    object = try? container.decode(jsonValueArrayType)
                case let jsonValueDictType as [String: JSON].Type:
                    object = try? container.decode(jsonValueDictType)
                default:
                    break
                }
            }
        }
        self.init(object ?? NSNull())
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if object is NSNull {
            try container.encodeNil()
            return
        }
        switch object {
        case let intValue as Int:
            try container.encode(intValue)
        case let int8Value as Int8:
            try container.encode(int8Value)
        case let int32Value as Int32:
            try container.encode(int32Value)
        case let int64Value as Int64:
            try container.encode(int64Value)
        case let uintValue as UInt:
            try container.encode(uintValue)
        case let uint8Value as UInt8:
            try container.encode(uint8Value)
        case let uint16Value as UInt16:
            try container.encode(uint16Value)
        case let uint32Value as UInt32:
            try container.encode(uint32Value)
        case let uint64Value as UInt64:
            try container.encode(uint64Value)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case is [Any]:
            let jsonValueArray = array ?? []
            try container.encode(jsonValueArray)
        case is [String: Any]:
            let jsonValueDictValue = dictionary ?? [:]
            try container.encode(jsonValueDictValue)
        default:
            break
        }
    }
}
