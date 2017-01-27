//
//  OptionalsTests.swift
//  SwiftyJSON
//
//  Created by Alessandro "Sandro" Calzavara on 27/01/2017.
//
//

import XCTest
import SwiftyJSON

class OptionalsTests: XCTestCase {
    
    func testBool() {
        
        let value: Bool? = nil
        var json = JSON(parseJSON: "{}")
            
        json.optionalSetter(key: "key", value: value)
        
        XCTAssertEqual(json.debugDescription, "{\n\n}")
    }
    
    func testString() {
        
        let value: String? = nil
        var json = JSON(parseJSON: "{}")
        
        json.optionalSetter(key: "key", value: value)
        
        XCTAssertEqual(json.debugDescription, "{\n\n}")
    }
    
    func testNumber() {
        
        let value: NSNumber? = nil
        var json = JSON(parseJSON: "{}")
        
        json.optionalSetter(key: "key", value: value)
        
        XCTAssertEqual(json.debugDescription, "{\n\n}")
    }
    
    func testInt() {
        
        let value: Int? = nil
        var json = JSON(parseJSON: "{}")
        
        json.optionalSetter(key: "key", value: value)
        
        XCTAssertEqual(json.debugDescription, "{\n\n}")
    }
    
    func testFloat() {
        
        let value: Float? = nil
        var json = JSON(parseJSON: "{}")
        
        json.optionalSetter(key: "key", value: value)
        
        XCTAssertEqual(json.debugDescription, "{\n\n}")
    }
    
    func testDouble() {
        
        let value: Double? = nil
        var json = JSON(parseJSON: "{}")
        
        json.optionalSetter(key: "key", value: value)
        
        XCTAssertEqual(json.debugDescription, "{\n\n}")
    }
}
