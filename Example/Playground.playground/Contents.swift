//: Playground - noun: a place where people can play

/*:
 ## Basic setting for playground
 */
import SwiftyJSON

var jsonData: Data?

if let file = Bundle.main.path(forResource: "SwiftyJSONTests", ofType: "json") {
    jsonData = try? Data(contentsOf: URL(fileURLWithPath: file))
} else {
    print("Fail")
}

let jsonObject = try JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments) as? [[String: AnyObject]]

let jsonString = String(data: jsonData!, encoding: .utf8)

/*:
 # Usage
 
 ## Initialization
 
 */
import SwiftyJSON

let json1 = JSON(data: jsonData!)
/*:
 or
 */
let json2 = JSON(jsonObject)
/*:
 or
 */
let dataFromString = jsonString?.data(using: .utf8)
let json3 = JSON(data: dataFromString!)

/*:
 ## Subscript
 */
// Example json
var jsonArray: JSON = [
    "array": [12.34, 56.78],
    "users": [
        [
            "id": 987654,
            "info": [
                "name": "jack",
                "email": "jack@gmail.com"
            ],
            "feeds": [98833, 23443, 213239, 23232]
        ],
        [
            "id": 654321,
            "info": [
                "name": "jeffgukang",
                "email": "jeffgukang@gmail.com"
            ],
            "feeds": [12345, 56789, 12423, 12412]
        ]
    ]
]

var jsonDictionary: JSON = [
    "name": "jeffgukang",
    "country": "South Korea"
]

// Getting a double from a JSON Array
jsonArray["array"][0].double

// Getting an array of string from a JSON Array
let arrayOfString = jsonArray["users"].arrayValue.map({$0["info"]["name"]})
print(arrayOfString)

// Getting a string from a JSON Dictionary
jsonDictionary["country"].stringValue

//Getting a string using a path to the element
let path: [JSONSubscriptType] = ["users", 1, "info", "name"]
let feed = jsonArray[path].string

////Just the same
//let name = json[1]["list"][2]["name"].string
////Alternatively
//let name = json[1,"list",2,"name"].string
//
//
//```swift
////With a hard way
//let name = json[].string
//```
//```swift
////With a custom way
//let keys:[SubscriptType] = [1,"list",2,"name"]
//let name = json[keys].string
//```
