//: Playground - noun: a place where people can play

import SwiftyJSON

var testData: Data?

if let file = Bundle.main.path(forResource: "SwiftyJSONTests", ofType: "json") {
    testData = try? Data(contentsOf: URL(fileURLWithPath: file))
} else {
    print("Fail")
}

let json = JSON(data: testData!)
print(json[0]["text"])
