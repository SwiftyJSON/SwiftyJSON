//  SwiftyJSONTests.swift
//
//  Copyright (c) 2014 Ruoyu Fu, Pinglin Tang
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
class SwiftyJSONTests: XCTestCase {

    var testData: NSData!
    
    override func setUp() {
        
        super.setUp()
        
        if let file = NSBundle(forClass:SwiftyJSONTests.self).pathForResource("SwiftyJSONTests", ofType: "json") {
            self.testData = NSData(contentsOfFile: file)
        } else {
            XCTFail("Can't find the test JSON file")
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInit() {
        let aJSON = JSON(data:self.testData)
        XCTAssertEqual(aJSON.arrayValue!.count, 3)
        XCTAssertEqual(JSON(object: "123"), JSON(object: 123))
    }
    
    func testCompare() {
        XCTAssertEqual(JSON(object: "32.1234567890"), JSON(object: 32.1234567890))
        XCTAssertEqual(JSON(object: "9876543210987654321"),JSON(object: NSNumber(unsignedLongLong:9876543210987654321)))
        XCTAssertEqual(JSON(object: "9876543210987654321.12345678901234567890"), JSON(object: 9876543210987654321.12345678901234567890))
        XCTAssertEqual(JSON(object: "😊"), JSON(object: "😊"))
        XCTAssertNotEqual(JSON(object: "😱"), JSON(object: "😁"))
        XCTAssertEqual(JSON(object: [123,321,456]), JSON(object: [123,321,456]))
        XCTAssertNotEqual(JSON(object: [123,321,456]), JSON(object: 123456789))
        XCTAssertNotEqual(JSON(object: [123,321,456]), JSON(object: "string"))
        XCTAssertNotEqual(JSON(object: ["1":123,"2":321,"3":456]), JSON(object: "string"))
        XCTAssertEqual(JSON(object: ["1":123,"2":321,"3":456]), JSON(object: ["2":321,"1":123,"3":456]))
        XCTAssertEqual(JSON(object: NSNull()), JSON(object: NSObject()))
        XCTAssertNotEqual(JSON(object: NSNull()), JSON(object: 123))
    }
    
    func testJSONDoesProduceValidValueWithCorrectKeyPath() {
        let json = JSON(data:self.testData)
        
        let tweets = json
        let tweets_array = json.arrayValue
        let tweets_1 = json[1]
        let tweets_array_1 = tweets_1[1]
        let tweets_1_user_name = tweets_1["user"]["name"]
        let tweets_1_user_name_string = tweets_1["user"]["name"].stringValue
        XCTAssertNotEqual(tweets, JSON.Null(nil))
        XCTAssert(tweets_array != nil)
        XCTAssertNotEqual(tweets_1, JSON.Null(nil))
        XCTAssertEqual(tweets_1_user_name, JSON(object:"Raffi Krikorian"))
        XCTAssertEqual(tweets_1_user_name_string!, "Raffi Krikorian")
        
        let tweets_1_coordinates = tweets_1["coordinates"]
        let tweets_1_coordinates_coordinates = tweets_1_coordinates["coordinates"]
        let tweets_1_coordinates_coordinates_point_0_double = tweets_1_coordinates_coordinates[0].doubleValue
        let tweets_1_coordinates_coordinates_point_1_float = tweets_1_coordinates_coordinates[1].floatValue
        let new_tweets_1_coordinates_coordinates = JSON(object:[-122.25831,37.871609])
        XCTAssertEqual(tweets_1_coordinates_coordinates, new_tweets_1_coordinates_coordinates)
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_0_double!, -122.25831)
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_1_float!, 37.871609)
        let tweets_1_coordinates_coordinates_point_0_string = tweets_1_coordinates_coordinates[0].stringValue
        let tweets_1_coordinates_coordinates_point_1_string = tweets_1_coordinates_coordinates[1].stringValue
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_0_string!, "-122.25831")
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_1_string!, "37.871609")
        let tweets_1_coordinates_coordinates_point_0 = tweets_1_coordinates_coordinates[0]
        let tweets_1_coordinates_coordinates_point_1 = tweets_1_coordinates_coordinates[1]
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_0, JSON(object:-122.25831))
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_1, JSON(object:"37.871609"))
        
        let created_at = json[0]["created_at"].stringValue
        let id_str = json[0]["id_str"].stringValue
        let favorited = json[0]["favorited"].boolValue
        let id = json[0]["id"].longLongValue
        let in_reply_to_user_id_str = json[0]["in_reply_to_user_id_str"]
        XCTAssertEqual(created_at!, "Tue Aug 28 21:16:23 +0000 2012")
        XCTAssertEqual(id_str!,"240558470661799936")
        XCTAssertFalse(favorited)
        XCTAssertEqual(id!,240558470661799936)
        XCTAssertEqual(in_reply_to_user_id_str,JSON.Null(nil))

        let user = json[0]["user"]
        let user_name = user["name"].stringValue
        let user_profile_image_url = user["profile_image_url"].URLValue
        XCTAssert(user_name == "OAuth Dancer")
        XCTAssert(user_profile_image_url == NSURL(string: "http://a0.twimg.com/profile_images/730275945/oauth-dancer_normal.jpg"))

        let user_dictionary = json[0]["user"].dictionaryValue
        let user_dictionary_name = user_dictionary?["name"]?.stringValue
        let user_dictionary_name_profile_image_url = user_dictionary?["profile_image_url"]?.URLValue
        XCTAssert(user_dictionary_name == "OAuth Dancer")
        XCTAssert(user_dictionary_name_profile_image_url == NSURL(string: "http://a0.twimg.com/profile_images/730275945/oauth-dancer_normal.jpg"))
    }

    func testNumberPrint(){
        XCTAssertEqual(JSON(object: false).description,"false")
        XCTAssertEqual(JSON(object: true).description,"true")

        XCTAssertEqual(JSON(object: 1).description,"1")
        XCTAssertEqual(JSON(object: 22).description,"22")
        XCTAssertEqual(JSON(object: 2147483647).description,"2147483647")
        XCTAssertEqual(JSON(object: 2147483648).description,"2147483648")
        
        XCTAssertEqual(JSON(object: -1).description,"-1")
        XCTAssertEqual(JSON(object: -934834834).description,"-934834834")
        XCTAssertEqual(JSON(object: -2147483648).description,"-2147483648")

        XCTAssertEqual(JSON(object: 1.5555).description,"1.5555")
        XCTAssertEqual(JSON(object: -9.123456789).description,"-9.123456789")
        XCTAssertEqual(JSON(object: -0.00000000000000001).description,"-1e-17")
        XCTAssertEqual(JSON(object: -999999999999999999999999.000000000000000000000001).description,"-1e+24")
        XCTAssertEqual(JSON(object: -9999999991999999999999999.88888883433343439438493483483943948341).stringValue!,"-9.999999991999999e+24")

        XCTAssertEqual(JSON(object: Int(Int.max)).description,"\(Int.max)")
        XCTAssertEqual(JSON(object: NSNumber(long: Int.min)).description,"\(Int.min)")
        XCTAssertEqual(JSON(object: NSNumber(unsignedLong: ULONG_MAX)).description,"\(ULONG_MAX)")
        XCTAssertEqual(JSON(object: NSNumber(unsignedLongLong: UInt64.max)).description,"\(UInt64.max)")
        XCTAssertEqual(JSON(object: NSNumber(longLong: Int64.max)).description,"\(Int64.max)")
        XCTAssertEqual(JSON(object: NSNumber(unsignedLongLong: UInt64.max)).description,"\(UInt64.max)")

        XCTAssertEqual(JSON(object: Double.infinity).description,"inf")
        XCTAssertEqual(JSON(object: -Double.infinity).description,"-inf")
        XCTAssertEqual(JSON(object: Double.NaN).description,"nan")
        
        XCTAssertEqual(JSON(object: 1.0/0.0).description,"inf")
        XCTAssertEqual(JSON(object: -1.0/0.0).description,"-inf")
        XCTAssertEqual(JSON(object: 0.0/0.0).description,"nan")
    }
    
    func testNullPrint() {
        XCTAssertEqual(JSON.Null(nil).debugDescription,"null")
        let error = NSError(domain: SwiftyJSON.ErrorDomain, code: SwiftyJSON.ErrorWrongType, userInfo: [NSLocalizedDescriptionKey: "hello world"])
        XCTAssertEqual(JSON.Null(error).description,"\(error)")
    }
    
    func testErrorHandle() {
        let json = JSON(data:self.testData)
        if let wrongType = json["wrong-type"].stringValue {
            XCTFail("Should not run into here")
        } else {
            XCTAssertEqual(json["wrong-type"].error!.code, SwiftyJSON.ErrorWrongType)
        }

        if let notExist = json[0]["not-exist"].stringValue {
            XCTFail("Should not run into here")
        } else {
            XCTAssertEqual(json[0]["not-exist"].error!.code, SwiftyJSON.ErrorNotExist)
        }
        
        let wrongJSON = JSON(object: NSObject())
        if let error = wrongJSON.error {
            XCTAssertEqual(error.code, SwiftyJSON.ErrorUnsupportedType)
        }
    }
    
    func testReturnObject() {
        let json = JSON(data:self.testData)
        println(json.object)
        XCTAssertNotNil(json.object)
    }
    
    func testJSONURLPercentEscapes() {
        let emDash = "\\u2014"
        let urlString = "http://examble.com/unencoded" + emDash + "string"
        let encodedURLString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        
        let json = JSON(object: urlString)
        XCTAssertEqual(json.URLValue!, NSURL(string: encodedURLString!), "Wrong unpacked value")
    }
    
    func testInitPerformance() {
        // This is an example of a performance test case.
        self.measureBlock() {
            var t:Int = 0
            while (true) {
                if t == 100 {
                    break
                }
                JSON(data:self.testData)
                t++
            }
        }
    }
}