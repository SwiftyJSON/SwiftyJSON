//  SwiftyJSON.h
//
//  Copyright (c) 2014 Pinglin Tang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import SwiftyJSON

class ViewController: UITableViewController {

    var json: JSON = JSON.null
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.json.type {
        case Type.Array, Type.Dictionary:
            return self.json.count
        default:
            return 1
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("JSONCell", forIndexPath: indexPath) as UITableViewCell
            
        let row = indexPath.row
        
        switch self.json.type {
        case .Array:
            cell.textLabel?.text = "\(row)"
            cell.detailTextLabel?.text = self.json.arrayValue.description
        case .Dictionary:
            let key: AnyObject = self.json.dictionaryValue.keys.array[row]
            let value = self.json[key as! String]
            cell.textLabel?.text = "\(key)"
            cell.detailTextLabel?.text = value.description
        default:
            cell.textLabel?.text = ""
            cell.detailTextLabel?.text = self.json.description
        }
        
        return cell
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {

        var nextController: UIViewController?
        switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
        case .OrderedSame, .OrderedDescending:
            nextController = (segue.destinationViewController as! UINavigationController).topViewController
        case .OrderedAscending:
            nextController = segue.destinationViewController
        }
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let row = indexPath.row
            var nextJson: JSON = JSON.null
            switch self.json.type {
            case .Array:
                nextJson = self.json[row]
            case .Dictionary where row < self.json.dictionaryValue.count:
                let key = self.json.dictionaryValue.keys.array[row]
                if let value = self.json.dictionary?[key] {
                    nextJson = value
                }
            default:
                print("")
            }
            (nextController as! ViewController).json = nextJson
            print(nextJson)
        }
    }
}
