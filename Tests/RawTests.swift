//  RawTests.swift
//
//  Copyright (c) 2014 Pinglin Tang
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

import XCTest
import SwiftyJSON

class RawTests: XCTestCase {

    func testRawData() {
        let json: JSON = ["somekey" : "some string value"]
        let expectedRawData = "{\"somekey\":\"some string value\"}".dataUsingEncoding(NSUTF8StringEncoding)
        do {
            let data: NSData = try json.rawData()
            XCTAssertEqual(expectedRawData, data)
        } catch _ {
            XCTFail()
        }
    }
    
    func testInvalidJSONForRawData() {
        let json: JSON = "...<nonsense>xyz</nonsense>"
        do {
            try json.rawData()
        } catch let error as NSError {
            XCTAssertEqual(error.code, ErrorInvalidJSON)
        }
    }
    
    func testArray() {
        let json:JSON = [1, "2", 3.12, NSNull(), true, ["name": "Jack"]]
        let data: NSData?
        do {
            data = try json.rawData()
        } catch _ {
            data = nil
        }
        let string = json.rawString()
        XCTAssertTrue (data != nil)
        XCTAssertTrue (string!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0)
        print(string!)
    }
    
    func testDictionary() {
        let json:JSON = ["number":111111.23456789, "name":"Jack", "list":[1,2,3,4], "bool":false, "null":NSNull()]
        let data: NSData?
        do {
            data = try json.rawData()
        } catch _ {
            data = nil
        }
        let string = json.rawString()
        XCTAssertTrue (data != nil)
        XCTAssertTrue (string!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0)
        print(string!)
    }
    
    func testString() {
        let json:JSON = "I'm a json"
        print(json.rawString())
        XCTAssertTrue(json.rawString() == "I'm a json")
    }
    
    func testNumber() {
        let json:JSON = 123456789.123
        print(json.rawString())
        XCTAssertTrue(json.rawString() == "123456789.123")
    }
    
    func testBool() {
        let json:JSON = true
        print(json.rawString())
        XCTAssertTrue(json.rawString() == "true")
    }
    
    func testNull() {
        let json:JSON = nil
        print(json.rawString())
        XCTAssertTrue(json.rawString() == "null")
    }
}
