//
//  TestJSONValue.swift
//  Test
//
//  Created by Ruoyu Fu on 14-6-21.
//
//

import XCTest
import SwiftyJSON

class SwiftyJSONTests: XCTestCase {
    
    var validJSONData:NSData!
    
    override func setUp() {
        validJSONData = NSData(contentsOfFile : NSBundle(forClass:SwiftyJSONTests.self).pathForResource("Valid", ofType: "JSON"))
        super.setUp()
    }
    
    func testJSONValueDoesInitWithValidData() {
        let json = JSONValue(validJSONData)
        XCTAssert(json != JSONValue.JInvalid, "Pass")
    }

    func testJSONValueDoesProduceValidValueWithCorrectKeyPath() {
        let json = JSONValue(validJSONData)
        
        let stringValue = json["title"].string
        let numberValue = json["id"].number
        let boolValue = json["user"]["site_admin"].bool
        let nullValue = json["closed_by"]
        let arrayValue = json["labels"].array
        let objectValue = json["user"].object
        
        XCTAssert(stringValue == "How do I verify SwiftyJSON workS?")
        XCTAssert(numberValue == 36170434)
        XCTAssert(boolValue == false)
        XCTAssert(nullValue == JSONValue.JNull)
        XCTAssert(arrayValue)
        XCTAssert(objectValue)
    }
    
    func testPrettyPrintNumber() {
        let JSON = JSONValue(5)
        XCTAssertEqual("5.0", JSON.description, "Wrong pretty value")
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
    
    
    
}
