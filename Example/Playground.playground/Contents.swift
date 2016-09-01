//: Playground - noun: a place where people can play

import SwiftyJSON

var testData: NSData?

if let file = NSBundle.mainBundle().pathForResource("SwiftyJSONTests", ofType: "json") {
    testData = NSData(contentsOfFile: file)
} else {
    print("Fail")
}

let json = JSON(data: testData!)
print(json[0]["text"])