//
//  DynamicMemberLookupTests.swift
//  SwiftyJSON iOS Tests
//
//  Created by ios 4 on 9/29/18.
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
class DynamicMemberLookupTests: XCTestCase {
    func testDictionaryDynamicLookupString() {
        var json: JSON = JSON(rawValue: ["a": "aoo", "bb": "bpp", "z": "zoo"] as NSDictionary)!
        XCTAssertTrue(json.a == "aoo")
        XCTAssertEqual(json.bb, JSON("bpp"))
        XCTAssertTrue(json.z == "zoo")
        json.bb = "update"
        XCTAssertTrue(json.a == "aoo")
        XCTAssertTrue(json.bb == "update")
        XCTAssertTrue(json.z == "zoo")
    }
    func testMultilevelDynamicLookUpGetter() {
        var json: JSON = ["user": ["id": 987654, "info":
            ["name": "farshad", "email": "sam@gmail.com"],
                                   "feeds": [98833, 23443, 213239, 23232]]]
        XCTAssertEqual(json["user", "id"], 987654)
        XCTAssertEqual(json["user", "info", "name"], "farshad")
        XCTAssertEqual(json["user", "info", "email"], "sam@gmail.com")
        XCTAssertEqual(json["user", "feeds"], [98833, 23443, 213239, 23232])
    }
    func testMultilevelDynamicLookUpSetter() {
        var json: JSON = ["user": ["id": 987654, "info":
            ["name": "farshad","email": "sam@gmail.com"],
                                   "feeds": [98833, 23443, 213239, 23232]]]
        json.user.info.name = "jim"
        XCTAssertEqual(json.user.id, 987654)
        XCTAssertEqual(json.user.info.name, "jim")
        XCTAssertEqual(json.user.info.email, "sam@gmail.com")
        XCTAssertEqual(json.user.feeds, [98833, 23443, 213239, 23232])
        json.user.info.email = "jim@hotmail.com"
        XCTAssertEqual(json.user.id, 987654)
        XCTAssertEqual(json.user.info.name, "jim")
        XCTAssertEqual(json.user.info.email, "jim@hotmail.com")
        XCTAssertEqual(json.user.feeds, [98833, 23443, 213239, 23232])
        json.user.info = ["name": "tom", "email": "tom@qq.com"]
        XCTAssertEqual(json.user.id, 987654)
        XCTAssertEqual(json.user.info.name, "tom")
        XCTAssertEqual(json.user.info.email, "tom@qq.com")
        XCTAssertEqual(json.user.feeds, [98833, 23443, 213239, 23232])
        json.user.feeds = [77323, 2313, 4545, 323]
        XCTAssertEqual(json.user.id, 987654)
        XCTAssertEqual(json.user.info.name, "tom")
        XCTAssertEqual(json.user.info.email, "tom@qq.com")
        XCTAssertEqual(json.user.feeds, [77323, 2313, 4545, 323])
    }

}
