#SwiftyJSON [中文介绍](http://tangplin.github.io/swiftyjson/)

SwiftyJSON makes it easy to deal with JSON data in Swift.

1. [Why is the typical JSON handling in Swift NOT good](#why-is-the-typical-json-handling-in-swift-not-good)
1. [Requirements](#requirements)
1. [Integration](#integration)
1. [Usage](#usage)
	- [Initialization](#initialization)
	- [Subscript](#subscript)
	- [Loop](#loop)
	- [Error](#error)
	- [Optional getter](#optional-getter)
	- [Non-optional getter](#non-optional-getter)
	- [Setter](#setter)
	- [Raw object](#raw-object)
	- [Literal convertibles](#literal-convertibles)
1. [Work with Alamofire](#work-with-alamofire)

##Why is the typical JSON handling in Swift NOT good?
Swift is very strict about types. But although explicit typing is good for saving us from mistakes, it becomes painful when dealing with JSON and other areas that are, by nature, implicit about types.

Take the Twitter API for example.  Say we want to retrieve a user's "name" value of some tweet in Swift (according to Twitter's API https://dev.twitter.com/docs/api/1.1/get/statuses/home_timeline).

The code would look like this:

```swift

let jsonObject : AnyObject! = NSJSONSerialization.JSONObjectWithData(dataFromTwitter, options: NSJSONReadingOptions.MutableContainers, error: nil)
if let statusesArray = jsonObject as? NSArray{
    if let aStatus = statusesArray[0] as? NSDictionary{
        if let user = aStatus["user"] as? NSDictionary{
            if let userName = user["name"] as? NSString{
                //Finally We Got The Name

            }
        }
    }
}

```

It's not good.

Even if we use optional chaining, it would also cause a mess:

```swift

let jsonObject : AnyObject! = NSJSONSerialization.JSONObjectWithData(dataFromTwitter, options: NSJSONReadingOptions.MutableContainers, error: nil)
if let userName = (((jsonObject as? NSArray)?[0] as? NSDictionary)?["user"] as? NSDictionary)?["name"]{
  //What A disaster above
}

```
An unreadable mess--for something that should really be simple!

With SwiftyJSON all you have to do is:

```swift

let json = JSON(data: dataFromNetworking)
if let userName = json[0]["user"]["name"].string{
  //Now you got your value
}

```

And don't worry about the Optional Wrapping thing. It's done for you automatically.

```swift

let json = JSON(data: dataFromNetworking)
if let userName = json[999999]["wrong_key"]["wrong_name"].string{
    //Calm down, take it easy, the ".string" property still produces the correct Optional String type with safety
} else {
    //Print the error
    println(json[999999]["wrong_key"]["wrong_name"])
}

```

## Requirements

- iOS 7.0+ / Mac OS X 10.9+
- Xcode 6.1

##Integration

####Carthage
You can use [Carthage](https://github.com/Carthage/Carthage) to install `SwiftyJSON` by adding it to your `Cartfile`:
```
github "SwiftyJSON/SwiftyJSON" >= 2.2
```

####CocoaPods
You can use [Cocoapods](http://cocoapods.org/) to install `SwiftyJSON`by adding it to your `Podfile`:
```ruby
pod "SwiftyJSON", ">= 2.2"
```
Note that it needs you to install CocoaPods 36 version, and requires your iOS deploy target >= 8.0:
```bash
[sudo] gem install cocoapods -v '>=0.36'
```
####Manually

To use this library in your project manually you may:  

1. for Projects, just drag SwiftyJSON.swift to the project tree
2. for Workspaces, include the whole SwiftyJSON.xcodeproj (as suggested by @garnett)

## Usage

####Initialization
```swift
let json = JSON(data: dataFromNetworking)
```
```swift
let json = JSON(jsonObject)
```

####Subscript
```swift
//With a int from JSON supposed to an Array
let name = json[0].double
```
```swift
//With a string from JSON supposed to an Dictionary
let name = json["name"].stringValue
```
```swift
//With an array like path to the element
let path = [1,"list",2,"name"]
let name = json[path].string
//Just the same
let name = json[1]["list"][2]["name"].string
```
```swift
//With a literal array to the element
let name = json[1,"list",2,"name"].string
//Just the same
let name = json[1]["list"][2]["name"].string
```
```swift
//With a Hard Way
let name = json[[1,"list",2,"name"]].string
```
####Loop
```swift
//If json is .Dictionary
for (key: String, subJson: JSON) in json {
   //Do something you want
}
```
*The first element is always String, even if the JSON's object is Array*
```swift
//If json is .Array
//The `index` is 0..<json.count's string value
for (index: String, subJson: JSON) in json {
    //Do something you want
}
```
####Error
Use subscript to get/set value in Array or Dicitonary

*  If json is an array, the app may crash with "index out-of-bounds."
*  If json is a dictionary, it will get `nil` without the reason.
*  If json is not an array or a dictionary, the app may crash with the wrong selector exception.

It will never happen in SwiftyJSON.

```swift
let json = JSON(["name", "age"])
if let name = json[999].string {
    //Do something you want
} else {
    println(json[999].error) // "Array[999] is out of bounds"
}
```
```swift
let json = JSON(["name":"Jack", "age": 25])
if let name = json["address"].string {
    //Do something you want
} else {
    println(json["address"].error) // "Dictionary["address"] does not exist"
}
```
```swift
let json = JSON(12345)
if let age = json[0].string {
    //Do something you want
} else {
    println(json[0])       // "Array[0] failure, It is not an array"
    println(json[0].error) // "Array[0] failure, It is not an array"
}

if let name = json["name"].string {
    //Do something you want
} else {
    println(json["name"])       // "Dictionary[\"name"] failure, It is not an dictionary"
    println(json["name"].error) // "Dictionary[\"name"] failure, It is not an dictionary"
}
```

####Optional getter
```swift
//NSNumber
if let id = json["user"]["favourites_count"].number {
   //Do something you want
} else {
   //Print the error
   println(json["user"]["favourites_count"].error)
}
```
```swift
//String
if let id = json["user"]["name"].string {
   //Do something you want
} else {
   //Print the error
   println(json["user"]["name"])
}
```
```swift
//Bool
if let id = json["user"]["is_translator"].bool {
   //Do something you want
} else {
   //Print the error
   println(json["user"]["is_translator"])
}
```
```swift
//Int
if let id = json["user"]["id"].int {
   //Do something you want
} else {
   //Print the error
   println(json["user"]["id"])
}
...
```
####Non-optional getter
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
//If not a Array or nil, return []
let list: Array<JSON> = json["list"].arrayValue
```
```swift
//If not a Dictionary or nil, return [:]
let user: Dictionary<String, JSON> = json["user"].dictionaryValue
```

####Setter
```swift
json["name"] = JSON("new-name")
json[0] = JSON(1)
```
```swift
json["id"].int =  1234567890
json["coordinate"].double =  8766.766
json["name"].string =  "Jack"
json.arrayObject = [1,2,3,4]
json.dictionary = ["name":"Jack", "age":25]
```

####Raw object
```swift
let jsonObject: AnyObject = json.object
```
```swift
if let jsonObject: AnyObject = json.rawValue
```
```swift
//convert the JSON to raw NSData
if let data = json.rawData() {
    //Do something you want
}
```
```swift
//convert the JSON to raw String
if let string = json.rawString() {
    //Do something you want
}
```
####Literal convertibles
More info about the literal convertibles: [Swift Literal Convertibles](http://nshipster.com/swift-literal-convertible/)
```swift
//StringLiteralConvertible
let json:JSON = "I'm a json"
```
```swift
//IntegerLiteralConvertible
let json:JSON =  12345
```
```swift
//BooleanLiteralConvertible
let json:JSON =  true
```
```swift
//FloatLiteralConvertible
let json:JSON =  2.8765
```
```swift
//DictionaryLiteralConvertible
let json:JSON =  ["I":"am", "a":"json"]
```
```swift
//ArrayLiteralConvertible
let json:JSON =  ["I", "am", "a", "json"]
```
```swift
//NilLiteralConvertible
let json:JSON =  nil
```
```swift
//With subscript in array
var json:JSON =  [1,2,3]
json[0] = 100
json[1] = 200
json[2] = 300
json[999] = 300 //Don't worry, nothing will happen
```
```swift
//With subscript in dictionary
var json:JSON =  ["name":"Jack", "age": 25]
json["name"] = "Mike"
json["age"] = "25" //It's OK to set String
json["address"] = "L.A." // Add the "address": "L.A." in json
```
```swift
//Array & Dictionary
var json:JSON =  ["name":"Jack", "age": 25, "list":["a","b","c",["what":"this"]]]
json["list"][3]["what"] = "that"
json["list",3,"what"] = "that"
let path = ["list",3,"what"]
json[path] = "that"
```
##Work with Alamofire

SwiftyJSON nicely wraps the result of the Alamofire JSON response handler:
```swift
Alamofire.request(.GET, url, parameters: parameters)
  .responseJSON { (req, res, json, error) in
    if(error != nil) {
      NSLog("Error: \(error)")
      println(req)
      println(res)
    }
    else {
      NSLog("Success: \(url)")
      var json = JSON(json!)
    }
  }
```
