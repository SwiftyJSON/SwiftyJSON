
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

#if os(Linux)

import CoreFoundation
import Foundation

import Glibc

public class LclJSONSerialization {

    
    /* Determines whether the given object can be converted to JSON.
       Other rules may apply. Calling this method or attempting a conversion are the definitive ways
       to tell if a given object can be converted to JSON data.
       - parameter obj: The object to test.
       - returns: `true` if `obj` can be converted to JSON, otherwise `false`.
     */
    open class func isValidJSONObject(_ obj: Any) -> Bool {
        // TODO: - revisit this once bridging story gets fully figured out
        func isValidJSONObjectInternal(_ obj: Any) -> Bool {
            // object is Swift.String, NSNull, Int, Bool, or UInt
            if obj is String || obj is NSNull || obj is Int || obj is Bool || obj is UInt {
                return true
            }

            // object is a Double and is not NaN or infinity
            if let number = obj as? Double  {
	        let invalid = number.isInfinite || number.isNaN
	        return !invalid
	    }
																        // object is a Float and is not NaN or infinity
            if let number = obj as? Float  {
                let invalid = number.isInfinite || number.isNaN
                return !invalid
            }

            // object is NSNumber and is not NaN or infinity
            if let number = obj as? NSNumber {
                let invalid = number.doubleValue.isInfinite || number.doubleValue.isNaN
                return !invalid
            }

            // object is Swift.Array
            if let array = obj as? [Any] {
                for element in array {
                    guard isValidJSONObjectInternal(element) else {
                        return false
                    }
                }
                return true
            }

            // object is Swift.Dictionary
            if let dictionary = obj as? [String: Any] {
                for (_, value) in dictionary {
                    guard isValidJSONObjectInternal(value) else {
                        return false
                    }
                }
                return true
            }

            // invalid object
            return false
        }

        // top level object must be an Swift.Array or Swift.Dictionary
        guard obj is [Any] || obj is [String: Any] else {
            return false
        }

        return isValidJSONObjectInternal(obj)
    }
    
    /* Generate JSON data from a Foundation object. If the object will not produce valid JSON then an exception will be thrown. Setting the NSJSONWritingPrettyPrinted option will generate JSON with whitespace designed to make the output more readable. If that option is not set, the most compact possible JSON will be generated. If an error occurs, the error parameter will be set and the return value will be nil. The resulting data is a encoded in UTF-8.
     */
    internal class func _data(withJSONObject value: Any, options opt: JSONSerialization.WritingOptions, stream: Bool) throws -> Data {
        var jsonStr = String()
        jsonStr.reserveCapacity(5000)
        
        var writer = JSONWriter(
            pretty: opt.contains(.prettyPrinted),
            writer: { (str: String?) in
                if let str = str {
                    jsonStr.append(str)
                }
            }
        )
        
        if let container = value as? NSArray {
            try writer.serializeJSON(container._bridgeToSwift())
        } else if let container = value as? NSDictionary {
            try writer.serializeJSON(container._bridgeToSwift())
        } else if let container = value as? Array<Any> {
            try writer.serializeJSON(container)
        } else if let container = value as? Dictionary<AnyHashable, Any> {
            try writer.serializeJSON(container)
        } else {
            if stream {
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    "NSDebugDescription" : "Top-level object was not NSArray or NSDictionary"
                    ])
            } else {
                fatalError("Top-level object was not NSArray or NSDictionary") // This is a fatal error in objective-c too (it is an NSInvalidArgumentException)
            }
        }
        
        let count = jsonStr.lengthOfBytes(using: .utf8)
        let bufferLength = count+1 // Allow space for null terminator
        var utf8: [CChar] = Array<CChar>(repeating: 0, count: bufferLength)
        if !jsonStr.getCString(&utf8, maxLength: bufferLength, encoding: .utf8) {
            // throw something?
        }
        let rawBytes = UnsafeRawPointer(UnsafePointer(utf8))
        let result = Data(bytes: rawBytes.bindMemory(to: UInt8.self, capacity: count), count: count)
        return result
    }
    open class func data(withJSONObject value: Any, options opt: JSONSerialization.WritingOptions = []) throws -> Data {
        return try _data(withJSONObject: value, options: opt, stream: false)
    }
    
    
    /* Write JSON data into a stream. The stream should be opened and configured. The return value is the number of bytes written to the stream, or 0 on error. All other behavior of this method is the same as the dataWithJSONObject:options:error: method.
     */
    open class func writeJSONObject(_ obj: Any, toStream stream: OutputStream, options opt: JSONSerialization.WritingOptions) throws -> Int {
        let jsonData = try _data(withJSONObject: obj, options: opt, stream: true)
        let count = jsonData.count
        return jsonData.withUnsafeBytes { (bytePtr) -> Int in
            return stream.write(bytePtr, maxLength: count)
        }
    }
}


//MARK: - JSONSerializer
private struct JSONWriter {
    
    var indent = 0
    let pretty: Bool
    let writer: (String?) -> Void
    
    init(pretty: Bool = false, writer: @escaping (String?) -> Void) {
        self.pretty = pretty
        self.writer = writer
    }
    
    mutating func serializeJSON(_ obj: Any) throws {
        
        if let str = obj as? String {
            try serializeString(str)
        } else if obj is Int || obj is Float || obj is Double || obj is UInt {
            writer(String(describing: obj))
	} else if let boolValue = obj as? Bool {
            serializeBool(boolValue)
	} else if let num = obj as? NSNumber {
            try serializeNumber(num)
        } else if let array = obj as? Array<Any> {
            try serializeArray(array)
        } else if let dict = obj as? Dictionary<AnyHashable, Any> {
            try serializeDictionary(dict)
        } else if let null = obj as? NSNull {
            try serializeNull(null)
        } else if let boolVal = obj as? Bool {
            try serializeNumber(NSNumber(value: boolVal))
        }
        else {
            throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: ["NSDebugDescription" : "Invalid object cannot be serialized"])
        }
    }

    func serializeString(_ str: String) throws {
        writer("\"")
        for scalar in str.unicodeScalars {
            switch scalar {
                case "\"":
                    writer("\\\"") // U+0022 quotation mark
                case "\\":
                    writer("\\\\") // U+005C reverse solidus
                // U+002F solidus not escaped
                case "\u{8}":
                    writer("\\b") // U+0008 backspace
                case "\u{c}":
                    writer("\\f") // U+000C form feed
                case "\n":
                    writer("\\n") // U+000A line feed
                case "\r":
                    writer("\\r") // U+000D carriage return
                case "\t":
                    writer("\\t") // U+0009 tab
                case "\u{0}"..."\u{f}":
                    writer("\\u000\(String(scalar.value, radix: 16))") // U+0000 to U+000F
                case "\u{10}"..."\u{1f}":
                    writer("\\u00\(String(scalar.value, radix: 16))") // U+0010 to U+001F
                default:
                    writer(String(scalar))
            }
        }
        writer("\"")
    }

    func serializeBool(_ bool: Bool) {
        switch bool {
        case true:
            writer("true")
        case false:
            writer("false")
        }
    }

    mutating func serializeNumber(_ num: NSNumber) throws {
        if num.doubleValue.isInfinite || num.doubleValue.isNaN {
            throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: ["NSDebugDescription" : "Number cannot be infinity or NaN"])
        }
        
        // Cannot detect type information (e.g. bool) as there is no objCType property on NSNumber in Swift
        // So, just print the number

        writer(JSON.stringFromNumber(num))
    }

    mutating func serializeArray(_ array: [Any]) throws {
        writer("[")
        if pretty {
            writer("\n")
            incAndWriteIndent()
        }
        
        var first = true
        for elem in array {
            if first {
                first = false
            } else if pretty {
                writer(",\n")
                writeIndent()
            } else {
                writer(",")
            }
            try serializeJSON(elem)
        }
        if pretty {
            writer("\n")
            decAndWriteIndent()
        }
        writer("]")
    }

    mutating func serializeDictionary(_ dict: Dictionary<AnyHashable, Any>) throws {
        writer("{")
        if pretty {
            writer("\n")
            incAndWriteIndent()
        }
        
        var first = true
        
        for (key, value) in dict {
            if first {
                first = false
            } else if pretty {
                writer(",\n")
                writeIndent()
            } else {
                writer(",")
            }
            
            if key is String {
                try serializeString(key as! String)
            } else {
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: ["NSDebugDescription" : "NSDictionary key must be NSString"])
            }
            pretty ? writer(": ") : writer(":")
            try serializeJSON(value)
        }
        if pretty {
            writer("\n")
            decAndWriteIndent()
        }
        writer("}")
    }

    func serializeNull(_ null: NSNull) throws {
        writer("null")
    }
    
    let indentAmount = 2
    
    mutating func incAndWriteIndent() {
        indent += indentAmount
        writeIndent()
    }
    
    mutating func decAndWriteIndent() {
        indent -= indentAmount
        writeIndent()
    }
    
    func writeIndent() {
        for _ in 0..<indent {
            writer(" ")
        }
    }
}


#endif
