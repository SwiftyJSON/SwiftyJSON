//
//  DateTests.swift
//  SwiftyJSON
//
//  Created by David Evans on 09/11/2017.
//

import XCTest
@testable import SwiftyJSON

class DateTests: XCTestCase {

    func testDateFormat() {
        
        let date = Date()
        var json = JSON()
        json.date = date
        
        let components = Calendar(identifier: Calendar.Identifier.gregorian).dateComponents(in: .current, from: date)
        let year = json.dateString(format: "yyyy") ?? ""
        let month = json.dateString(format: "MM") ?? ""
        let day = json.dateString(format: "dd") ?? ""
        let hour = json.dateString(format: "HH") ?? ""
        let minute = json.dateString(format: "mm") ?? ""
        let second = json.dateString(format: "ss") ?? ""
        
        XCTAssertEqual(Int(year), components.year)
        XCTAssertEqual(Int(month), components.month)
        XCTAssertEqual(Int(day), components.day)
        XCTAssertEqual(Int(hour), components.hour)
        XCTAssertEqual(Int(minute), components.minute)
        XCTAssertEqual(Int(second), components.second)
        
        json.date = nil
        XCTAssertNil(json.date)
        
        json.stringValue = "foo bar"
        XCTAssertNil(json.date)
        XCTAssertNil(json.dateString())
    }
}
