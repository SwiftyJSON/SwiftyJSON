//
//  JSONSerializableTests.swift
//  SwiftyJSON
//
//  Created by bo shen on 15/7/5.
//
//

import XCTest
import SwiftyJSON

/**
*  MARK:User Model
*/
class User:JSONSerialize
{
    var UserId:Int?
    var UserName:String?
    var Age:Int?
    var Phone:String?
    
    required init(_ json:JSON)
    {
        self.UserId = json["UserId"].intValue
        self.UserName = json["UserName"].stringValue
        self.Age = json["Age"].intValue
        self.Phone = json["Phone"].stringValue
    }
}

/**
*  MARK:Company Model
*/
class Company:JSONSerialize
{
    var CompanyName:String?
    var CompanyDepartment:[String]?
    
    required init(_ json: JSON) {
        self.CompanyName = json["CompanyName"].string
        self.CompanyDepartment = json["CompanyDepartment"].arrayObject as? [String]
    }
    
}

class JSONSerializeTests: XCTestCase {

    var userJsonStr:AnyObject!
    
    var companyJsonStr:AnyObject!
    
    override func setUp() {
        super.setUp()

        userJsonStr = ["UserId":1,"UserName":"test","Age":25,"Phone":"13507608567"]
        
        companyJsonStr = ["CompanyName":"testCompanyName","CompanyDepartment":["Department1","Department2","Department3"]]
        
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testDictionaryToModel()
    {
        let user = User(JSON(userJsonStr))
        
        XCTAssertNotNil(user, "dictionary serialize fail")
    }
    
    func testDictionarySerializedInfo()
    {
        let user = User(JSON(userJsonStr))
        
        XCTAssertEqual(user.UserId!, 1, " UserId not equal 1")
        XCTAssertEqual(user.UserName!, "test", "UserName not equal test")
        XCTAssertEqual(user.Age!, 25, "Age not equal 25")
        XCTAssertEqual(user.Phone!, "13507608567", "Phone not equal 13507608567")
    }
    
    func testArrayToModel()
    {
        let company = Company(JSON(companyJsonStr))
        
        XCTAssertNotNil(company, "array  serialize fail")
    }
    
    func testArraySerializedInfo()
    {
        let company = Company(JSON(companyJsonStr))
        
        XCTAssertEqual(company.CompanyName!, "testCompanyName", " companyName not equal testCompanyName")
        XCTAssertEqual(company.CompanyDepartment!.count, 3, "company's department is not equal 3")
        XCTAssertEqual(company.CompanyDepartment![0], "Department1", "company's first department is not equal Department1")
        XCTAssertEqual(company.CompanyDepartment![1], "Department2", "company's first department is not equal Department1")
        XCTAssertEqual(company.CompanyDepartment![2], "Department3", "company's first department is not equal Department1")
    }
}
