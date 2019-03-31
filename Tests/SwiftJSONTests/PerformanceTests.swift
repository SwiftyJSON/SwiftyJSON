//  PerformanceTests.swift
//
//  Copyright (c) 2014 - 2017 Pinglin Tang
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

class PerformanceTests: XCTestCase {

    var testData: Data!

    override func setUp() {
        super.setUp()

        if let file = Bundle(for: PerformanceTests.self).path(forResource: "Tests", ofType: "json") {
            self.testData = try? Data(contentsOf: URL(fileURLWithPath: file))
        } else {
            XCTFail("Can't find the test JSON file")
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitPerformance() {
        self.measure {
            for _ in 1...100 {
                guard let json = try? JSON(data: self.testData) else {
                    XCTFail("Unable to parse testData")
                    return
                }
                XCTAssertTrue(json != JSON.null)
            }
        }
    }

    func testObjectMethodPerformance() {
        guard let json = try? JSON(data: self.testData) else {
            XCTFail("Unable to parse testData")
            return
        }
        self.measure {
            for _ in 1...100 {
                let object: Any? = json.object
                XCTAssertTrue(object != nil)
            }
        }
    }

    func testArrayMethodPerformance() {
        guard let json = try? JSON(data: self.testData) else {
            XCTFail("Unable to parse testData")
            return
        }
        self.measure {
            for _ in 1...100 {
                autoreleasepool {
                    if let array = json.array {
                        XCTAssertTrue(array.count > 0)
                    }
                }
            }
        }
    }

    func testDictionaryMethodPerformance() {
        guard let json = try? JSON(data: self.testData)[0] else {
            XCTFail("Unable to parse testData")
            return
        }
        self.measure {
            for _ in 1...100 {
                autoreleasepool {
                    if let dictionary = json.dictionary {
                        XCTAssertTrue(dictionary.count > 0)
                    }
                }
            }
        }
    }

    func testRawStringMethodPerformance() {
        guard let json = try? JSON(data: self.testData) else {
            XCTFail("Unable to parse testData")
            return
        }
        self.measure {
            for _ in 1...100 {
                autoreleasepool {
                    let string = json.rawString()
                    XCTAssertTrue(string != nil)
                }
            }
        }
    }

    func testLargeDictionaryMethodPerformance() {
        var data: [String: JSON] = [:]
        (0...100000).forEach { n in
            data["\(n)"] = JSON([
                "name": "item\(n)",
                "id": n
                ])
        }
        let json = JSON(data)

        self.measure {
            autoreleasepool {
                if let dictionary = json.dictionary {
                    XCTAssertTrue(dictionary.count == 100001)
                } else {
                    XCTFail("dictionary should not be nil")
                }
            }
        }
    }
}
