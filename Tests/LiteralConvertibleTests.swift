//  LiteralConvertibleTests.swift
//
//  Copyright (c) 2014 - 2017 Pinglin Tang
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

class LiteralConvertibleTests: XCTestCase {

    func testNumber() {
        var json: JSON = 1234567890.876623
        XCTAssertEqual(json.int!, 1234567890)
        XCTAssertEqual(json.intValue, 1234567890)
        XCTAssertEqual(json.double!, 1234567890.876623)
        XCTAssertEqual(json.doubleValue, 1234567890.876623)
        XCTAssertTrue(json.float! == 1234567890.876623)
        XCTAssertTrue(json.floatValue == 1234567890.876623)
    }

    func testBool() {
        var jsonTrue: JSON = true
        XCTAssertEqual(jsonTrue.bool!, true)
        XCTAssertEqual(jsonTrue.boolValue, true)
        var jsonFalse: JSON = false
        XCTAssertEqual(jsonFalse.bool!, false)
        XCTAssertEqual(jsonFalse.boolValue, false)
    }

    func testString() {
        var json: JSON = "abcd efg, HIJK;LMn"
        XCTAssertEqual(json.string!, "abcd efg, HIJK;LMn")
        XCTAssertEqual(json.stringValue, "abcd efg, HIJK;LMn")
    }

    func testNil() {
        let jsonNil_1: JSON = JSON.null
        XCTAssert(jsonNil_1 == JSON.null)
        let jsonNil_2: JSON = JSON(NSNull.self)
        XCTAssert(jsonNil_2 != JSON.null)
        let jsonNil_3: JSON = JSON([1: 2])
        XCTAssert(jsonNil_3 != JSON.null)
    }

    func testArray() {
        let json: JSON = [1, 2, "4", 5, "6"]
        XCTAssertEqual(json.array!, [1, 2, "4", 5, "6"])
        XCTAssertEqual(json.arrayValue, [1, 2, "4", 5, "6"])
    }

    func testDictionary() {
        let json: JSON = ["1": 2, "2": 2, "three": 3, "list": ["aa", "bb", "dd"]]
        XCTAssertEqual(json.dictionary!, ["1": 2, "2": 2, "three": 3, "list": ["aa", "bb", "dd"]])
        XCTAssertEqual(json.dictionaryValue, ["1": 2, "2": 2, "three": 3, "list": ["aa", "bb", "dd"]])
    }
}
