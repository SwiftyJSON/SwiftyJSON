//  BaseTests.swift
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

import XCTest
@testable import SwiftyJSON

class BaseTests: XCTestCase {

    var testData: Data!
    
    override func setUp() {
        
        super.setUp()
        
        if let file = Bundle(for:BaseTests.self).path(forResource: "Tests", ofType: "json") {
            self.testData = try? Data(contentsOf: URL(fileURLWithPath: file))
        } else {
            XCTFail("Can't find the test JSON file")
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInit() {
        let json0 = JSON(data:self.testData)
        XCTAssertEqual(json0.array!.count, 3)
        XCTAssertEqual(JSON("123").description, "123")
        XCTAssertEqual(JSON(["1":"2"])["1"].string!, "2")
        let dictionary = NSMutableDictionary()
        dictionary.setObject(NSNumber(value: 1.0), forKey: "number" as NSString)
        dictionary.setObject(NSNull(), forKey: "null" as NSString)
        _ = JSON(dictionary)
        do {
            let object: AnyObject = try JSONSerialization.jsonObject(with: self.testData, options: [])
            let json2 = JSON(object)
            XCTAssertEqual(json0, json2)
        } catch _ {
        }
    }
    
    func testCompare() {
        XCTAssertNotEqual(JSON("32.1234567890"), JSON(32.1234567890))
        let veryLargeNumber:UInt64 = 9876543210987654321
        XCTAssertNotEqual(JSON("9876543210987654321"),JSON(NSNumber(value:veryLargeNumber)))
        XCTAssertNotEqual(JSON("9876543210987654321.12345678901234567890"), JSON(9876543210987654321.12345678901234567890))
        XCTAssertEqual(JSON("😊"), JSON("😊"))
        XCTAssertNotEqual(JSON("😱"), JSON("😁"))
        XCTAssertEqual(JSON([123,321,456]), JSON([123,321,456]))
        XCTAssertNotEqual(JSON([123,321,456]), JSON(123456789))
        XCTAssertNotEqual(JSON([123,321,456]), JSON("string"))
        XCTAssertNotEqual(JSON(["1":123,"2":321,"3":456]), JSON("string"))
        XCTAssertEqual(JSON(["1":123,"2":321,"3":456]), JSON(["2":321,"1":123,"3":456]))
        XCTAssertEqual(JSON(NSNull()),JSON(NSNull()))
        XCTAssertNotEqual(JSON(NSNull()), JSON(123))
    }
    
    func testJSONDoesProduceValidWithCorrectKeyPath() {
        let json = JSON(data:self.testData)
        
        let tweets = json
        let tweets_array = json.array
        let tweets_1 = json[1]
        _ = tweets_1[1]
        let tweets_1_user_name = tweets_1["user"]["name"]
        let tweets_1_user_name_string = tweets_1["user"]["name"].string
        XCTAssertNotEqual(tweets.type, Type.null)
        XCTAssert(tweets_array != nil)
        XCTAssertNotEqual(tweets_1.type, Type.null)
        XCTAssertEqual(tweets_1_user_name, JSON("Raffi Krikorian"))
        XCTAssertEqual(tweets_1_user_name_string!, "Raffi Krikorian")
        
        let tweets_1_coordinates = tweets_1["coordinates"]
        let tweets_1_coordinates_coordinates = tweets_1_coordinates["coordinates"]
        let tweets_1_coordinates_coordinates_point_0_double = tweets_1_coordinates_coordinates[0].double
        let tweets_1_coordinates_coordinates_point_1_float = tweets_1_coordinates_coordinates[1].float
        let new_tweets_1_coordinates_coordinates = JSON([-122.25831,37.871609] as NSArray)
        XCTAssertEqual(tweets_1_coordinates_coordinates, new_tweets_1_coordinates_coordinates)
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_0_double!, -122.25831)
        XCTAssertTrue(tweets_1_coordinates_coordinates_point_1_float! == 37.871609)
        let tweets_1_coordinates_coordinates_point_0_string = tweets_1_coordinates_coordinates[0].stringValue
        let tweets_1_coordinates_coordinates_point_1_string = tweets_1_coordinates_coordinates[1].stringValue
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_0_string, "-122.25831")
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_1_string, "37.871609")
        let tweets_1_coordinates_coordinates_point_0 = tweets_1_coordinates_coordinates[0]
        let tweets_1_coordinates_coordinates_point_1 = tweets_1_coordinates_coordinates[1]
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_0, JSON(-122.25831))
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_1, JSON(37.871609))
        
        let created_at = json[0]["created_at"].string
        let id_str = json[0]["id_str"].string
        let favorited = json[0]["favorited"].bool
        let id = json[0]["id"].int64
        let in_reply_to_user_id_str = json[0]["in_reply_to_user_id_str"]
        XCTAssertEqual(created_at!, "Tue Aug 28 21:16:23 +0000 2012")
        XCTAssertEqual(id_str!,"240558470661799936")
        XCTAssertFalse(favorited!)
        XCTAssertEqual(id!,240558470661799936)
        XCTAssertEqual(in_reply_to_user_id_str.type, Type.null)

        let user = json[0]["user"]
        let user_name = user["name"].string
        let user_profile_image_url = user["profile_image_url"].URL
        XCTAssert(user_name == "OAuth Dancer")
        XCTAssert(user_profile_image_url == URL(string: "http://a0.twimg.com/profile_images/730275945/oauth-dancer_normal.jpg"))

        let user_dictionary = json[0]["user"].dictionary
        let user_dictionary_name = user_dictionary?["name"]?.string
        let user_dictionary_name_profile_image_url = user_dictionary?["profile_image_url"]?.URL
        XCTAssert(user_dictionary_name == "OAuth Dancer")
        XCTAssert(user_dictionary_name_profile_image_url == URL(string: "http://a0.twimg.com/profile_images/730275945/oauth-dancer_normal.jpg"))
    }
    
    func testJSONNumberCompare() {
        XCTAssertEqual(JSON(12376352.123321), JSON(12376352.123321))
        XCTAssertGreaterThan(JSON(20.211), JSON(20.112))
        XCTAssertGreaterThanOrEqual(JSON(30.211), JSON(20.112))
        XCTAssertGreaterThanOrEqual(JSON(65232), JSON(65232))
        XCTAssertLessThan(JSON(-82320.211), JSON(20.112))
        XCTAssertLessThanOrEqual(JSON(-320.211), JSON(123.1))
        XCTAssertLessThanOrEqual(JSON(-8763), JSON(-8763))
        
        XCTAssertEqual(JSON(12376352.123321), JSON(12376352.123321))
        XCTAssertGreaterThan(JSON(20.211), JSON(20.112))
        XCTAssertGreaterThanOrEqual(JSON(30.211), JSON(20.112))
        XCTAssertGreaterThanOrEqual(JSON(65232), JSON(65232))
        XCTAssertLessThan(JSON(-82320.211), JSON(20.112))
        XCTAssertLessThanOrEqual(JSON(-320.211), JSON(123.1))
        XCTAssertLessThanOrEqual(JSON(-8763), JSON(-8763))
    }

    func testNumberConvertToString(){
        XCTAssertEqual(JSON(true).stringValue, "true")
        XCTAssertEqual(JSON(999.9823).stringValue, "999.9823")
        XCTAssertEqual(JSON(true).number!.stringValue, "1")
        XCTAssertEqual(JSON(false).number!.stringValue, "0")
        XCTAssertEqual(JSON("hello").numberValue.stringValue, "0")
        XCTAssertEqual(JSON(NSNull()).numberValue.stringValue, "0")
        XCTAssertEqual(JSON(["a","b","c","d"]).numberValue.stringValue, "0")
        XCTAssertEqual(JSON(["a":"b","c":"d"]).numberValue.stringValue, "0")
    }
    
    func testNumberPrint(){

        XCTAssertEqual(JSON(false).description,"false")
        XCTAssertEqual(JSON(true).description,"true")

        XCTAssertEqual(JSON(1).description,"1")
        XCTAssertEqual(JSON(22).description,"22")
        #if (arch(x86_64) || arch(arm64))
        XCTAssertEqual(JSON(9.22337203685478E18).description,"9.22337203685478e+18")
        #elseif (arch(i386) || arch(arm))
        XCTAssertEqual(JSON(2147483647).description,"2147483647")
        #endif
        XCTAssertEqual(JSON(-1).description,"-1")
        XCTAssertEqual(JSON(-934834834).description,"-934834834")
        XCTAssertEqual(JSON(-2147483648).description,"-2147483648")

        XCTAssertEqual(JSON(1.5555).description,"1.5555")
        XCTAssertEqual(JSON(-9.123456789).description,"-9.123456789")
        XCTAssertEqual(JSON(-0.00000000000000001).description,"-1e-17")
        XCTAssertEqual(JSON(-999999999999999999999999.000000000000000000000001).description,"-1e+24")
        XCTAssertEqual(JSON(-9999999991999999999999999.88888883433343439438493483483943948341).stringValue,"-9.999999991999999e+24")

        XCTAssertEqual(JSON(Int(Int.max)).description,"\(Int.max)")
        XCTAssertEqual(JSON(NSNumber(value: Int.min)).description,"\(Int.min)")
        XCTAssertEqual(JSON(NSNumber(value: UInt.max)).description,"\(UInt.max)")
        XCTAssertEqual(JSON(NSNumber(value: UInt64.max)).description,"\(UInt64.max)")
        XCTAssertEqual(JSON(NSNumber(value: Int64.max)).description,"\(Int64.max)")
        XCTAssertEqual(JSON(NSNumber(value: UInt64.max)).description,"\(UInt64.max)")

        XCTAssertEqual(JSON(Double.infinity).description,"inf")
        XCTAssertEqual(JSON(-Double.infinity).description,"-inf")
        XCTAssertEqual(JSON(Double.nan).description,"nan")
        
        XCTAssertEqual(JSON(1.0/0.0).description,"inf")
        XCTAssertEqual(JSON(-1.0/0.0).description,"-inf")
        XCTAssertEqual(JSON(0.0/0.0).description,"nan")
    }
    
    func testNullJSON() {
        XCTAssertEqual(JSON(NSNull()).debugDescription,"null")
        
        let json:JSON = nil
        XCTAssertEqual(json.debugDescription,"null")
        XCTAssertNil(json.error)
        let json1:JSON = JSON(NSNull())
        if json1 != nil {
            XCTFail("json1 should be nil")
        }
    }
    
    func testExistance() {
        let dictionary = ["number":1111]
        let json = JSON(dictionary)
        XCTAssertFalse(json["unspecifiedValue"].exists())
        XCTAssertTrue(json["number"].exists())
    }
    
    func testErrorHandle() {
        let json = JSON(data:self.testData)
        if let _ = json["wrong-type"].string {
            XCTFail("Should not run into here")
        } else {
            XCTAssertEqual(json["wrong-type"].error!.code, SwiftyJSON.ErrorWrongType)
        }

        if let _ = json[0]["not-exist"].string {
            XCTFail("Should not run into here")
        } else {
            XCTAssertEqual(json[0]["not-exist"].error!.code, SwiftyJSON.ErrorNotExist)
        }
        
        let wrongJSON = JSON(NSObject())
        if let error = wrongJSON.error {
            XCTAssertEqual(error.code, SwiftyJSON.ErrorUnsupportedType)
        }
    }
    
    func testReturnObject() {
        let json = JSON(data:self.testData)
        XCTAssertNotNil(json.object)
    }
        
    func testNumberCompare(){
        XCTAssertEqual(NSNumber(value: 888332), NSNumber(value:888332))
        XCTAssertNotEqual(NSNumber(value: 888332.1), NSNumber(value:888332))
        XCTAssertLessThan(NSNumber(value: 888332).doubleValue, NSNumber(value:888332.1).doubleValue)
        XCTAssertGreaterThan(NSNumber(value: 888332.1).doubleValue, NSNumber(value:888332).doubleValue)
        XCTAssertFalse(NSNumber(value: 1) == NSNumber(value:true))
        XCTAssertFalse(NSNumber(value: 0) == NSNumber(value:false))
        XCTAssertEqual(NSNumber(value: false), NSNumber(value:false))
        XCTAssertEqual(NSNumber(value: true), NSNumber(value:true))
    }
    

}
