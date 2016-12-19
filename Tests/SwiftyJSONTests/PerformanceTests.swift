//  PerformanceTests.swift
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
import Foundation

@testable import SwiftyJSON

#if os(Linux)
// autoreleasepool is Objective-C feature
//TODO check what is its equivalent in Swift on Linux
func autoreleasepool(callback:() -> ()) {
     callback()
}
#endif

class PerformanceTests: XCTestCase {

// GENERATED: allTests required for Swift 3.0
    static var allTests : [(String, (PerformanceTests) -> () throws -> Void)] {
        return [
            ("testInitPerformance", testInitPerformance),
            ("testObjectMethodPerformance", testObjectMethodPerformance),
            ("testArrayMethodPerformance", testArrayMethodPerformance),
            ("testDictionaryMethodPerformance", testDictionaryMethodPerformance),
            ("testRawStringMethodPerformance", testRawStringMethodPerformance),
        ]
    }
// END OF GENERATED CODE

    var testData: Data!

    override func setUp() {
        super.setUp()

        var testDataURL = URL(fileURLWithPath: #file)
        testDataURL.appendPathComponent("../Tests.json")
        do {
            self.testData = try Data(contentsOf: testDataURL.standardized)
        }
        catch {
            XCTFail("Failed to read in the test data")
            exit(1)
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitPerformance() {
        self.measure() {
            for _ in 1...100 {
                let json = JSON(data:self.testData)
                XCTAssertTrue(json != JSON.null)
            }
        }
    }

    func testObjectMethodPerformance() {
        let json = JSON(data:self.testData)
        self.measure() {
            for _ in 1...100 {
                _ = json.object
            }
        }
    }

    func testArrayMethodPerformance() {
        let json = JSON(data:self.testData)
        self.measure() {
            for _ in 1...100 {
                autoreleasepool{
                    let array = json.array
                    XCTAssertTrue( (array?.count ?? 0) > 0)
                }
            }
        }
    }

    func testDictionaryMethodPerformance() {
        let json = JSON(data:testData)[0]
        self.measure() {
            for _ in 1...100 {
                autoreleasepool{
                    let dictionary = json.dictionary
                    XCTAssertTrue( (dictionary?.count ?? 0) > 0)
                }
            }
        }
    }

    func testRawStringMethodPerformance() {
        let json = JSON(data:testData)
        self.measure() {
            for _ in 1...100 {
                autoreleasepool{
                    let string = json.rawString()
                    XCTAssertTrue(string != nil)
                }
            }
        }
    }

}
