//  MutabilityTests.swift
//
//  Copyright (c) 2014 - 2017 Zigii Wong
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

class MutabilityTests: XCTestCase {

    func testDictionaryMutability() {
        let dictionary: [String: Any] = [
            "string": "STRING",
            "number": 9823.212,
            "bool": true,
            "empty": ["nothing"],
            "foo": ["bar": ["1"]],
            "bar": ["foo": ["1": "a"]]
        ]

        var json = JSON(dictionary)
        XCTAssertEqual(json["string"], "STRING")
        XCTAssertEqual(json["number"], 9823.212)
        XCTAssertEqual(json["bool"], true)
        XCTAssertEqual(json["empty"], ["nothing"])

        json["string"] = "muted"
        XCTAssertEqual(json["string"], "muted")

        json["number"] = 9999.0
        XCTAssertEqual(json["number"], 9999.0)

        json["bool"] = false
        XCTAssertEqual(json["bool"], false)

        json["empty"] = []
        XCTAssertEqual(json["empty"], [])

        json["new"] = JSON(["foo": "bar"])
        XCTAssertEqual(json["new"], ["foo": "bar"])

        json["foo"]["bar"] = JSON([])
        XCTAssertEqual(json["foo"]["bar"], [])

        json["bar"]["foo"] = JSON(["2": "b"])
        XCTAssertEqual(json["bar"]["foo"], ["2": "b"])
    }

    func testArrayMutability() {
        let array: [Any] = ["1", "2", 3, true, []]

        var json = JSON(array)
        XCTAssertEqual(json[0], "1")
        XCTAssertEqual(json[1], "2")
        XCTAssertEqual(json[2], 3)
        XCTAssertEqual(json[3], true)
        XCTAssertEqual(json[4], [])

        json[0] = false
        XCTAssertEqual(json[0], false)

        json[1] = 2
        XCTAssertEqual(json[1], 2)

        json[2] = "3"
        XCTAssertEqual(json[2], "3")

        json[3] = [:]
        XCTAssertEqual(json[3], [:])

        json[4] = [1, 2]
        XCTAssertEqual(json[4], [1, 2])
    }

    func testValueMutability() {
        var intArray = JSON([0, 1, 2])
        intArray[0] = JSON(55)
        XCTAssertEqual(intArray[0], 55)
        XCTAssertEqual(intArray[0].intValue, 55)

        var dictionary = JSON(["foo": "bar"])
        dictionary["foo"] = JSON("foo")
        XCTAssertEqual(dictionary["foo"], "foo")
        XCTAssertEqual(dictionary["foo"].stringValue, "foo")

        var number = JSON(1)
        number = JSON("111")
        XCTAssertEqual(number, "111")
        XCTAssertEqual(number.intValue, 111)
        XCTAssertEqual(number.stringValue, "111")

        var boolean = JSON(true)
        boolean = JSON(false)
        XCTAssertEqual(boolean, false)
        XCTAssertEqual(boolean.boolValue, false)
    }

    func testArrayRemovability() {
        let array = ["Test", "Test2", "Test3"]
        var json = JSON(array)

        json.arrayObject?.removeFirst()
        XCTAssertEqual(false, json.arrayValue.isEmpty)
        XCTAssertEqual(json.arrayValue, ["Test2", "Test3"])

        json.arrayObject?.removeLast()
        XCTAssertEqual(false, json.arrayValue.isEmpty)
        XCTAssertEqual(json.arrayValue, ["Test2"])

        json.arrayObject?.removeAll()
        XCTAssertEqual(true, json.arrayValue.isEmpty)
        XCTAssertEqual(JSON([]), json)
    }

    func testDictionaryRemovability() {
        let dictionary: [String: Any] = ["key1": "Value1", "key2": 2, "key3": true]
        var json = JSON(dictionary)

        json.dictionaryObject?.removeValue(forKey: "key1")
        XCTAssertEqual(false, json.dictionaryValue.isEmpty)
        XCTAssertEqual(json.dictionaryValue, ["key2": 2, "key3": true])

        json.dictionaryObject?.removeValue(forKey: "key3")
        XCTAssertEqual(false, json.dictionaryValue.isEmpty)
        XCTAssertEqual(json.dictionaryValue, ["key2": 2])

        json.dictionaryObject?.removeAll()
        XCTAssertEqual(true, json.dictionaryValue.isEmpty)
        XCTAssertEqual(json.dictionaryValue, [:])
    }
}
