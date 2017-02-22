//  StringTests.swift
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

class StringTests: XCTestCase {

    func testString() {
        //getter
        var json = JSON("abcdefg hijklmn;opqrst.?+_()")
        XCTAssertEqual(json.string!, "abcdefg hijklmn;opqrst.?+_()")
        XCTAssertEqual(json.stringValue, "abcdefg hijklmn;opqrst.?+_()")

        json.string = "12345?67890.@#"
        XCTAssertEqual(json.string!, "12345?67890.@#")
        XCTAssertEqual(json.stringValue, "12345?67890.@#")
    }
    
    func testUrl() {
        let json = JSON("http://github.com")
        XCTAssertEqual(json.url!, URL(string:"http://github.com")!)
    }

    func testBool() {
        let json = JSON("true")
        XCTAssertTrue(json.boolValue)
    }

    func testBoolWithY() {
        let json = JSON("Y")
        XCTAssertTrue(json.boolValue)
    }

    func testBoolWithT() {
        let json = JSON("T")
        XCTAssertTrue(json.boolValue)
    }

    func testUrlPercentEscapes() {
        let emDash = "\\u2014"
        let urlString = "http://examble.com/unencoded" + emDash + "string"
        guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return XCTFail("Couldn't encode URL string \(urlString)")
        }
        let json = JSON(urlString)
        XCTAssertEqual(json.url!, URL(string: encodedURLString)!, "Wrong unpacked ")
        let preEscaped = JSON(encodedURLString)
        XCTAssertEqual(preEscaped.url!, URL(string: encodedURLString)!, "Wrong unpacked ")
    }
}
