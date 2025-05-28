//  ArrayTests.swift
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
@testable import SwiftyJSON

class ArrayTests: XCTestCase {

    func testSingleDimensionalArraysGetter() {
        let array = ["1", "2", "a", "B", "D"]
        let json = JSON(array)
        XCTAssertEqual((json.array![0] as JSON).string!, "1")
        XCTAssertEqual((json.array![1] as JSON).string!, "2")
        XCTAssertEqual((json.array![2] as JSON).string!, "a")
        XCTAssertEqual((json.array![3] as JSON).string!, "B")
        XCTAssertEqual((json.array![4] as JSON).string!, "D")
    }

    func testSingleDimensionalArraysSetter() {
        let array = ["1", "2", "a", "B", "D"]
        var json = JSON(array)
        json.arrayObject = ["111", "222"]
        XCTAssertEqual((json.array![0] as JSON).string!, "111")
        XCTAssertEqual((json.array![1] as JSON).string!, "222")
    }
    
    func testCustomArraySetter() throws {
        // top level setter test
        var array: [Any] = ["oldValue"]
        try array.set("newValue", at: [0])
        XCTAssertEqual(array[0] as? String, "newValue")
        
        // nested value test
        array = [
            ["entities": [
                "url": [
                    "urls": [
                        ["indices": [0, 1]]
                    ]
                ]
            ]]
        ]
        let newIndices = [7, 14]
        let path: [JSONSubscriptType] =  [0, "entities", "url", "urls", 0, "indices"]
        try array.set(newIndices, at: path)
        let extracted = (((array[0] as? [String: Any])?[
            "entities"
        ] as? [String: Any])?["url"] as? [String: Any])?["urls"] as? [[String: Any]]
        let result = extracted?[0]["indices"] as? [Int]
        XCTAssertEqual(result, newIndices)
        
        array = []
        XCTAssertThrowsError(try array.set("value", at: [0])) { error in
            XCTAssertEqual(error as? SwiftyJSONError, .indexOutOfBounds)
        }

        array = ["notAContainer"]
        XCTAssertThrowsError(try array.set("value", at: [0, "entities"])) { error in
            XCTAssertEqual(error as? SwiftyJSONError, .wrongType)
        }
    }
}
