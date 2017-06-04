//: Playground - noun: a place where people can play
/*:
 # SwiftyJSON
 SwiftyJSON makes it easy to deal with JSON data in Swift.
 
 You must have to build `SwiftyJSON iOS` package for import.
 */
/*:
 ### Basic setting for playground
 */
import SwiftyJSON
import Foundation

var jsonData: Data?

if let file = Bundle.main.path(forResource: "SwiftyJSONTests", ofType: "json") {
    jsonData = try? Data(contentsOf: URL(fileURLWithPath: file))
} else {
    print("Fail")
}

let jsonObject = try JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments)

let jsonString = String(data: jsonData!, encoding: .utf8)

/*:
 ## Usage
 
 ### Initialization
 
 */
import SwiftyJSON

let json1 = try? JSON(data: jsonData!)
/*:
 or
 */
let json2 = JSON(jsonObject)
/*:
 or
 */
let dataFromString = jsonString?.data(using: .utf8)
let json3 = try? JSON(data: dataFromString!)

/*:
 ### Subscript
 */
// Example json
let json: JSON = JSON([
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
])

// Getting a double from a JSON Array
json["array"][0].double

// Getting an array of string from a JSON Array
let arrayOfString = json["users"].arrayValue.map({$0["info"]["name"]})
print(arrayOfString)

// Getting a string from a JSON Dictionary
json["users"][0]["info"]["name"].stringValue

// Getting a string using a path to the element
let path = ["users", 1, "info", "name"] as [JSONSubscriptType]
var name = json["users", 1, "info", "name"].string

// With a custom way
let keys: [JSONSubscriptType] = ["users", 1, "info", "name"]
name = json[keys].string

// Just the same
name = json["users"][1]["info"]["name"].string

// Alternatively
name = json["users", 1, "info", "name"].string

/*:
 ### Loop
 */
// If json is .Dictionary
for (key, subJson):(String, JSON) in json {
	//Do something you want
//	print(subJson)
}

/*The first element is always a String, even if the JSON is an Array*/
//If json is .Array
//The `index` is 0..<json.count's string value
for (index, subJson):(String, JSON) in json["array"] {
	//Do something you want
	print("\(index): \(subJson)")
}

/*:
 ### Error

SwiftyJSON 4.x

SwiftyJSON 4.x introduces an enum type called `SwiftyJSONError`, which includes `unsupportedType`, `indexOutOfBounds`, `elementTooDeep`, `wrongType`, `notExist` and `invalidJSON`, at the same time, `ErrorDomain` are being replaced by `SwiftyJSONError.errorDomain`. Note: Those old error types are deprecated in SwiftyJSON 4.x and will be removed in the future release.

Use a subscript to get/set a value in an Array or Dictionary

If the JSON is:

- an array, the app may crash with "index out-of-bounds."
- a dictionary, it will be assigned nil without a reason.
- not an array or a dictionary, the app may crash with an "unrecognised selector" exception.

This will never happen in SwiftyJSON.
*/

let errorJson = JSON(["name", "age"])
if let name = errorJson[999].string {
	//Do something you want
} else {
	print(errorJson[999].error!) // "Array[999] is out of bounds"
}

let errorJson2 = JSON(["name": "Jack", "age": 25])
if let name = errorJson2["address"].string {
	//Do something you want
} else {
	print(errorJson2["address"].error!) // "Dictionary["address"] does not exist"
}

let errorJson3 = JSON(12345)
if let age = errorJson3[0].string {
	//Do something you want
} else {
	print(errorJson3[0])       // "Array[0] failure, It is not an array"
	print(errorJson3[0].error!) // "Array[0] failure, It is not an array"
}

if let name = json["name"].string {
	//Do something you want
} else {
	print(json["name"])       // "Dictionary[\"name"] failure, It is not an dictionary"
	print(json["name"].error!) // "Dictionary[\"name"] failure, It is not an dictionary"
}

/*:
### Optional getter
*/

// Example json
let jsonOG: JSON = JSON([
	"id": 987654,
	"user": [
		"favourites_count": 8,
		"name": "jack",
		"email": "jack@gmail.com",
		"is_translator": true
	]
])

//NSNumber
if let id = jsonOG["user"]["favourites_count"].number {
	//Do something you want
	print(id)
} else {
	//Print the error
	print(jsonOG["user"]["favourites_count"].error!)
}

//String
if let id = jsonOG["user"]["name"].string {
	//Do something you want
	print(id)
} else {
	//Print the error
	print(jsonOG["user"]["name"].error!)
}

//Bool
if let id = jsonOG["user"]["is_translator"].bool {
	//Do something you want
	print(id)
} else {
	//Print the error
	print(jsonOG["user"]["is_translator"].error!)
}

/*:
### Non-optional getter
Non-optional getter is named xxxValue
*/

// Example json
let jsonNOG: JSON = JSON([
	"id": 987654,
	"name": "jack",
	"list": [
		["number": 1],
		["number": 2],
		["number": 3]
	],
	"user": [
		"favourites_count": 8,
		"email": "jack@gmail.com",
		"is_translator": true
	]
])

//If not a Number or nil, return 0
let idNOG: Int = jsonOG["id"].intValue
print(idNOG)

//If not a String or nil, return ""
let nameNOG: String = jsonNOG["name"].stringValue
print(nameNOG)

//If not an Array or nil, return []
let listNOG: Array = jsonNOG["list"].arrayValue
print(listNOG)

//If not a Dictionary or nil, return [:]
let userNOG: Dictionary = jsonNOG["user"].dictionaryValue
print(userNOG)



