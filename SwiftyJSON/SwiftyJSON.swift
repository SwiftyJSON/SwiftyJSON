//
//  SwiftJSON.swift
//  SwiftJSON
//
//  Created by Ruoyu Fu on 14-6-16.
//  Copyright (c) 2014年 Ruoyu Fu. All rights reserved.
//

import Foundation

func ==(lhs: JSONValue, rhs: JSONValue) -> Bool {
    switch lhs{
    case .JNumber(let lvalue):
        switch rhs{
        case .JNumber(let rvalue):
            return rvalue == lvalue
        default:
            return false
        }
    case .JString(let lvalue):
        switch rhs{
        case .JString(let rvalue):
            return rvalue == lvalue
        default:
            return false
        }
    case .JBool(let lvalue):
        switch rhs{
        case .JBool(let rvalue):
            return rvalue == lvalue
        default:
            return false
        }
    case .JNull:
        switch rhs{
        case .JNull:
            return true
        default:
            return false
        }
    case .JArray(let lvalue):
        switch rhs{
        case .JArray(let rvalue):
            return rvalue == lvalue
        default:
            return false
        }
    case .JObject(let lvalue):
        switch rhs{
        case .JObject(let rvalue):
            return rvalue == lvalue
        default:
            return false
        }
    
    default:
        return false
    }
}

enum JSONValue:LogicValue, Equatable, Printable {

    case JNumber(Double)
    case JString(String)
    case JBool(Bool)
    case JNull
    case JArray(Array<JSONValue>)
    case JObject(Dictionary<String,JSONValue>)
    case JInvalid
    
    var string:String?{
        switch self{
        case .JString(let value):
            return value
        default:
            return nil
        }
    }
    var number:Double?{
        switch self{
        case .JNumber(let value):
            return value
        default:
            return nil
        }
    }
    var bool:Bool?{
        switch self{
        case .JBool(let value):
            return value
        default:
            return nil
        }
    }
    var array:Array<JSONValue>?{
        switch self{
        case .JArray(let value):
            return value
        default:
            return nil
        }
    }
    var object:Dictionary<String,JSONValue>?{
        switch self{
        case .JObject(let value):
            return value
        default:
            return nil
        }
    }
    
//    init(_ rawValue:Any){
//        
//        switch rawValue{
//        case let value as Int:
//            self = .JNumber(Double(value))
//        case let value as Double:
//            self = .JNumber(value)
//        case let value as Bool:
//            self = .JBool(value)
//        case let value as String:
//            self = .JString(value)
//        case let value as Array<JSONValue>:
//            self = .JArray(value)
//        case let value as Dictionary<String,JSONValue>:
//            self = .JObject(value)
//        case let value as JSONValue:
//            self = value
//        default:
//            self = .JInvalid
//        }
//    }
    
    init (_ rawObject:AnyObject){
        switch rawObject{
        case let value as NSData:
            if let jsonObject : AnyObject = NSJSONSerialization.JSONObjectWithData(value, options: NSJSONReadingOptions.MutableContainers, error: nil){
                self = JSONValue(jsonObject)
            }else{
                self = JSONValue.JInvalid
            }
        case let value as NSNumber:
            if String.fromCString(value.objCType) == "c"{
                self = .JBool(value.boolValue)
                return
            }
            self = .JNumber(value.doubleValue)
        case let value as NSString:
            self = .JString(value)
        case let value as NSNull:
            self = .JNull
        case let value as NSArray:
            var jsonValues = JSONValue[]()
            for possibleJsonValue : AnyObject in value{
                let jsonValue = JSONValue(possibleJsonValue)
                if jsonValue{
                    jsonValues.append(jsonValue)
                }
            }
            self = .JArray(jsonValues)
        case let value as NSDictionary:
            var jsonObject = Dictionary<String,JSONValue>()
            for (possibleJsonKey : AnyObject,possibleJsonValue : AnyObject) in value{
                if let key = possibleJsonKey as? NSString{
                    let jsonValue = JSONValue(possibleJsonValue)
                    if jsonValue{
                        jsonObject[key]=jsonValue
                    }
                }
            }
            self = .JObject(jsonObject)
        default:
            self = .JInvalid
        }
    }

    subscript(index: Int) -> JSONValue {
        get {
            switch self{
            case .JArray(let jsonArray) where jsonArray.count > index:
                return jsonArray[index]
            default:
                return JSONValue.JInvalid
            }
        }
    }
    
    subscript(key: String) -> JSONValue {
        get {
            switch self{
            case .JObject(let jsonDictionary):
                if let value = jsonDictionary[key]{
                    return value
                }else{
                    return JSONValue.JInvalid
                }
            default:
                return JSONValue.JInvalid
            }
        }
    }
    
    func getLogicValue() -> Bool{
        switch self{
        case .JInvalid:
            return false
        default:
            return true
        }
    }
    
    var rawJSONString: String{
        switch self{
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
            var arrayString = "["
            for (index, value) in enumerate(array) {
                if index != array.count - 1{
                    arrayString += "\(value.description),"
                }else{
                    arrayString += "\(value.description)"
                }
            }
            arrayString += "]"
            return arrayString
        case .JObject(let object):
            var objectString = "{"
            var (index, count) = (0, object.count)
            for (key, value) in object{
                if index != count - 1{
                    objectString += "\"\(key)\":\(value.description),"
                }else{
                    objectString += "\"\(key)\":\(value.description)"
                }
                index += 1
            }
            objectString += "}"
            return objectString
        case .JInvalid:
            return "INVALID_JSON_VALUE"
        }
    }
    
    func printableString(indent:String)->String{
        switch self{
        case .JObject(let object):
            var objectString = "{\n"
            var (index, count) = (0, object.count)
            for (key, value) in object{
                let valueString = value.printableString(indent + "  ")
                if index != count - 1{
                    objectString += "\(indent)  \"\(key)\":\(valueString),\n"
                }else{
                    objectString += "\(indent)  \"\(key)\":\(valueString)\n"
                }
                index += 1
            }
            objectString += "\(indent)}"
            return objectString
        case .JArray(let array):
            var arrayString = "[\n"
            for (index, value) in enumerate(array) {
                let valueString = value.printableString(indent + "  ")
                if index != array.count - 1{
                    arrayString += "\(indent)  \(valueString),\n"
                }else{
                    arrayString += "\(indent)  \(valueString)\n"
                }
            }
            arrayString += "\(indent)]"
            return arrayString
        default:
            return self.rawJSONString
        }
    }
    
    var description: String {
        return self.printableString("")
    }
}
