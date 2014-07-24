//  SwiftyJSON.swift
//
//  Copyright (c) 2014年 Ruoyu Fu, Denis Lebedev.
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

public enum JSONValue: Printable {
    
    case JNumber(NSNumber)
    case JString(String)
    case JBool(Bool)
    case JNull
    case JArray(Array<JSONValue>)
    case JObject(Dictionary<String,JSONValue>)
    case JInvalid
    
    public var string: String? {
    switch self {
    case .JString(let value):
        return value
    default:
        return nil
        }
    }
    
    public var number: NSNumber? {
    switch self {
    case .JNumber(let value):
        return value
    default:
        return nil
        }
    }
    
    public var double: Double? {
    switch self {
    case .JNumber(let value):
        return value.doubleValue
    default:
        return nil
        }
    }
    
    public var integer: Int? {
    switch self {
    case .JNumber(let value):
        return value.integerValue
    default:
        return nil
        }
    }
    
    public var bool: Bool? {
    switch self {
    case .JBool(let value):
        return value
    default:
        return nil
        }
    }
    public var array: Array<JSONValue>? {
    switch self {
    case .JArray(let value):
        return value
    default:
        return nil
        }
    }
    public var object: Dictionary<String, JSONValue>? {
    switch self {
    case .JObject(let value):
        return value
    default:
        return nil
        }
    }
    
    public init (_ rawObject: AnyObject) {
        switch rawObject {
        case let value as NSData:
            if let jsonObject : AnyObject = NSJSONSerialization.JSONObjectWithData(value, options: nil, error: nil) {
                self = JSONValue(jsonObject)
            } else {
                self = JSONValue.JInvalid
            }
        case let value as NSNumber:
            if String.fromCString(value.objCType) == "c" {
                self = .JBool(value.boolValue)
                return
            }
            self = .JNumber(value)
        case let value as NSString:
            self = .JString(value)
        case let value as NSNull:
            self = .JNull
        case let value as NSArray:
            var jsonValues = [JSONValue]()
            for possibleJsonValue : AnyObject in value {
                let jsonValue = JSONValue(possibleJsonValue)
                if  jsonValue {
                    jsonValues.append(jsonValue)
                }
            }
            self = .JArray(jsonValues)
        case let value as NSDictionary:
            var jsonObject = Dictionary<String, JSONValue>()
            for (possibleJsonKey : AnyObject, possibleJsonValue : AnyObject) in value {
                if let key = possibleJsonKey as? NSString {
                    let jsonValue = JSONValue(possibleJsonValue)
                    if jsonValue {
                        jsonObject[key] = jsonValue
                    }
                }
            }
            self = .JObject(jsonObject)
        default:
            self = .JInvalid
        }
    }
    
    public subscript(index: Int) -> JSONValue {
        get {
            switch self {
            case .JArray(let jsonArray) where jsonArray.count > index:
                return jsonArray[index]
            default:
                return JSONValue.JInvalid
            }
        }
    }
    
    public subscript(key: String) -> JSONValue {
        get {
            switch self {
            case .JObject(let jsonDictionary):
                if let value = jsonDictionary[key] {
                    return value
                }else {
                    return JSONValue.JInvalid
                }
            default:
                return JSONValue.JInvalid
            }
        }
    }
}

extension JSONValue: Printable {
    
    public var description: String {
    return _printableString("")
    }
    
    var _rawJSONString: String {
    switch self {
    case .JNumber(let value):
        return "\(value)"
    case .JBool(let value):
        return "\(value)"
    case .JString(let value):
        let jsonAbleString = value.stringByReplacingOccurrencesOfString("\"", withString: "\\\"", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        return "\"\(jsonAbleString)\""
    case .JNull:
        return "null"
    case .JArray(let array):
        var arrayString = ""
        for (index, value) in enumerate(array) {
            if index != array.count - 1 {
                arrayString += "\(value),"
            }else{
                arrayString += "\(value)"
            }
        }
        return "[\(arrayString)]"
    case .JObject(let object):
        var objectString = ""
        var (index, count) = (0, object.count)
        for (key, value) in object {
            if index != count - 1 {
                objectString += "\"\(key)\":\(value),"
            } else {
                objectString += "\"\(key)\":\(value)"
            }
            index += 1
        }
        return "[\(objectString)]"
    case .JInvalid:
        return "INVALID_JSON_VALUE"
        }
    }
    
    func _printableString(indent: String) -> String {
        switch self {
        case .JObject(let object):
            var objectString = "{\n"
            var index = 0
            for (key, value) in object {
                let valueString = value._printableString(indent + "  ")
                if index != object.count - 1 {
                    objectString += "\(indent)  \"\(key)\":\(valueString),\n"
                } else {
                    objectString += "\(indent)  \"\(key)\":\(valueString)\n"
                }
                index += 1
            }
            objectString += "\(indent)}"
            return objectString
        case .JArray(let array):
            var arrayString = "[\n"
            for (index, value) in enumerate(array) {
                let valueString = value._printableString(indent + "  ")
                if index != array.count - 1 {
                    arrayString += "\(indent)  \(valueString),\n"
                }else{
                    arrayString += "\(indent)  \(valueString)\n"
                }
            }
            arrayString += "\(indent)]"
            return arrayString
        default:
            return _rawJSONString
        }
    }
    
}

extension JSONValue: LogicValue {
    public func getLogicValue() -> Bool {
        switch self {
        case .JInvalid:
            return false
        default:
            return true
        }
    }
}

extension JSONValue : Equatable {}

public func ==(lhs: JSONValue, rhs: JSONValue) -> Bool {
    switch lhs {
    case .JNumber(let lvalue):
        switch rhs {
        case .JNumber(let rvalue):
            return rvalue == lvalue
        default:
            return false
        }
    case .JString(let lvalue):
        switch rhs {
        case .JString(let rvalue):
            return rvalue == lvalue
        default:
            return false
        }
    case .JBool(let lvalue):
        switch rhs {
        case .JBool(let rvalue):
            return rvalue == lvalue
        default:
            return false
        }
    case .JNull:
        switch rhs {
        case .JNull:
            return true
        default:
            return false
        }
    case .JArray(let lvalue):
        switch rhs {
        case .JArray(let rvalue):
            return rvalue == lvalue
        default:
            return false
        }
    case .JObject(let lvalue):
        switch rhs {
        case .JObject(let rvalue):
            return rvalue == lvalue
        default:
            return false
        }
    default:
        return false
    }
}