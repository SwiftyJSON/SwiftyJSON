#SwiftyJSON
SwiftyJSON makes it easy to deal with JSON data in Swift.
##The Typical JSON Handling in Swift
What's the problem with the way JSON handling in Swift?

Let's take the [Twitter API](https://dev.twitter.com/docs/api/1.1/get/statuses/home_timeline) for example:

```JSON
[
  {
  
    ......
    
    "text": "just another test",
    
    ......
    
    "user": {
      "name": "OAuth Dancer",
      "follow_request_sent": false,
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

What if we want to retrive the user's "name" value of the first tweet in swift?

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
What A Pain!!!

Even if we use Optional Chainning would also cause a mess:

```swift

let jsonObject : AnyObject! = NSJSONSerialization.JSONObjectWithData(dataFromTwitter, options: NSJSONReadingOptions.MutableContainers, error: nil)
if let userName = (((jsonObject as? NSArray)?[0] as? NSDictionary)?["user"] as? NSDictionary)?["name"]{
  //What A disaster above
}

```
What an unreadable mess for something should be really simple!

##SwiftyJSON

With SwiftyJSON all you have to do is:

```
if let userName = JSONValue(jsonObject)[0]["user"]["name"].string{
  //Now you got your value
}
```

And don't worry about the Optional Wrapping Thing, it's done for you automaticly

```
if let userName = JSONValue(jsonObject)[999999]["wrong_key"]["wrong_name"].string{
  //Calm down, take it easy, the ".string" property still produces the correct Optional String type with safety
}

```
