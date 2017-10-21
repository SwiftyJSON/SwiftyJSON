//  ViewController.swift
//
//  Copyright (c) 2014 - 2016 Pinglin Tang
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

	override func viewDidLoad() {
		title = "SwiftyJSON(\(json.type))"
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.json.type {
        case .array, .dictionary:
            return self.json.count
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JSONCell", for: indexPath) as UITableViewCell

        let row = indexPath.row

        switch self.json.type {
        case .array:
            cell.textLabel?.text = "\(row)"
            cell.detailTextLabel?.text = self.json.arrayValue.description
        case .dictionary:
            let key: Any = Array(self.json.dictionaryValue.keys)[row]
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {

        var nextController: UIViewController?
        nextController = segue.destination

        if let indexPath = self.tableView.indexPathForSelectedRow {
            let row = indexPath.row
            var nextJson: JSON = JSON.null
            switch self.json.type {
            case .array:
                nextJson = self.json[row]
            case .dictionary where row < self.json.dictionaryValue.count:
                let key = Array(self.json.dictionaryValue.keys)[row]
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
