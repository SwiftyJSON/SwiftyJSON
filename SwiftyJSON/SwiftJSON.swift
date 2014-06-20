//
//  SwiftJSON.swift
//  SwiftJSON
//
//  Created by Ruoyu Fu on 14-6-16.
//  Copyright (c) 2014年 Ruoyu Fu. All rights reserved.
//

import Foundation

func ==(lhs: JSONValue, rhs: JSONValue) -> Bool{
    switch lhs{
    case .NUMBER(let lvalue):
        switch rhs{
        case .NUMBER(let rvalue):
            return (rvalue == lvalue) ? true:false
        default:
            return false
        }
    case .STRING(let lvalue):
        switch rhs{
        case .STRING(let rvalue):
            return (rvalue == lvalue) ? true:false
        default:
            return false
        }
    case .BOOL(let lvalue):
        switch rhs{
        case .BOOL(let rvalue):
            return (rvalue == lvalue) ? true:false
        default:
            return false
        }
    case .NULL:
        switch rhs{
        case .NULL:
            return true
        default:
            return false
        }
    case .ARRAY(let lvalue):
        switch rhs{
        case .ARRAY(let rvalue):
            return (rvalue == lvalue) ? true:false
        default:
            return false
        }
    case .OBJECT(let lvalue):
        switch rhs{
        case .OBJECT(let rvalue):
            return (rvalue == lvalue) ? true:false
        default:
            return false
        }
    
    default:
        return false
    }
}

enum JSONValue:LogicValue,Equatable,Printable{

    case NUMBER(Double)
    case STRING(String)
    case BOOL(Bool)
    case NULL
    case ARRAY(Array<JSONValue>)
    case OBJECT(Dictionary<String,JSONValue>)
    case INVALID
    
    var string:String?{
        switch self{
        case .STRING(let value):
            return value
        default:
            return nil
        }
    }
    var number:Double?{
        switch self{
        case .NUMBER(let value):
            return value
        default:
            return nil
        }
    }
    var bool:Bool?{
        switch self{
        case .BOOL(let value):
            return value
        default:
            return nil
        }
    }
    var array:Array<JSONValue>?{
        switch self{
        case .ARRAY(let value):
            return value
        default:
            return nil
        }
    }
    var object:Dictionary<String,JSONValue>?{
        switch self{
        case .OBJECT(let value):
            return value
        default:
            return nil
        }
    }
    
    init(_ rawValue:Any){
        
        switch rawValue{
        case let value as Int:
            self = .NUMBER(Double(value))
        case let value as Double:
            self = .NUMBER(value)
        case let value as Bool:
            self = .BOOL(value)
        case let value as String:
            self = .STRING(value)
        case let value as Array<JSONValue>:
            self = .ARRAY(value)
        case let value as Dictionary<String,JSONValue>:
            self = .OBJECT(value)
        case let value as JSONValue:
            self = value
        default:
            self = .INVALID
        }
    }
    
    init (_ rawObject:AnyObject){
        switch rawObject{
        case let value as NSData:
            self = JSONValue(NSJSONSerialization.JSONObjectWithData(value, options: NSJSONReadingOptions.MutableContainers, error: nil))
        case let value as NSNumber:
            if String.fromCString(value.objCType) == "c"{
                self = .BOOL(value.boolValue)
            }
            self = .NUMBER(value.doubleValue)
        case let value as NSString:
            self = .STRING(value)
        case let value as NSNull:
            self = .NULL
        case let value as NSArray:
            var jsonValues = JSONValue[]()
            for possibleJsonValue : AnyObject in value{
                let jsonValue = JSONValue(possibleJsonValue)
                if jsonValue{
                    jsonValues.append(jsonValue)
                }
            }
            self = .ARRAY(jsonValues)
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
            self = .OBJECT(jsonObject)
        default:
            self = .INVALID
        }
    }

    subscript(index: Int) -> JSONValue {
        get {
            switch self{
            case .ARRAY(let jsonArray) where jsonArray.count > index:
                return jsonArray[index]
            default:
                return JSONValue.INVALID
            }
        }
    }
    
    subscript(key: String) -> JSONValue {
        get {
            switch self{
            case .OBJECT(let jsonDictionary):
                if let value = jsonDictionary[key]{
                    return value
                }else{
                    return JSONValue.INVALID
                }
            default:
                return JSONValue.INVALID
            }
        }
    }
    
    func getLogicValue() -> Bool{
        switch self{
        case .INVALID:
            return false
        default:
            return true
        }
    }
    
    var rawJSONString: String{
        switch self{
        case .NUMBER(let value):
            return "\(value)"
        case BOOL(let value):
            return "\(value)"
        case STRING(let value):
            
            let jsonAbleString = value.stringByReplacingOccurrencesOfString("\"", withString: "\\\"", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
            return "\"\(jsonAbleString)\""
        case NULL:
            return "null"
        case ARRAY(let array):
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
        case OBJECT(let object):
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
        case INVALID:
            return "INVALID_JSON_VALUE"
        }
    }
    
    func printableString(indent:String)->String{
        switch self{
        case .OBJECT(let object):
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
        case .ARRAY(let array):
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
