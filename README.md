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
let json = JSONValue(dataFromNetworking)
if let userName = json[0]["user"]["name"].string{
  //Now you got your value
}
```

And don't worry about the Optional Wrapping thing, it's done for you automatically

```swift
let json = JSONValue(dataFromNetworking)
if let userName = json[999999]["wrong_key"]["wrong_name"].string{
  //Calm down, take it easy, the ".string" property still produces the correct Optional String type with safety
}

```
```swift
let json = JSONValue(jsonObject)
switch json["user_id"]{
case .JString(let stringValue):
    let id = stringValue.toInt()
case .JNumber(let numberValue):
    let id = numberValue.integerValue
default:
    println("ooops!!! JSON Data is Unexpected or Broken")

```

##Error Handling
```swift
let json = JSONValue(dataFromNetworking)["some_key"]["some_wrong_key"]["wrong_name"]
if json{
  //JSONValue it self confirm to Protocol "LogicValue", with JSONValue.JInvalid produce false and others produce true
}else{
  println(json)
  //> JSON Keypath Error: Incorrect Keypath "some_wrong_key/wrong_name"
  //It always tells you where your key starts went wrong
  switch json{
  case .JInvalid(let error):
    //An NSError containing detailed error information 
  }
}
```
##Integration
CocoaPods is not fully supported for Swift yet, to use this library in your project you should:  

1. for Projects just drag SwiftyJSON.swift to the project tree
2. for Workspaces you may include the whole SwiftyJSON.xcodeproj as suggested by @garnett
