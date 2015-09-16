//  StringTests.swift
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
    
    func testURL() {
        let json = JSON("http://github.com")
        XCTAssertEqual(json.URL!, NSURL(string:"http://github.com")!)
    }

    func testURLPercentEscapes() {
        let emDash = "\\u2014"
        let urlString = "http://examble.com/unencoded" + emDash + "string"
        let encodedURLString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let json = JSON(urlString)
        XCTAssertEqual(json.URL!, NSURL(string: encodedURLString!)!, "Wrong unpacked ")
    }
}
