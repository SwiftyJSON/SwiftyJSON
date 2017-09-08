# SwiftyJSON

[![Travis CI](https://travis-ci.org/SwiftyJSON/SwiftyJSON.svg?branch=master)](https://travis-ci.org/SwiftyJSON/SwiftyJSON) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) ![CocoaPods](https://img.shields.io/cocoapods/v/SwiftyJSON.svg) ![Platform](https://img.shields.io/badge/platforms-iOS%208.0+%20%7C%20macOS%2010.10+%20%7C%20tvOS%209.0+%20%7C%20watchOS%202.0+-333333.svg)

SwiftyJSON makes it easy to deal with JSON data in Swift.

1. [Why is the typical JSON handling in Swift NOT good](#why-is-the-typical-json-handling-in-swift-not-good)
2. [Requirements](#requirements)
3. [Integration](#integration)
4. [Usage](#usage)
   - [Initialization](#initialization)
   - [Subscript](#subscript)
   - [Loop](#loop)
   - [Error](#error)
   - [Optional getter](#optional-getter)
   - [Non-optional getter](#non-optional-getter)
   - [Setter](#setter)
   - [Raw object](#raw-object)
   - [Literal convertibles](#literal-convertibles)
   - [Merging](#merging)
5. [Work with Alamofire](#work-with-alamofire)
6. [Work with Moya](#work-with-moya)

> For Legacy Swift support, take a look at the [swift2 branch](https://github.com/SwiftyJSON/SwiftyJSON/tree/swift2)

> [中文介绍](http://tangplin.github.io/swiftyjson/)


## Why is the typical JSON handling in Swift NOT good?

Swift is very strict about types. But although explicit typing is good for saving us from mistakes, it becomes painful when dealing with JSON and other areas that are, by nature, implicit about types.

Take the Twitter API for example. Say we want to retrieve a user's "name" value of some tweet in Swift (according to Twitter's API https://dev.twitter.com/docs/api/1.1/get/statuses/home_timeline).

The code would look like this:

```swift
if let statusesArray = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]],
    let user = statusesArray[0]["user"] as? [String: Any],
    let username = user["name"] as? String {
    // Finally we got the username
}
```

It's not good.

Even if we use optional chaining, it would be messy:

```swift
if let JSONObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]],
    let username = (JSONObject[0]["user"] as? [String: Any])?["name"] as? String {
        // There's our username
}
```

An unreadable mess--for something that should really be simple!

With SwiftyJSON all you have to do is:

```swift
let json = JSON(data: dataFromNetworking)
if let userName = json[0]["user"]["name"].string {
  //Now you got your value
}
```

And don't worry about the Optional Wrapping thing. It's done for you automatically.

```swift
let json = JSON(data: dataFromNetworking)
if let userName = json[999999]["wrong_key"]["wrong_name"].string {
    //Calm down, take it easy, the ".string" property still produces the correct Optional String type with safety
} else {
    //Print the error
    print(json[999999]["wrong_key"]["wrong_name"])
}
```

## Requirements

- iOS 8.0+ | macOS 10.10+ | tvOS 9.0+ | watchOS 2.0+
- Xcode 8

## Integration

#### CocoaPods (iOS 8+, OS X 10.9+)

You can use [CocoaPods](http://cocoapods.org/) to install `SwiftyJSON`by adding it to your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!

target 'MyApp' do
	pod 'SwiftyJSON'
end
```

Note that this requires CocoaPods version 36, and your iOS deployment target to be at least 8.0:


#### Carthage (iOS 8+, OS X 10.9+)

You can use [Carthage](https://github.com/Carthage/Carthage) to install `SwiftyJSON` by adding it to your `Cartfile`:

```
github "SwiftyJSON/SwiftyJSON"
```

#### Swift Package Manager

You can use [The Swift Package Manager](https://swift.org/package-manager) to install `SwiftyJSON` by adding the proper description to your `Package.swift` file:

```swift
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", versions: Version(1, 0, 0)..<Version(3, .max, .max)),
    ]
)
```

Note that the [Swift Package Manager](https://swift.org/package-manager) is still in early design and development, for more information checkout its [GitHub Page](https://github.com/apple/swift-package-manager)

#### Manually (iOS 7+, OS X 10.9+)

To use this library in your project manually you may:  

1. for Projects, just drag SwiftyJSON.swift to the project tree
2. for Workspaces, include the whole SwiftyJSON.xcodeproj

## Usage

#### Initialization

```swift
import SwiftyJSON
```

```swift
let json = JSON(data: dataFromNetworking)
```
Or

```swift
let json = JSON(jsonObject)
```
Or

```swift
if let dataFromString = jsonString.data(using: .utf8, allowLossyConversion: false) {
    let json = JSON(data: dataFromString)
}
```

#### Subscript

```swift
//Getting a double from a JSON Array
let name = json[0].double
```

```swift
//Getting an array of string from a JSON Array
let arrayNames =  json["users"].arrayValue.map({$0["name"].stringValue})
```

```swift
//Getting a string from a JSON Dictionary
let name = json["name"].stringValue
```

```swift
//Getting a string using a path to the element
let path: [JSONSubscriptType] = [1,"list",2,"name"]
let name = json[path].string
//Just the same
let name = json[1]["list"][2]["name"].string
//Alternatively
let name = json[1,"list",2,"name"].string
```

```swift
//With a hard way
let name = json[].string
```

```swift
//With a custom way
let keys:[SubscriptType] = [1,"list",2,"name"]
let name = json[keys].string
```

#### Loop

```swift
//If json is .Dictionary
for (key,subJson):(String, JSON) in json {
   //Do something you want
}
```

*The first element is always a String, even if the JSON is an Array*

```swift
//If json is .Array
//The `index` is 0..<json.count's string value
for (index,subJson):(String, JSON) in json {
    //Do something you want
}
```

#### Error

##### SwiftyJSON 4.x

SwiftyJSON 4.x introduces an enum type called `SwiftyJSONError`, which includes `unsupportedType`, `indexOutOfBounds`, `elementTooDeep`, `wrongType`, `notExist` and `invalidJSON`, at the same time, `ErrorDomain` are being replaced by `SwiftyJSONError.errorDomain`.
Note: Those old error types are deprecated in SwiftyJSON 4.x and will be removed in the future release.

##### SwiftyJSON 3.x

Use a subscript to get/set a value in an Array or Dictionary

If the JSON is:
*  an array, the app may crash with "index out-of-bounds."
*  a dictionary, it will be assigned to `nil` without a reason.
*  not an array or a dictionary, the app may crash with an "unrecognised selector" exception.

This will never happen in SwiftyJSON.

```swift
let json = JSON(["name", "age"])
if let name = json[999].string {
    //Do something you want
} else {
    print(json[999].error!) // "Array[999] is out of bounds"
}
```

```swift
let json = JSON(["name":"Jack", "age": 25])
if let name = json["address"].string {
    //Do something you want
} else {
    print(json["address"].error!) // "Dictionary["address"] does not exist"
}
```

```swift
let json = JSON(12345)
if let age = json[0].string {
    //Do something you want
} else {
    print(json[0])       // "Array[0] failure, It is not an array"
    print(json[0].error!) // "Array[0] failure, It is not an array"
}

if let name = json["name"].string {
    //Do something you want
} else {
    print(json["name"])       // "Dictionary[\"name"] failure, It is not an dictionary"
    print(json["name"].error!) // "Dictionary[\"name"] failure, It is not an dictionary"
}
```

#### Optional getter

```swift
//NSNumber
if let id = json["user"]["favourites_count"].number {
   //Do something you want
} else {
   //Print the error
   print(json["user"]["favourites_count"].error!)
}
```

```swift
//String
if let id = json["user"]["name"].string {
   //Do something you want
} else {
   //Print the error
   print(json["user"]["name"].error!)
}
```

```swift
//Bool
if let id = json["user"]["is_translator"].bool {
   //Do something you want
} else {
   //Print the error
   print(json["user"]["is_translator"].error!)
}
```

```swift
//Int
if let id = json["user"]["id"].int {
   //Do something you want
} else {
   //Print the error
   print(json["user"]["id"].error!)
}
...
```

#### Non-optional getter

Non-optional getter is named `xxxValue`

```swift
//If not a Number or nil, return 0
let id: Int = json["id"].intValue
```

```swift
//If not a String or nil, return ""
let name: String = json["name"].stringValue
```

```swift
//If not an Array or nil, return []
let list: Array<JSON> = json["list"].arrayValue
```

```swift
//If not a Dictionary or nil, return [:]
let user: Dictionary<String, JSON> = json["user"].dictionaryValue
```

#### Setter

```swift
json["name"] = JSON("new-name")
json[0] = JSON(1)
```

```swift
json["id"].int =  1234567890
json["coordinate"].double =  8766.766
json["name"].string =  "Jack"
json.arrayObject = [1,2,3,4]
json.dictionaryObject = ["name":"Jack", "age":25]
```

#### Raw object

```swift
let jsonObject: Any = json.object
```

```swift
if let jsonObject: Any = json.rawValue
```

```swift
//convert the JSON to raw NSData
if let data = json.rawData() {
    //Do something you want
}
```

```swift
//convert the JSON to a raw String
if let string = json.rawString() {
    //Do something you want
}
```

#### Existence

```swift
//shows you whether value specified in JSON or not
if json["name"].exists()
```

#### Literal convertibles

For more info about literal convertibles: [Swift Literal Convertibles](http://nshipster.com/swift-literal-convertible/)

```swift
//StringLiteralConvertible
let json: JSON = "I'm a json"
```

```swift
//IntegerLiteralConvertible
let json: JSON =  12345
```

```swift
//BooleanLiteralConvertible
let json: JSON =  true
```

```swift
//FloatLiteralConvertible
let json: JSON =  2.8765
```

```swift
//DictionaryLiteralConvertible
let json: JSON =  ["I":"am", "a":"json"]
```

```swift
//ArrayLiteralConvertible
let json: JSON =  ["I", "am", "a", "json"]
```

```swift
//NilLiteralConvertible
let json: JSON =  nil
```

```swift
//With subscript in array
var json: JSON =  [1,2,3]
json[0] = 100
json[1] = 200
json[2] = 300
json[999] = 300 //Don't worry, nothing will happen
```

```swift
//With subscript in dictionary
var json: JSON =  ["name": "Jack", "age": 25]
json["name"] = "Mike"
json["age"] = "25" //It's OK to set String
json["address"] = "L.A." // Add the "address": "L.A." in json
```

```swift
//Array & Dictionary
var json: JSON =  ["name": "Jack", "age": 25, "list": ["a", "b", "c", ["what": "this"]]]
json["list"][3]["what"] = "that"
json["list",3,"what"] = "that"
let path: [JSONSubscriptType] = ["list",3,"what"]
json[path] = "that"
```

```swift
//With other JSON objects
let user: JSON = ["username" : "Steve", "password": "supersecurepassword"]
let auth: JSON = [
  "user": user.object //use user.object instead of just user
  "apikey": "supersecretapitoken"
]
```

#### Merging

It is possible to merge one JSON into another JSON. Merging a JSON into another JSON adds all non existing values to the original JSON which are only present in the `other` JSON.

If both JSONs contain a value for the same key, _mostly_ this value gets overwritten in the original JSON, but there are two cases where it provides some special treatment:

- In case of both values being a `JSON.Type.array` the values form the array found in the `other` JSON getting appended to the original JSON's array value.
- In case of both values being a `JSON.Type.dictionary` both JSON-values are getting merged the same way the encapsulating JSON is merged.

In case, where two fields in a JSON have a different types, the value will get always overwritten.

There are two different fashions for merging: `merge` modifies the original JSON, whereas `merged` works non-destructively on a copy.

```swift
let original: JSON = [
    "first_name": "John",
    "age": 20,
    "skills": ["Coding", "Reading"],
    "address": [
        "street": "Front St",
        "zip": "12345",
    ]
]

let update: JSON = [
    "last_name": "Doe",
    "age": 21,
    "skills": ["Writing"],
    "address": [
        "zip": "12342",
        "city": "New York City"
    ]
]

let updated = original.merge(with: update)
// [
//     "first_name": "John",
//     "last_name": "Doe",
//     "age": 21,
//     "skills": ["Coding", "Reading", "Writing"],
//     "address": [
//         "street": "Front St",
//         "zip": "12342",
//         "city": "New York City"
//     ]
// ]
```

## String representation
There are two options available:
- use the default Swift one
- use a custom one that will handle optionals well and represent `nil` as `"null"`:
```swift
let dict = ["1":2, "2":"two", "3": nil] as [String: Any?]
let json = JSON(dict)
let representation = json.rawString(options: [.castNilToNSNull: true])
// representation is "{\"1\":2,\"2\":\"two\",\"3\":null}", which represents {"1":2,"2":"two","3":null}
```

## Work with [Alamofire](https://github.com/Alamofire/Alamofire)

SwiftyJSON nicely wraps the result of the Alamofire JSON response handler:

```swift
Alamofire.request(url, method: .get).validate().responseJSON { response in
    switch response.result {
    case .success(let value):
        let json = JSON(value)
        print("JSON: \(json)")
    case .failure(let error):
        print(error)
    }
}
```

We also provide an extension of Alamofire for serializing NSData to SwiftyJSON's JSON.

See: [Alamofire-SwiftyJSON](https://github.com/SwiftyJSON/Alamofire-SwiftyJSON)


## Work with [Moya](https://github.com/Moya/Moya)

SwiftyJSON parse data to JSON:

```swift
let provider = MoyaProvider<Backend>()
provider.request(.showProducts) { result in
    switch result {
    case let .success(moyaResponse):
        let data = moyaResponse.data
        let json = JSON(data: data) // convert network data to json
        print(json)
    case let .failure(error):
        print("error: \(error)")
    }
}

```
