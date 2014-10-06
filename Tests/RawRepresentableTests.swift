//
//  RawRepresentable.swift
//  SwiftyJSON
//
//  Created by Pinglin Tang on 14-10-6.
//
//

import UIKit
import XCTest
import SwiftyJSON

class RawRepresentableTests: XCTestCase {

    func testNumber() {
        var json:JSON = JSON.fromRaw(948394394.347384 as NSNumber)!
        XCTAssertEqual(json.int!, 948394394)
        XCTAssertEqual(json.intValue, 948394394)
        XCTAssertEqual(json.double!, 948394394.347384)
        XCTAssertEqual(json.doubleValue, 948394394.347384)
        XCTAssertEqual(json.float!, 948394394.347384)
        XCTAssertEqual(json.floatValue, 948394394.347384)
        
        var object: AnyObject = json.toRaw()
        XCTAssertEqual(object as Int, 948394394)
        XCTAssertEqual(object as Double, 948394394.347384)
        XCTAssertEqual(object as Float, 948394394.347384)
        XCTAssertEqual(object as NSNumber, 948394394.347384)
    }
    
    func testBool() {
        var jsonTrue:JSON = JSON.fromRaw(true as NSNumber)!
        XCTAssertEqual(jsonTrue.bool!, true)
        XCTAssertEqual(jsonTrue.boolValue, true)
        
        var jsonFalse:JSON = JSON.fromRaw(false)!
        XCTAssertEqual(jsonFalse.bool!, false)
        XCTAssertEqual(jsonFalse.boolValue, false)
        
        var objectTrue: AnyObject = jsonTrue.toRaw()
        XCTAssertEqual(objectTrue as Int, 1)
        XCTAssertEqual(objectTrue as Double, 1.0)
        XCTAssertEqual(objectTrue as Float, 1.0)
        XCTAssertEqual(objectTrue as Bool, true)
        XCTAssertEqual(objectTrue as NSNumber, NSNumber(bool: true))
        
        var objectFalse: AnyObject = jsonFalse.toRaw()
        XCTAssertEqual(objectFalse as Int, 0)
        XCTAssertEqual(objectFalse as Double, 0.0)
        XCTAssertEqual(objectFalse as Float, 0.0)
        XCTAssertEqual(objectFalse as Bool, false)
        XCTAssertEqual(objectFalse as NSNumber, NSNumber(bool: false))
    }
    
    func testString() {
        let string = "The better way to deal with JSON data in Swift."
        if let json:JSON = JSON.fromRaw(string) {
            XCTAssertEqual(json.string!, string)
            XCTAssertEqual(json.stringValue, string)
            XCTAssertTrue(json.array == nil)
            XCTAssertTrue(json.dictionary == nil)
            XCTAssertTrue(json.null == nil)
            XCTAssertTrue(json.error == nil)
            XCTAssertTrue(json.type == .String)
            XCTAssertEqual(json.object as String, string)
        } else {
            XCTFail("Should not run into here")
        }
        
        let object: AnyObject = JSON.fromRaw(string)!.toRaw()
        XCTAssertEqual(object as String, string)
    }
    
    func testNil() {
        if let json = JSON.fromRaw(NSObject()) {
            XCTFail("Should not run into here")
        }
    }
    
    func testArray() {
        let array = [1,2,"3",4102,"5632", "abocde", "!@# $%^&*()"] as NSArray
        if let json:JSON = JSON.fromRaw(array) {
            XCTAssertEqual(json, JSON(array))
        }
        
        let object: AnyObject = JSON.fromRaw(array)!.toRaw()
        XCTAssertTrue(array == object as NSArray)
    }
    
    func testDictionary() {
        let dictionary = ["1":2,"2":2,"three":3,"list":["aa","bb","dd"]] as NSDictionary
        if let json:JSON = JSON.fromRaw(dictionary) {
            XCTAssertEqual(json, JSON(dictionary))
        }

        let object: AnyObject = JSON.fromRaw(dictionary)!.toRaw()
        XCTAssertTrue(dictionary == object as NSDictionary)
    }
}
