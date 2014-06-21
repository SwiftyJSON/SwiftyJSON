//
//  TestJSONValue.swift
//  Test
//
//  Created by Ruoyu Fu on 14-6-21.
//
//

import XCTest

class TestJSONValue: XCTestCase {
    
    var validJSONData:NSData = NSData(contentsOfFile : NSBundle(forClass:TestJSONValue.self).pathForResource("Valid", ofType: "JSON", inDirectory: "Resource"))
    
    override func setUp() {
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
    
}
