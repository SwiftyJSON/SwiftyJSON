//  NestedJSONTests.swift
//
//  Created by Hector Matos on 9/27/16.
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

class NestedJSONTests: XCTestCase {
    let family: JSON = [
        "names": [
            "Brooke Abigail Matos",
            "Rowan Danger Matos"
        ],
        "motto": "Hey, I don't know about you, but I'm feeling twenty-two! So, release the KrakenDev!"
    ]

    func testTopLevelNestedJSON() {
        let nestedJSON: JSON = [
            "family": family
        ]
        XCTAssertNotNil(try? nestedJSON.rawData())
    }

    func testDeeplyNestedJSON() {
        let nestedFamily: JSON = [
            "count": 1,
            "families": [
                [
                    "isACoolFamily": true,
                    "family": [
                        "hello": family
                    ]
                ]
            ]
        ]
        XCTAssertNotNil(try? nestedFamily.rawData())
    }

    func testArrayJSON() {
        let arr: [JSON] = ["a", 1, ["b", 2]]
        let json = JSON(arr)
        XCTAssertEqual(json[0].string, "a")
        XCTAssertEqual(json[2, 1].int, 2)
    }

    func testDictionaryJSON() {
        let json: JSON = ["a": JSON("1"), "b": JSON([1, 2, "3"]), "c": JSON(["aa": "11", "bb": 22])]
        XCTAssertEqual(json["a"].string, "1")
        XCTAssertEqual(json["b"].array!, [1, 2, "3"])
        XCTAssertEqual(json["c"]["aa"].string, "11")
    }

    func testNestedJSON() {
        let inner = JSON([
            "some_field": "1" + "2"
            ])
        let json = JSON([
            "outer_field": "1" + "2",
            "inner_json": inner
            ])
        XCTAssertEqual(json["inner_json"], ["some_field": "12"])

        let foo = "foo"
        let json2 = JSON([
            "outer_field": foo,
            "inner_json": inner
            ])
        XCTAssertEqual(json2["inner_json"].rawValue as! [String: String], ["some_field": "12"])
    }
}
