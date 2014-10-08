//
//  StringTests.swift
//  SwiftyJSON
//
//  Created by Pinglin Tang on 14-10-7.
//
//

import UIKit
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
        XCTAssertEqual(json.URL!, NSURL(string:"http://github.com"))
    }

    func testURLPercentEscapes() {
        let emDash = "\\u2014"
        let urlString = "http://examble.com/unencoded" + emDash + "string"
        let encodedURLString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let json = JSON(urlString)
        XCTAssertEqual(json.URL!, NSURL(string: encodedURLString!), "Wrong unpacked ")
    }
}
