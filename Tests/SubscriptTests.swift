//  SubscriptTests.swift
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

import UIKit
import XCTest
import SwiftyJSON

class SubscriptTests: XCTestCase {

    func testArrayAllNumber() {
        var json:JSON = [1,2.0,3.3,123456789,987654321.123456789]
        XCTAssertEqual(json, [1,2.0,3.3,123456789,987654321.123456789])
        XCTAssertEqual(json[0], 1)
        XCTAssertEqual(json[1].double!, 2.0)
        XCTAssertEqual(json[2].floatValue, 3.3)
        XCTAssertEqual(json[3].int!, 123456789)
        XCTAssertEqual(json[4].doubleValue, 987654321.123456789)
        
        json[0] = 1.9
        json[1] = 2.899
        json[2] = 3.567
        json[3] = 0.999
        json[4] = 98732
        
        XCTAssertEqual(json[0], 1.9)
        XCTAssertEqual(json[1].doubleValue, 2.899)
        XCTAssertEqual(json[2], 3.567)
        XCTAssertEqual(json[3].float!, 0.999)
        XCTAssertEqual(json[4].intValue, 98732)
    }
    
    func testArrayAllBool() {
        var json:JSON = [true, false, false, true, true]
        XCTAssertEqual(json, [true, false, false, true, true])
        XCTAssertEqual(json[0], true)
        XCTAssertEqual(json[1], false)
        XCTAssertEqual(json[2], false)
        XCTAssertEqual(json[3], true)
        XCTAssertEqual(json[4], true)
        
        json[0] = false
        json[4] = true
        XCTAssertEqual(json[0], false)
        XCTAssertEqual(json[4], true)
    }
    
    func testArrayAllString() {
        var json:JSON = JSON.fromRaw(["aoo","bpp","zoo"] as NSArray)!
        XCTAssertEqual(json, ["aoo","bpp","zoo"])
        XCTAssertEqual(json[0], "aoo")
        XCTAssertEqual(json[1], "bpp")
        XCTAssertEqual(json[2], "zoo")
        
        json[1] = "update"
        XCTAssertEqual(json[0], "aoo")
        XCTAssertEqual(json[1], "update")
        XCTAssertEqual(json[2], "zoo")
    }
    
    func testArrayWithNull() {
        var json:JSON = JSON.fromRaw(["aoo","bpp", NSNull() ,"zoo"] as NSArray)!
        XCTAssertEqual(json[0], "aoo")
        XCTAssertEqual(json[1], "bpp")
        XCTAssertNil(json[2].string)
        XCTAssertNotNil(json[2].null)
        XCTAssertEqual(json[3], "zoo")
        
        json[2] = "update"
        json[3] = JSON(NSNull())
        XCTAssertEqual(json[0], "aoo")
        XCTAssertEqual(json[1], "bpp")
        XCTAssertEqual(json[2], "update")
        XCTAssertNil(json[3].string)
        XCTAssertNotNil(json[3].null)
    }
    
    func testArrayAllDictionary() {
        var json:JSON = [["1":1, "2":2], ["a":"A", "b":"B"], ["null":NSNull()]]
        XCTAssertEqual(json[0], ["1":1, "2":2])
        XCTAssertEqual(json[1].dictionary!, ["a":"A", "b":"B"])
        XCTAssertEqual(json[2], JSON(["null":NSNull()]))
        XCTAssertEqual(json[0]["1"], 1)
        XCTAssertEqual(json[0]["2"], 2)
        XCTAssertEqual(json[1]["a"], JSON.fromRaw("A")!)
        XCTAssertEqual(json[1]["b"], JSON("B"))
        XCTAssertNotNil(json[2]["null"].null)
    }
    
    func testDictionaryAllNumber() {
        var json:JSON = ["double":1.11111, "int":987654321]
        XCTAssertEqual(json["double"].double!, 1.11111)
        XCTAssertEqual(json["int"], 987654321)
        
        json["double"] = 2.2222
        json["int"] = 123456789
        json["add"] = 7890
        XCTAssertEqual(json["double"], 2.2222)
        XCTAssertEqual(json["int"].doubleValue, 123456789.0)
        XCTAssertEqual(json["add"].intValue, 7890)
    }
    
    func testDictionaryAllBool() {
        var json:JSON = ["t":true, "f":false, "false":false, "tr":true, "true":true]
        XCTAssertEqual(json["t"], true)
        XCTAssertEqual(json["f"], false)
        XCTAssertEqual(json["false"], false)
        XCTAssertEqual(json["tr"], true)
        XCTAssertEqual(json["true"], true)

        json["f"] = true
        json["tr"] = false
        XCTAssertEqual(json["f"], true)
        XCTAssertEqual(json["tr"], JSON(false))
    }
    
    func testDictionaryAllString() {
        var json:JSON = JSON.fromRaw(["a":"aoo","bb":"bpp","z":"zoo"] as NSDictionary)!
        XCTAssertEqual(json["a"], "aoo")
        XCTAssertEqual(json["bb"], JSON("bpp"))
        XCTAssertEqual(json["z"], "zoo")
        
        json["bb"] = "update"
        XCTAssertEqual(json["a"], "aoo")
        XCTAssertEqual(json["bb"], "update")
        XCTAssertEqual(json["z"], "zoo")
    }
    
    func testDictionaryWithNull() {
        var json:JSON = JSON.fromRaw(["a":"aoo","bb":"bpp","null":NSNull(), "z":"zoo"] as NSDictionary)!
        XCTAssertEqual(json["a"], "aoo")
        XCTAssertEqual(json["bb"], JSON("bpp"))
        XCTAssertEqual(json["null"], JSON(NSNull()))
        XCTAssertEqual(json["z"], "zoo")
        
        json["null"] = "update"
        XCTAssertEqual(json["a"], "aoo")
        XCTAssertEqual(json["null"], "update")
        XCTAssertEqual(json["z"], "zoo")
    }
    
    func testDictionaryAllArray() {
        //Swift bug: [1, 2.01,3.09] is convert to [1, 2, 3] (Array<Int>)
        var json:JSON = JSON ([[NSNumber(integer:1),NSNumber(double:2.123456),NSNumber(int:123456789)], ["aa","bbb","cccc"], [true, "766", NSNull(), 655231.9823]] as NSArray)
        let array = NSArray(objects: NSNumber(integer:1),NSNumber(double:2.123456),NSNumber(int:123456789))
        XCTAssertEqual(json[0], [1,2.123456,123456789])
        XCTAssertEqual(json[0][1].double!, 2.123456)
        XCTAssertEqual(json[0][2], 123456789)
        XCTAssertEqual(json[1][0], "aa")
        XCTAssertEqual(json[1], ["aa","bbb","cccc"])
        XCTAssertEqual(json[2][0], true)
        XCTAssertEqual(json[2][1], "766")
        XCTAssertEqual(json[2][2], JSON(NSNull()))
        XCTAssertEqual(json[2][3], JSON(655231.9823))
    }
    
    func testOutOfBounds() {
        var json:JSON = JSON ([[NSNumber(integer:1),NSNumber(double:2.123456),NSNumber(int:123456789)], ["aa","bbb","cccc"], [true, "766", NSNull(), 655231.9823]] as NSArray)
        XCTAssertEqual(json[9], JSON.nullJSON)
        XCTAssertEqual(json[6].error!.code, ErrorIndexOutOfBounds)
        XCTAssertEqual(json[9][8], JSON.nullJSON)
        XCTAssertEqual(json[8][7].error!.code, ErrorWrongType)
    }
}
