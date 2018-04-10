//  CodableTests.swift
//
//  Created by Lei Wang on 2018/1/9.
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

class CodableTests: XCTestCase {

    func testEncodeNull() {
        var json = JSON([NSNull()])
        _ = try! JSONEncoder().encode(json)
        json = JSON([nil])
        _ = try! JSONEncoder().encode(json)
        let dictionary: [String: Any?] = ["key": nil]
        json = JSON(dictionary)
        _ = try! JSONEncoder().encode(json)
    }

    func testArrayCodable() {
        let jsonString = """
        [1,"false", ["A", 4.3231],"3",true]
        """
        var data = jsonString.data(using: .utf8)!
        let json = try! JSONDecoder().decode(JSON.self, from: data)
        XCTAssertEqual(json.arrayValue.first?.int, 1)
        XCTAssertEqual(json[1].bool, nil)
        XCTAssertEqual(json[1].string, "false")
        XCTAssertEqual(json[3].string, "3")
        XCTAssertEqual(json[2][1].double!, 4.3231)
        XCTAssertEqual(json.arrayValue[0].bool, nil)
        XCTAssertEqual(json.array!.last!.bool, true)
        let jsonList = try! JSONDecoder().decode([JSON].self, from: data)
        XCTAssertEqual(jsonList.first?.int, 1)
        XCTAssertEqual(jsonList.last!.bool, true)
        data = try! JSONEncoder().encode(json)
        let list = try! JSONSerialization.jsonObject(with: data, options: []) as! [Any]
        XCTAssertEqual(list[0] as! Int, 1)
        XCTAssertEqual((list[2] as! [Any])[1] as! NSNumber, 4.3231)
    }

    func testDictionaryCodable() {
        let dictionary: [String: Any] = ["number": 9823.212, "name": "NAME", "list": [1234, 4.21223256], "object": ["sub_number": 877.2323, "sub_name": "sub_name"], "bool": true]
        var data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
        let json = try! JSONDecoder().decode(JSON.self, from: data)
        XCTAssertNotNil(json.dictionary)
        XCTAssertEqual(json["number"].float, 9823.212)
        XCTAssertEqual(json["list"].arrayObject is [NSNumber], true)
        XCTAssertEqual(json["object"]["sub_number"].float, 877.2323)
        XCTAssertEqual(json["bool"].bool, true)
        let jsonDict = try! JSONDecoder().decode([String: JSON].self, from: data)
        XCTAssertEqual(jsonDict["number"]?.int, 9823)
        XCTAssertEqual(jsonDict["object"]?["sub_name"], "sub_name")
        data = try! JSONEncoder().encode(json)
        var encoderDict = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(encoderDict["list"] as! [NSNumber], [1234, 4.21223256])
        XCTAssertEqual(encoderDict["bool"] as! Bool, true)
        data = try! JSONEncoder().encode(jsonDict)
        encoderDict = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(encoderDict["name"] as! String, dictionary["name"] as! String)
        XCTAssertEqual((encoderDict["object"] as! [String: Any])["sub_number"] as! NSNumber, 877.2323)
    }

    func testCodableModel() {
        let dictionary: [String: Any] = [
            "number": 9823.212,
            "name": "NAME",
            "list": [1234, 4.21223256],
            "object": ["sub_number": 877.2323, "sub_name": "sub_name"],
            "bool": true]
        let data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
        let model = try! JSONDecoder().decode(CodableModel.self, from: data)
        XCTAssertEqual(model.subName, "sub_name")
    }
}

private struct CodableModel: Codable {
    let name: String
    let number: Double
    let bool: Bool
    let list: [Double]
    private let object: JSON
    var subName: String? {
        return object["sub_name"].string
    }
}
