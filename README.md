#SwiftyJSON
SwiftyJSON makes it easy to deal with JSON data in Swift.
##Why is the typical JSON handling in Swift NOT good?
Swift is very strict about types, it's good while explicit typing left us little chance to make mistakes. 
But while dealing with things that naturally implicit about types such as JSON, it's painful.

Take the Twitter API for example: say we want to retrieve a user's "name" value of some tweet in Swift (according to Twitter's API https://dev.twitter.com/docs/api/1.1/get/statuses/home_timeline)

```JSON

[
  {
    ......
    "text": "just another test",
    ......
    "user": {
      "name": "OAuth Dancer",
      "favourites_count": 7,
      "entities": {
        "url": {
          "urls": [
            {
              "expanded_url": null,
              "url": "http://bit.ly/oauth-dancer",
              "indices": [
                0,
                26
              ],
              "display_url": null
            }
          ]
        }
      ......
    },
    "in_reply_to_screen_name": null,
  },
  ......]
  
```

The code would look like this:

```swift

let jsonObject : AnyObject! = NSJSONSerialization.JSONObjectWithData(dataFromTwitter, options: NSJSONReadingOptions.MutableContainers, error: nil)
if let statusesArray = jsonObject as? NSArray{
    if let aStatus = statusesArray[0] as? NSDictionary{
        if let user = aStatus["user"] as? NSDictionary{
            if let userName = user["name"] as? NSDictionary{
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

An unreadable mess for something like this should really be simple!

##SwiftyJSON

With SwiftyJSON all you have to do is:

```swift

let json = JSON(data: dataFromNetworking)
if let userName = json[0]["user"]["name"].string{
  //Now you got your value
}

```

And don't worry about the Optional Wrapping thing, it's done for you automatically

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
- Xcode 6.0

## Usage

####Initialization
```swift
let json = JSON(data: dataFromNetworking)
```
```swift
let json = JSON(object: jsonObject)
```
####Loop
```swift
let json = JSON(data:dataFromNetworking)
//If json is .Mapping
for (key: String, subJson: JSON) in json {
//Do something you want
}

//If json is .Sequence
//The `index` is 0..<json.count's string value
for (index: String, subJson: JSON) in json {
//Do something you want
}
```

####Use the optional getter
```swift
//NSNumber
if let id = json["user"]["favourites_count"].number {
   //Do something you want
} else {
   //Print the error
   println(json["user"]["favourites_count"])
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
if let id = json["user"]["id"].integer {
   //Do something you want
} else {
   //Print the error
   println(json["user"]["id"])
}
...
```
####Use the non-optional getter (xxxValue)

```swift
//If not a Number or nil, return 0
let id: Int = json["id"].integerValue
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

####Get the raw object from JSON
```swift
let json = JSON(data: dataFromNetworking)
if let jsonObject: AnyObject = json.object {
   // do something
} else {
    // print the error
    println(json) 
}
```

##Integration

CocoaPods is not fully supported for Swift yet, to use this library in your project you should:  

1. for Projects just drag SwiftyJSON.swift to the project tree
2. for Workspaces you may include the whole SwiftyJSON.xcodeproj as suggested by @garnett


##Work with Alamofire

To use Alamofire and SwiftyJSON, try [Alamofire-SwiftyJSON](https://github.com/SwiftyJSON/Alamofire-SwiftyJSON).
