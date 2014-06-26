#SwiftyJSON
SwiftyJSON makes it easy to deal with JSON data in Swift.
##Why The Typical JSON Handling in Swift is NOT Good?
Swift is very strict about types, It's good while explicit typing left us little chance to make mistakes. 
But while dealing with things that naturally implicit about types such as JSON, It's painful.
Take the Twitter API for example:
Say we want to retrive a user's "name" value of some tweet in Swift,according to twitter's api:https://dev.twitter.com/docs/api/1.1/get/statuses/home_timeline

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
It's Not Good

Even if we use Optional Chainning would also cause a mess:

```swift

let jsonObject : AnyObject! = NSJSONSerialization.JSONObjectWithData(dataFromTwitter, options: NSJSONReadingOptions.MutableContainers, error: nil)
if let userName = (((jsonObject as? NSArray)?[0] as? NSDictionary)?["user"] as? NSDictionary)?["name"]{
  //What A disaster above
}

```
An unreadable mess for something should be really simple!

##SwiftyJSON

With SwiftyJSON all you have to do is:

```swift
let json = JSONValue(dataFromNetworking)
if let userName = json[0]["user"]["name"].string{
  //Now you got your value
}
```

And don't worry about the Optional Wrapping Thing, it's done for you automaticly

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
  //JSONValue it self confirm to Protocol "Logic"
  //Calm down, take it easy
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
