//
//  SwiftyMapper.swift
//  SwiftyJSON
//
//  Created by Edgard Hernandez on 11/19/14.
//
//

import Foundation


/* Swifty Mapper will map a JSONValue Object that represents a Class with Properties to Swift Class but it has to Inherit from NSObject */
public class SwiftyMapper {
    
     public init() {
        
    }
    
     public func MapJsonToObj<T where T: NSObject>(jsonData: JSON) -> [T] {
        
        var list = [T]()
    
        for mainArray in jsonData.array! {
            
            if let dataObject = mainArray.object as? [String : AnyObject] {// In my original code I had no need to this Casting.
                
                var newobj = T()
                for(key,value) in dataObject { //Extract Data per Obj in the Array of Objects of JsonValue, if its only one object only one object will be extracted.
                   
                    //The Name of Property has to be exactly the same as the Name of the Element in the Json, Case Sensitive
                    println("\n\nKey: '\(key)' ... Value: \(value)")
                    var valueObject: AnyObject = value 
                    newobj.setValue(valueObject, forKey: key)
                    println("Obj with New Setted Property '\(key)': \(newobj.valueForKey(key)!)")
                    
                    //FIX: Still have issues with array inside an Array
                    
                }
                
                list.append(newobj)
                
            }//DataObject loop through Properties
        }//Main loop
        
        println("List Count: \(list.count)")
        return list
        
    }
    
    
    
    
}
