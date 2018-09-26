//  NumberTests.swift
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

class NumberTests: XCTestCase {

    func testNumber() {
        //getter
        var json = JSON(NSNumber(value: 9876543210.123456789))
        XCTAssertEqual(json.number!, 9876543210.123456789)
        XCTAssertEqual(json.numberValue, 9876543210.123456789)
        XCTAssertEqual(json.stringValue, "9876543210.123457")

        json.string = "1000000000000000000000000000.1"
        XCTAssertNil(json.number)
        XCTAssertEqual(json.numberValue.description, "1000000000000000000000000000.1")

        json.string = "1e+27"
        XCTAssertEqual(json.numberValue.description, "1000000000000000000000000000")

        //setter
        json.number = NSNumber(value: 123456789.0987654321)
        XCTAssertEqual(json.number!, 123456789.0987654321)
        XCTAssertEqual(json.numberValue, 123456789.0987654321)

        json.number = nil
        XCTAssertEqual(json.numberValue, 0)
        XCTAssertEqual(json.object as? NSNull, NSNull())
        XCTAssertTrue(json.number == nil)

        json.numberValue = 2.9876
        XCTAssertEqual(json.number!, 2.9876)
    }

    func testBool() {
        var json = JSON(true)
        XCTAssertEqual(json.bool!, true)
        XCTAssertEqual(json.boolValue, true)
        XCTAssertEqual(json.numberValue, true as NSNumber)
        XCTAssertEqual(json.stringValue, "true")

        json.bool = false
        XCTAssertEqual(json.bool!, false)
        XCTAssertEqual(json.boolValue, false)
        XCTAssertEqual(json.numberValue, false as NSNumber)

        json.bool = nil
        XCTAssertTrue(json.bool == nil)
        XCTAssertEqual(json.boolValue, false)
        XCTAssertEqual(json.numberValue, 0)

        json.boolValue = true
        XCTAssertEqual(json.bool!, true)
        XCTAssertEqual(json.boolValue, true)
        XCTAssertEqual(json.numberValue, true as NSNumber)
    }

    func testDouble() {
        var json = JSON(9876543210.123456789)
        XCTAssertEqual(json.double!, 9876543210.123456789)
        XCTAssertEqual(json.doubleValue, 9876543210.123456789)
        XCTAssertEqual(json.numberValue, 9876543210.123456789)
        XCTAssertEqual(json.stringValue, "9876543210.123457")

        json.double = 2.8765432
        XCTAssertEqual(json.double!, 2.8765432)
        XCTAssertEqual(json.doubleValue, 2.8765432)
        XCTAssertEqual(json.numberValue, 2.8765432)

        json.doubleValue = 89.0987654
        XCTAssertEqual(json.double!, 89.0987654)
        XCTAssertEqual(json.doubleValue, 89.0987654)
        XCTAssertEqual(json.numberValue, 89.0987654)

        json.double = nil
        XCTAssertEqual(json.boolValue, false)
        XCTAssertEqual(json.doubleValue, 0.0)
        XCTAssertEqual(json.numberValue, 0)
    }

    func testFloat() {
        var json = JSON(54321.12345)
        XCTAssertTrue(json.float! == 54321.12345)
        XCTAssertTrue(json.floatValue == 54321.12345)
        XCTAssertEqual(json.numberValue, 54321.12345)
        XCTAssertEqual(json.stringValue, "54321.12345")

        json.double = 23231.65
        XCTAssertTrue(json.float! == 23231.65)
        XCTAssertTrue(json.floatValue == 23231.65)
        XCTAssertEqual(json.numberValue, NSNumber(value: 23231.65))

        json.double = -98766.23
        XCTAssertEqual(json.float!, -98766.23)
        XCTAssertEqual(json.floatValue, -98766.23)
        XCTAssertEqual(json.numberValue, NSNumber(value: -98766.23))
    }

    func testInt() {
        var json = JSON(123456789)
        XCTAssertEqual(json.int!, 123456789)
        XCTAssertEqual(json.intValue, 123456789)
        XCTAssertEqual(json.numberValue, NSNumber(value: 123456789))
        XCTAssertEqual(json.stringValue, "123456789")

        json.int = nil
        XCTAssertTrue(json.boolValue == false)
        XCTAssertTrue(json.intValue == 0)
        XCTAssertEqual(json.numberValue, 0)
        XCTAssertEqual(json.object as? NSNull, NSNull())
        XCTAssertTrue(json.int == nil)

        json.intValue = 76543
        XCTAssertEqual(json.int!, 76543)
        XCTAssertEqual(json.intValue, 76543)
        XCTAssertEqual(json.numberValue, NSNumber(value: 76543))

        json.intValue = 98765421
        XCTAssertEqual(json.int!, 98765421)
        XCTAssertEqual(json.intValue, 98765421)
        XCTAssertEqual(json.numberValue, NSNumber(value: 98765421))
    }

    func testUInt() {
        var json = JSON(123456789)
        XCTAssertTrue(json.uInt! == 123456789)
        XCTAssertTrue(json.uIntValue == 123456789)
        XCTAssertEqual(json.numberValue, NSNumber(value: 123456789))
        XCTAssertEqual(json.stringValue, "123456789")

        json.uInt = nil
        XCTAssertTrue(json.boolValue == false)
        XCTAssertTrue(json.uIntValue == 0)
        XCTAssertEqual(json.numberValue, 0)
        XCTAssertEqual(json.object as? NSNull, NSNull())
        XCTAssertTrue(json.uInt == nil)

        json.uIntValue = 76543
        XCTAssertTrue(json.uInt! == 76543)
        XCTAssertTrue(json.uIntValue == 76543)
        XCTAssertEqual(json.numberValue, NSNumber(value: 76543))

        json.uIntValue = 98765421
        XCTAssertTrue(json.uInt! == 98765421)
        XCTAssertTrue(json.uIntValue == 98765421)
        XCTAssertEqual(json.numberValue, NSNumber(value: 98765421))
    }

    func testInt8() {
        let n127 = NSNumber(value: 127)
        var json = JSON(n127)
        XCTAssertTrue(json.int8! == n127.int8Value)
        XCTAssertTrue(json.int8Value == n127.int8Value)
        XCTAssertTrue(json.number! == n127)
        XCTAssertEqual(json.numberValue, n127)
        XCTAssertEqual(json.stringValue, "127")

        let nm128 = NSNumber(value: -128)
        json.int8Value = nm128.int8Value
        XCTAssertTrue(json.int8! == nm128.int8Value)
        XCTAssertTrue(json.int8Value == nm128.int8Value)
        XCTAssertTrue(json.number! == nm128)
        XCTAssertEqual(json.numberValue, nm128)
        XCTAssertEqual(json.stringValue, "-128")

        let n0 = NSNumber(value: 0 as Int8)
        json.int8Value = n0.int8Value
        XCTAssertTrue(json.int8! == n0.int8Value)
        XCTAssertTrue(json.int8Value == n0.int8Value)
        XCTAssertTrue(json.number! == n0)
        XCTAssertEqual(json.numberValue, n0)
        XCTAssertEqual(json.stringValue, "0")

        let n1 = NSNumber(value: 1 as Int8)
        json.int8Value = n1.int8Value
        XCTAssertTrue(json.int8! == n1.int8Value)
        XCTAssertTrue(json.int8Value == n1.int8Value)
        XCTAssertTrue(json.number! == n1)
        XCTAssertEqual(json.numberValue, n1)
        XCTAssertEqual(json.stringValue, "1")
    }

    func testUInt8() {
        let n255 = NSNumber(value: 255)
        var json = JSON(n255)
        XCTAssertTrue(json.uInt8! == n255.uint8Value)
        XCTAssertTrue(json.uInt8Value == n255.uint8Value)
        XCTAssertTrue(json.number! == n255)
        XCTAssertEqual(json.numberValue, n255)
        XCTAssertEqual(json.stringValue, "255")

        let nm2 = NSNumber(value: 2)
        json.uInt8Value = nm2.uint8Value
        XCTAssertTrue(json.uInt8! == nm2.uint8Value)
        XCTAssertTrue(json.uInt8Value == nm2.uint8Value)
        XCTAssertTrue(json.number! == nm2)
        XCTAssertEqual(json.numberValue, nm2)
        XCTAssertEqual(json.stringValue, "2")

        let nm0 = NSNumber(value: 0)
        json.uInt8Value = nm0.uint8Value
        XCTAssertTrue(json.uInt8! == nm0.uint8Value)
        XCTAssertTrue(json.uInt8Value == nm0.uint8Value)
        XCTAssertTrue(json.number! == nm0)
        XCTAssertEqual(json.numberValue, nm0)
        XCTAssertEqual(json.stringValue, "0")

        let nm1 = NSNumber(value: 1)
        json.uInt8 = nm1.uint8Value
        XCTAssertTrue(json.uInt8! == nm1.uint8Value)
        XCTAssertTrue(json.uInt8Value == nm1.uint8Value)
        XCTAssertTrue(json.number! == nm1)
        XCTAssertEqual(json.numberValue, nm1)
        XCTAssertEqual(json.stringValue, "1")
    }

    func testInt16() {

        let n32767 = NSNumber(value: 32767)
        var json = JSON(n32767)
        XCTAssertTrue(json.int16! == n32767.int16Value)
        XCTAssertTrue(json.int16Value == n32767.int16Value)
        XCTAssertTrue(json.number! == n32767)
        XCTAssertEqual(json.numberValue, n32767)
        XCTAssertEqual(json.stringValue, "32767")

        let nm32768 = NSNumber(value: -32768)
        json.int16Value = nm32768.int16Value
        XCTAssertTrue(json.int16! == nm32768.int16Value)
        XCTAssertTrue(json.int16Value == nm32768.int16Value)
        XCTAssertTrue(json.number! == nm32768)
        XCTAssertEqual(json.numberValue, nm32768)
        XCTAssertEqual(json.stringValue, "-32768")

        let n0 = NSNumber(value: 0)
        json.int16Value = n0.int16Value
        XCTAssertTrue(json.int16! == n0.int16Value)
        XCTAssertTrue(json.int16Value == n0.int16Value)
        XCTAssertEqual(json.number, n0)
        XCTAssertEqual(json.numberValue, n0)
        XCTAssertEqual(json.stringValue, "0")

        let n1 = NSNumber(value: 1)
        json.int16 = n1.int16Value
        XCTAssertTrue(json.int16! == n1.int16Value)
        XCTAssertTrue(json.int16Value == n1.int16Value)
        XCTAssertTrue(json.number! == n1)
        XCTAssertEqual(json.numberValue, n1)
        XCTAssertEqual(json.stringValue, "1")
    }

    func testUInt16() {

        let n65535 = NSNumber(value: 65535)
        var json = JSON(n65535)
        XCTAssertTrue(json.uInt16! == n65535.uint16Value)
        XCTAssertTrue(json.uInt16Value == n65535.uint16Value)
        XCTAssertTrue(json.number! == n65535)
        XCTAssertEqual(json.numberValue, n65535)
        XCTAssertEqual(json.stringValue, "65535")

        let n32767 = NSNumber(value: 32767)
        json.uInt16 = n32767.uint16Value
        XCTAssertTrue(json.uInt16! == n32767.uint16Value)
        XCTAssertTrue(json.uInt16Value == n32767.uint16Value)
        XCTAssertTrue(json.number! == n32767)
        XCTAssertEqual(json.numberValue, n32767)
        XCTAssertEqual(json.stringValue, "32767")
    }

    func testInt32() {
        let n2147483647 = NSNumber(value: 2147483647)
        var json = JSON(n2147483647)
        XCTAssertTrue(json.int32! == n2147483647.int32Value)
        XCTAssertTrue(json.int32Value == n2147483647.int32Value)
        XCTAssertTrue(json.number! == n2147483647)
        XCTAssertEqual(json.numberValue, n2147483647)
        XCTAssertEqual(json.stringValue, "2147483647")

        let n32767 = NSNumber(value: 32767)
        json.int32 = n32767.int32Value
        XCTAssertTrue(json.int32! == n32767.int32Value)
        XCTAssertTrue(json.int32Value == n32767.int32Value)
        XCTAssertTrue(json.number! == n32767)
        XCTAssertEqual(json.numberValue, n32767)
        XCTAssertEqual(json.stringValue, "32767")

        let nm2147483648 = NSNumber(value: -2147483648)
        json.int32Value = nm2147483648.int32Value
        XCTAssertTrue(json.int32! == nm2147483648.int32Value)
        XCTAssertTrue(json.int32Value == nm2147483648.int32Value)
        XCTAssertTrue(json.number! == nm2147483648)
        XCTAssertEqual(json.numberValue, nm2147483648)
        XCTAssertEqual(json.stringValue, "-2147483648")
    }

    func testUInt32() {
        let n2147483648 = NSNumber(value: 2147483648 as UInt32)
        var json = JSON(n2147483648)
        XCTAssertTrue(json.uInt32! == n2147483648.uint32Value)
        XCTAssertTrue(json.uInt32Value == n2147483648.uint32Value)
        XCTAssertTrue(json.number! == n2147483648)
        XCTAssertEqual(json.numberValue, n2147483648)
        XCTAssertEqual(json.stringValue, "2147483648")

        let n32767 = NSNumber(value: 32767 as UInt32)
        json.uInt32 = n32767.uint32Value
        XCTAssertTrue(json.uInt32! == n32767.uint32Value)
        XCTAssertTrue(json.uInt32Value == n32767.uint32Value)
        XCTAssertTrue(json.number! == n32767)
        XCTAssertEqual(json.numberValue, n32767)
        XCTAssertEqual(json.stringValue, "32767")

        let n0 = NSNumber(value: 0 as UInt32)
        json.uInt32Value = n0.uint32Value
        XCTAssertTrue(json.uInt32! == n0.uint32Value)
        XCTAssertTrue(json.uInt32Value == n0.uint32Value)
        XCTAssertTrue(json.number! == n0)
        XCTAssertEqual(json.numberValue, n0)
        XCTAssertEqual(json.stringValue, "0")
    }

    func testInt64() {
        let int64Max = NSNumber(value: INT64_MAX)
        var json = JSON(int64Max)
        XCTAssertTrue(json.int64! == int64Max.int64Value)
        XCTAssertTrue(json.int64Value == int64Max.int64Value)
        XCTAssertTrue(json.number! == int64Max)
        XCTAssertEqual(json.numberValue, int64Max)
        XCTAssertEqual(json.stringValue, int64Max.stringValue)

        let n32767 = NSNumber(value: 32767)
        json.int64 = n32767.int64Value
        XCTAssertTrue(json.int64! == n32767.int64Value)
        XCTAssertTrue(json.int64Value == n32767.int64Value)
        XCTAssertTrue(json.number! == n32767)
        XCTAssertEqual(json.numberValue, n32767)
        XCTAssertEqual(json.stringValue, "32767")

        let int64Min = NSNumber(value: (INT64_MAX-1) * -1)
        json.int64Value = int64Min.int64Value
        XCTAssertTrue(json.int64! == int64Min.int64Value)
        XCTAssertTrue(json.int64Value == int64Min.int64Value)
        XCTAssertTrue(json.number! == int64Min)
        XCTAssertEqual(json.numberValue, int64Min)
        XCTAssertEqual(json.stringValue, int64Min.stringValue)
    }

    func testUInt64() {
        let uInt64Max = NSNumber(value: UINT64_MAX)
        var json = JSON(uInt64Max)
        XCTAssertTrue(json.uInt64! == uInt64Max.uint64Value)
        XCTAssertTrue(json.uInt64Value == uInt64Max.uint64Value)
        XCTAssertTrue(json.number! == uInt64Max)
        XCTAssertEqual(json.numberValue, uInt64Max)
        XCTAssertEqual(json.stringValue, uInt64Max.stringValue)

        let n32767 = NSNumber(value: 32767)
        json.int64 = n32767.int64Value
        XCTAssertTrue(json.int64! == n32767.int64Value)
        XCTAssertTrue(json.int64Value == n32767.int64Value)
        XCTAssertTrue(json.number! == n32767)
        XCTAssertEqual(json.numberValue, n32767)
        XCTAssertEqual(json.stringValue, "32767")
    }
}
