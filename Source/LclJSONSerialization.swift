/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

#if os(Linux)

import Foundation

public let LclErrorDomain = "Lcl.Error.Domain"


public class LclJSONSerialization {
    private static let JSON_WRITE_ERROR = "JSON Write failure."

    private static let FALSE = "false"
    private static let TRUE = "true"
    private static let NULL = "null"


    public class func isValidJSONObject(_ obj: Any) -> Bool {
        // TODO: - revisit this once bridging story gets fully figured out
        func isValidJSONObjectInternal(_ obj: Any) -> Bool {
            // object is Swift.String or NSNull
            if obj is String || obj is Int || obj is Bool || obj is NSNull || obj is UInt {
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

            let mirror = Mirror(reflecting: obj)
            if  mirror.displayStyle == .collection  {
                // object is Swift.Array
                for element in mirror.children {
                    guard isValidJSONObjectInternal(element.value) else {
                        return false
                    }
                }
                return true
            }
            else if  mirror.displayStyle == .dictionary  {
                // object is Swift.Dictionary
                for pair in mirror.children {
                    let pairMirror = Mirror(reflecting: pair.value)
                    if  pairMirror.displayStyle == .tuple  &&  pairMirror.children.count == 2 {
                        let generator = pairMirror.children.makeIterator()
                        if  generator.next()!.value is String {
                            guard isValidJSONObjectInternal(generator.next()!.value) else {
                                return false
                            }
                        }
                        else {
                            // Invalid JSON Object, Key not a String
                            return false
                        }
                    }
                    else {
                        // Invalid Dictionary
                        return false
                    }
                }
                return true
            }
            else {
                // invalid object
                return false
            }
        }

        // top level object must be an Swift.Array or Swift.Dictionary
        let mirror = Mirror(reflecting: obj)
        guard mirror.displayStyle == .collection || mirror.displayStyle == .dictionary else {
            return false
        }

        return isValidJSONObjectInternal(obj)
    }

    public class func dataWithJSONObject(_ obj: Any, options: JSONSerialization.WritingOptions) throws -> Data
    {
        var result = Data()

        try writeJson(obj, options: options) { (str: String?) in
            if  let str = str  {
                result.append(str.data(using: String.Encoding.utf8) ?? Data())
            }
        }

        return result
    }

    /* Helper function to enable writing to NSData as well as NSStream */
    private static func writeJson(_ obj: Any, options opt: JSONSerialization.WritingOptions, writer: (String?) -> Void) throws {
        let prettyPrint = opt.rawValue & JSONSerialization.WritingOptions.prettyPrinted.rawValue  != 0
        let padding: String? = prettyPrint ? "" : nil

        try writeJsonValue(obj, padding: padding, writer: writer)
    }

    /* Write out a JSON value (simple value, object, or array) */
    private static func writeJsonValue(_ obj: Any, padding: String?, writer: (String?) -> Void) throws {
        if  obj is String  {
            writer("\"")
            writer((obj as! String))
            writer("\"")
        }
        else if  obj is Bool  {
            writer(obj as! Bool ? TRUE : FALSE)
        }
        else if  obj is Int || obj is Float || obj is Double || obj is UInt {
            writer(String(describing: obj))
        }
        else if  obj is NSNumber  {
            writer(JSON.stringFromNumber(obj as! NSNumber))
        }
        else if obj is NSNull {
            writer(NULL)
        }
        else {
            let mirror = Mirror(reflecting: obj)
            if  mirror.displayStyle == .collection  {
                try writeJsonArray(mirror.children.map { $0.value as Any }, padding: padding, writer: writer)
            }
            else if  mirror.displayStyle == .dictionary  {
                try writeJsonObject(mirror.children.map { $0.value }, padding: padding, writer: writer)
            }
            else {
                print("writeJsonValue: Unsupported type \(type(of: obj))")
                throw createWriteError("Unsupported data type to be written out as JSON")
            }
        }
    }

    /* Write out a dictionary as a JSON object */
    private static func writeJsonObject(_ pairs: Array<Any>, padding: String?, writer: (String?) -> Void) throws {
        let (nestedPadding, startOfLine, endOfLine) = setupPadding(padding)
        let nameValueSeparator = padding != nil ? ": " : ":"

        writer("{")

        var comma = ""
        let realComma = ","
        for pair in pairs {
           let pairMirror = Mirror(reflecting: pair)
           if  pairMirror.displayStyle == .tuple  &&  pairMirror.children.count == 2 {
               let generator = pairMirror.children.makeIterator()
               if  let key = generator.next()!.value as? String {
                   let value = generator.next()!.value
                   writer(comma)
                   comma = realComma
                   writer(endOfLine)
                   writer(nestedPadding)
                   writer("\"")
                   writer(key)
                   writer("\"")
                   writer(nameValueSeparator)
                   try writeJsonValue(value, padding: nestedPadding, writer: writer)
               }
           }
        }
        writer(endOfLine)

        writer(startOfLine)
        writer("}")
    }

    /* Write out an array as a JSON Array */
    private static func writeJsonArray(_ obj: Array<Any>, padding: String?, writer: (String?) -> Void) throws {
        let (nestedPadding, startOfLine, endOfLine) = setupPadding(padding)
        writer("[")

        var comma = ""
        let realComma = ","
        for value in obj {
            writer(comma)
            comma = realComma
            writer(endOfLine)
            writer(nestedPadding)
            try writeJsonValue(value, padding: nestedPadding, writer: writer)
        }
        writer(endOfLine)

        writer(startOfLine)
        writer("]")
    }

    /* Setup "padding" to be used in objects and arrays.

       Note: if padding is nil, then all padding, newlines etc., are suppressed
    */
    private static func setupPadding(_ padding: String?) -> (String?, String?, String?) {
        var nestedPadding: String?
        var startOfLine: String?
        var endOfLine: String?
        if  let padding = padding  {
            nestedPadding = padding + "  "
            startOfLine = padding
            endOfLine = "\n"
        }
        else {
            nestedPadding = nil
            startOfLine = nil
            endOfLine = nil
        }
        return (nestedPadding, startOfLine, endOfLine)
    }

    private static func createWriteError(_ reason: String) -> NSError {
        let userInfo: [String: Any] = [NSLocalizedDescriptionKey: JSON_WRITE_ERROR,
            NSLocalizedFailureReasonErrorKey: reason]
        return NSError(domain: LclErrorDomain, code: 1, userInfo: userInfo)
    }
}
#endif
