//
//  TestJSONValue.swift
//  Test
//
//  Created by Ruoyu Fu on 14-6-21.
//
//

import XCTest

class SwiftyJSONTests: XCTestCase {
    
    var validJSONData:NSData!
    
    override func setUp() {
        validJSONData = NSData(contentsOfFile : NSBundle(forClass:SwiftyJSONTests.self).pathForResource("Valid", ofType: "JSON"))
        super.setUp()
    }
    
    func testJSONValueDoesInitWithDictionaryLiteral() {
        let json = JSONValue(["Key": ["SubKey":"Value"]])
        XCTAssertEqual(json["Key"]["SubKey"].string!, "Value", "Wrong unpacked value")
    }
    
    func testJSONValueDoesInitWithValidData() {
        let json = JSONValue(validJSONData)
        switch json{
        case .JInvalid:
            XCTFail()
        default:
            "Pass"
        }
    }

    func testJSONValueDoesProduceValidValueWithCorrectKeyPath() {
        let json = JSONValue(validJSONData)
        
        let stringValue = json["title"].string
        let urlValue = json["url"].url
        let numberValue = json["id"].number
        let boolValue = json["user"]["site_admin"].bool
        let nullValue = json["closed_by"]
        let arrayValue = json["labels"].array
        let objectValue = json["user"].object
      
        XCTAssert(stringValue == "How do I verify SwiftyJSON workS?")
        XCTAssert(urlValue == NSURL(string: "https://api.github.com/repos/lingoer/SwiftyJSON/issues/2"))
        XCTAssert(numberValue == 36170434)
        XCTAssert(boolValue == false)
        XCTAssert(nullValue == JSONValue.JNull)
        XCTAssert(arrayValue != nil)
        XCTAssert(objectValue != nil)
    }
    
    func testJSONString() {
        let JSON = JSONValue("string")
        XCTAssertEqual(JSON.string!, "string", "Wrong unpacked value")
    }
  
    func testJSONURL() {
        let JSON = JSONValue("http://example.com/")
        XCTAssertEqual(JSON.url!, NSURL(string: "http://example.com/"), "Wrong unpacked value")
    }
  
    func testJSONNumber() {
        let JSON = JSONValue(5)
        XCTAssertEqual(JSON.number!, 5, "Wrong unpacked value")
    }
    
    func testJSONBool() {
        let falseJSON = JSONValue(NSNumber(bool: false))
        XCTAssertEqual(falseJSON.bool!, false, "Wrong unpacked value")
        
        let trueJSON = JSONValue(NSNumber(bool: true))
        XCTAssertEqual(trueJSON.bool!, true, "Wrong unpacked value")
    }
    
    func testJSONArray() {
        let JSON = JSONValue([1, 2])
        let array = [JSONValue(1), JSONValue(2)]
        let result = JSON.array!
        
        XCTAssert(result == array, "Wrong unpacked value")
        XCTAssertEqual(JSON[0].number!, 1, "Wrong unpacked value")
    }
    
    func testJSONObject() {
        let JSON = JSONValue(["name": "Foo", "count": 32])
        let object = ["name": JSONValue("Foo"), "count": JSONValue(32)]
        let result = JSON.object!
        
        XCTAssert(result == object, "Wrong unpacked value")
        XCTAssertEqual(JSON["name"].string!, "Foo", "Wrong unpacked value")
    }
    
    func testPrettyPrintIntegerNumber() {
        let JSON = JSONValue(5.0)
        XCTAssertEqual("5", JSON.description, "Wrong pretty value")
    }
    
    func testPrettyPrintFloatNumber() {
        let JSON = JSONValue(5.1)
        XCTAssertEqual("5.1", JSON.description, "Wrong pretty value")
    }
    
    func testPrettyPrintBool() {
        let trueJSON = JSONValue(true)
        let falseJSON = JSONValue(false)

        XCTAssertEqual("true", trueJSON.description, "Wrong pretty value")
        XCTAssertEqual("false", falseJSON.description, "Wrong pretty value")
    }
    
    func testPrettyPrintObject() {
        let JSON = JSONValue(["key": "value"])
        XCTAssertEqual("{\n  \"key\":\"value\"\n}", JSON.description, "Wrong pretty value")
    }
    
    func testPrettyPrintArray() {
        let JSON = JSONValue(["0", "1"])
        XCTAssertEqual("[\n  \"0\",\n  \"1\"\n]", JSON.description, "Wrong pretty value")

    }
    
    func testPrettyPrintNull() {
        let JSON = JSONValue(NSNull())
        XCTAssertEqual("null", JSON.description, "Wrong pretty value")
    }
    
    func testPrettyPrintString() {
        let JSON = JSONValue("Hi")
        XCTAssertEqual("\"Hi\"", JSON.description, "Wrong pretty value")
    }
    
    func testPrettyPrintURL() {
        let JSON = JSONValue("http://example.com/")
        XCTAssertEqual("\"http://example.com/\"", JSON.description, "Wrong pretty value")
    }
  
}
