//
//  ViewController.swift
//  SwiftyJSONExample
//
//  Created by Govin Vatsan on 2/15/16.
//
//

//NOTE: SwiftyJSON.swift has been copied into this file project. This allows us to directly use Swifty in our code
//The JSON file I am going to use is countries.json, which has also been copied into this project

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var swiftJSONText: UILabel!
    @IBOutlet weak var swiftyJSONText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* I access countries.json, then I attempt to parse it in two ways
           First, using Swift's normal JSON data handling.
           Then, using Swifty - notice how much cleaner and easier it is to use
        */
        if let path = NSBundle.mainBundle().pathForResource("countries", ofType: "json"),
            let dataFromJSON = NSData(contentsOfFile: path) {
                usingSwiftJSONHandling(dataFromJSON)    //clunky Swift way of parsing JSON data
                usingSwiftyJSONHandling(dataFromJSON)   //Swifty way of parsing data
        }
    }
    
    ///How Swift would normally parse JSON data. Swift's strict typing makes it very unreadable
    private func usingSwiftJSONHandling(dataFromJSON: NSData) {
        if let dataArray = try? NSJSONSerialization.JSONObjectWithData(dataFromJSON, options: .AllowFragments) as? [[String:AnyObject]],
            let name = dataArray![0]["name"] as? [String: AnyObject],
            let commonName = name["common"] as? String {
                swiftJSONText.text = commonName
                print ("Using normal Swift handling, the output is: \(commonName)")
        }
    }
    
    ///Using Swifty - a much cleaner and more readable way to access JSON data
    private func usingSwiftyJSONHandling(dataFromJSON: NSData) {
        let json = JSON(data: dataFromJSON)
        
        //Easily handles JSON data access
        if let commonName = json[0]["name"]["common"].string {
            swiftyJSONText.text = commonName
            print("Using Swifty handling, the output is: \(commonName)")
        }
        
        //Also handles optional wrapping easily - this should print an error
        if let userName = json[999999]["wrong_key"]["wrong_name"].string {
            print("The username is: \(userName)")
        } else {
            //Print the error
            print("Error: Attempted output is: \(json[999999]["wrong_key"]["wrong_name"])")
        }
    }
}

