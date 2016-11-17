//
//  JSONTests.swift
//
//  Created by Daniel Kiedrowski on 17.11.16.
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

class JSONTests: XCTestCase {
    func testPrimitiveType() {
        let A = JSON("a")
        let B = JSON("b")
        XCTAssertEqual(A.merged(other: B), B)
    }
    
    func testMergeEqual() {
        let json = JSON(["a": "A"])
        XCTAssertEqual(json.merged(other: json), json)
    }
    
    func testMergeUnequalValues() {
        let A = JSON(["a": "A"])
        let B = JSON(["a": "B"])
        XCTAssertEqual(A.merged(other: B), B)
    }
    
    func testMergeUnequalKeysAndValues() {
        let A = JSON(["a": "A"])
        let B = JSON(["b": "B"])
        XCTAssertEqual(A.merged(other: B), JSON(["a": "A", "b": "B"]))
    }
    
    func testMergeFilledAndEmpty() {
        let A = JSON(["a": "A"])
        let B = JSON([:])
        XCTAssertEqual(A.merged(other: B), A)
    }
    
    func testMergeEmptyAndFilled() {
        let A = JSON([:])
        let B = JSON(["a": "A"])
        XCTAssertEqual(A.merged(other: B), B)
    }
    
    func testMergeArray() {
        let A = JSON(["a"])
        let B = JSON(["b"])
        XCTAssertEqual(A.merged(other: B), JSON(["a", "b"]))
    }
    
    func testMergeNestedJSONs() {
        let A = JSON([
            "nested": [
                "A": "a"
            ]
        ])
        
        let B = JSON([
            "nested": [
                "A": "b"
            ]
        ])
        
        XCTAssertEqual(A.merged(other: B), B)
    }
}
