//
//  NestedJSONTests.swift
//  SwiftyJSON
//
//  Created by Hector Matos on 9/27/16.
//
//

import XCTest
import Foundation
import SwiftyJSON

final class NestedJSONTests: XCTestCase, XCTestCaseProvider {
	
	static var allTests: [(String, (NestedJSONTests) -> () throws -> Void)] {
		return [
			("testTopLevelNestedJSON", testTopLevelNestedJSON),
			("testDeeplyNestedJSON", testDeeplyNestedJSON)
		]
	}
	
    let family: JSON = [
        "names" : [
            "Brooke Abigail Matos",
            "Rowan Danger Matos"
        ],
        "motto" : "Hey, I don't know about you, but I'm feeling twenty-two! So, release the KrakenDev!"
    ]
    
    func testTopLevelNestedJSON() {
        let nestedJSON: JSON = [
            "family" : family
        ]
        XCTAssertNotNil(try? nestedJSON.rawData())
    }
    
    func testDeeplyNestedJSON() {
        let nestedFamily: JSON = [
            "count": 1,
            "families": [
                [
                    "isACoolFamily" : true,
                    "family" : [
                        "hello" : family
                    ]
                ]
            ]
        ]
        XCTAssertNotNil(try? nestedFamily.rawData())
    }
}
