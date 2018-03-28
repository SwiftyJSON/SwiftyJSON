//
//  SwiftyJSON+Optionals.swift
//  SwiftyJSON
//
//  Created by Alessandro "Sandro" Calzavara on 27/01/2017.
//
//

import Foundation

// MARK: Setters with optional

extension JSON {
    
    /// Set String value only if not nil
    public mutating func optionalSetter(key: String, value: String?) {
        
        guard let value = value else {
            return
        }
        
        self[key].string = value
    }
    
    /// Set NSNumber value only if not nil
    public mutating func optionalSetter(key: String, value: NSNumber?) {
        
        guard let value = value else {
            return
        }
        
        self[key].number = value
    }
    
    /// Set Int value only if not nil
    public mutating func optionalSetter(key: String, value: Int?) {
        
        guard let value = value else {
            return
        }
        
        self[key].int = value
    }
    
    /// Set Float value only if not nil
    public mutating func optionalSetter(key: String, value: Float?) {
        
        guard let value = value else {
            return
        }
        
        self[key].float = value
    }
    
    /// Set Double value only if not nil
    public mutating func optionalSetter(key: String, value: Double?) {
        
        guard let value = value else {
            return
        }
        
        self[key].double = value
    }
    
    /// Set Bool value only if not nil
    public mutating func optionalSetter(key: String, value: Bool?) {
        
        guard let value = value else {
            return
        }
        
        self[key].bool = value
    }

}
