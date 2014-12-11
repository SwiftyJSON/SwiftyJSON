//
//  MapperTests.swift
//  SwiftyJSON
//
//  Created by Edgard Hernandez on 11/19/14.
//
//

import XCTest
import Foundation
import SwiftyJSON


class MapperTests: XCTestCase {

    var testData: NSData!

    override func setUp() {
        super.setUp()
        
        if let file = NSBundle(forClass:PerformanceTests.self).pathForResource("TestMapper", ofType: "json") {
            self.testData = NSData(contentsOfFile: file)
        } else {
            XCTFail("Can't find the test JSON file")
        }
    }

    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    
    func testJsonValueToSwiftObject() {
        
        var mapper = SwiftyMapper()
        
        /* Note: Grabbed AssertTest Equals from TestMapper.json file. */
        
        
        var jsondata = JSON(data:self.testData)
        println("\n\n")
        println(jsondata)
        println("\n\n\n")
        var arrayOfObjects: [TestSwiftObject] = mapper.MapJsonToObj(jsondata) as [TestSwiftObject]
        
        //Check Array has the Amount of Objects Expected. 
        XCTAssertEqual(arrayOfObjects.count,2)
        
        
        var firstObj = arrayOfObjects[0]
        
        let expectedId:String = "12345"
        let expectedTextString:String = "just some test"
        
        //Check for Common String Types.
        XCTAssertEqual(firstObj.id,expectedId)
        XCTAssertEqual(firstObj.text,expectedTextString)
        XCTAssertEqual(firstObj.Nothing as NSNull, NSNull())
        
        
        //Now check array data is Completely Transferred
        XCTAssertEqual(firstObj.cars[0] as String,"Audi")
        XCTAssertEqual(firstObj.cars[1] as String,"BMW")
        XCTAssertEqual(firstObj.cars[2] as String,"Bugatti")
        XCTAssertEqual(firstObj.cars[3] as String,"Chevy")
        
        
        //TODO: Fix this array issue... it should NOT be a String, it should BE an Array
        //var arrayInsideArray: AnyObject = arrayOfObjects[0].cars[4]
        //println(arrayInsideArray)
        
        //Test if Dictionaries are Mapped
        var dict = firstObj.user
        let myname = "Toothless The Night Fury"
        XCTAssertEqual(dict["name"] as String, myname)
        
        //Tests Bools should be Mapped too.
        if(firstObj.retweeted != false){
            XCTFail("Retweeted Property has to be 'False'")
        }
        
        
        //Now Test Second Obj. 
        
        var secondObj = arrayOfObjects[1]
        
        
        //Check for Common String Types.
        XCTAssertEqual(secondObj.id, "98765")
        XCTAssertEqual(secondObj.text,"What would our world be like if we had Dragons?")
        XCTAssertEqual(secondObj.Nothing as NSNull, NSNull())
        
        
        //Now check array data is Completely Transferred
        XCTAssertEqual(secondObj.cars[0] as String,"Ferrari")
        
        //Test if Dictionaries are Mapped
        var sodict = secondObj.user
        let secondObjName = "Hiccup The Viking"
        XCTAssertEqual(sodict["name"] as String, secondObjName)
        
        //Tests Bools should be Mapped too.
        if(secondObj.retweeted != true){
            XCTFail("Second Object Retweeted Property has to be 'True'")
        }

        
        
    }
    
    
    
    
    
}



/**
 * Class only for testing Purposes in this Test Cases only
 * a JsonValue object should successfully map to this Class
 **/
class TestSwiftObject : NSObject {
    
    var id: String!
    var text: String!
    var cars: [AnyObject]!
    var retweeted: Bool = true
    var Nothing: AnyObject!
    var user: Dictionary<String,AnyObject>!
    
    override init() {
        super.init()
    }
    
}