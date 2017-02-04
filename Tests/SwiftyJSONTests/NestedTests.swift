//
//  NestedTests.swift
//  SwiftyJSON
//
//  Created by 丁帅 on 2017/2/4.
//
//

import XCTest
import SwiftyJSON

class NestedTests: XCTestCase {
    
    func testArrayJSON() {
        let arr: [JSON] = ["a", 1, ["b", 2]]
        let json = JSON(arr)
        XCTAssertEqual(json[0].string, "a")
        XCTAssertEqual(json[2,1].int, 2)
    }
    
    func testDictionaryJSON() {
        let json: JSON = ["a": JSON("1"), "b": JSON([1, 2, "3"]), "c": JSON(["aa": "11", "bb": 22])]
        XCTAssertEqual(json["a"].string, "1")
        XCTAssertEqual(json["b"].array!, [1, 2, "3"])
        XCTAssertEqual(json["c"]["aa"].string, "11")
        
        print(json["b"].arrayObject!)
    }
    
    func testNextedJSON() {
        let inner = JSON.init([
            "some_field": "1" + "2",
            ])
        
        let json = JSON.init([
            "outer_field": "1" + "2",
            "inner_json": inner
            ])
        
        XCTAssertEqual(json["inner_json"], ["some_field": "12"])
        
        let foo = "foo"
        
        let json2 = JSON.init([
            "outer_field": foo,
            "inner_json": inner
            ])
        
        XCTAssertEqual(json2["inner_json"], ["some_field": "12"])
        
    }

}
