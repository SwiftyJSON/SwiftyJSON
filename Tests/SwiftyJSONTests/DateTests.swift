//
//  DateTests.swift
//  SwiftyJSON
//
//  Created by David Evans on 09/11/2017.
//

import XCTest
import SwiftyJSON

class DateTests: XCTestCase {
    
    func testDates() {
        let date = Date()
        var json = JSON()
        json.date = date
        XCTAssertEqual(json.date.timeIntervalSince1970, date.timeIntervalSince1970)
    }
}
