//
//  Map.swift
//  Offpeak
//
//  Created by ChjpCoj on 6/24/16.
//  Copyright © 2016 Weezi. All rights reserved.
//

import UIKit
import Foundation

public protocol MapContext {
    
}

public final class Map {
    
    public let mappingType: MappingType
    
    public internal(set) var JSONDictionary: [String : AnyObject] = [:]
    public internal(set) var isKeyPresent = false
    public var currentValue: AnyObject?
    public var context: MapContext?
    var currentKey: String?
    var keyIsNested = false
    
    let toObject: Bool
    
    /// Counter for failing cases of deserializing values to `let` properties.
    private var failedCount: Int = 0
    
    public init(mappingType: MappingType, JSONDictionary: [String : AnyObject], toObject: Bool = false, context: MapContext? = nil){
        
        self.mappingType = mappingType
        self.JSONDictionary = JSONDictionary
        self.toObject = toObject
        self.context = context
        
    }
    
    public subscript(key: String) -> Map {
        let nested = key.containsString(".")
        return self[key, nested: nested, ignoreNil: false]
    }
    
    public subscript(key: String, nested nested: Bool) -> Map{
        return self[key, nested: nested, ignoreNil: false]
    }
    
    public subscript(key: String, ignoreNil ignoreNil: Bool) -> Map {
        let nested = key.containsString(".")
        return self[key, nested: nested, ignoreNil: ignoreNil]
    }
    
    public subscript(key: String, nested nested: Bool, ignoreNil ignoreNil: Bool) -> Map {
        // save key and value associated to it
        currentKey = key
        keyIsNested = nested
        
        // check if a value exists for the current key
        // do this pre-check for performance reasons
        if nested == false {
            let object = JSONDictionary[key]
            let isNSNull = object is NSNull
            isKeyPresent = isNSNull ? true : object != nil
            currentValue = isNSNull ? nil : object
        } else {
            // break down the components of the key that are separated by .
            (isKeyPresent, currentValue) = valueFor(ArraySlice(key.componentsSeparatedByString(".")), dictionary: JSONDictionary)
        }
        
        // update isKeyPresent if ignoreNil is true
        if ignoreNil && currentValue == nil {
            isKeyPresent = false
        }
        
        return self
    }
    
    public func value<T>() -> T? {
        return currentValue as? T
    }
    
    public func valueOr<T>(@autoclosure defaultValue: () -> T) -> T {
        return value() ?? defaultValue()
    }
    
    public func valueOrFail<T>() -> T {
        if let value: T = value() {
            return value
        }else {
            failedCount += 1
            
            let pointer = UnsafeMutablePointer<T>.alloc(0)
            pointer.dealloc(0)
            return pointer.memory
        }
    }
    
    public var isValid: Bool {
        return failedCount == 0
    }
    
    private func valueFor(keyPathCompnents: ArraySlice<String>, dictionary: [String: AnyObject]) -> (Bool, AnyObject?) {
        if keyPathCompnents.isEmpty {
            return (false, nil)
        }
        
        if let keyPath = keyPathCompnents.first {
            let object = dictionary[keyPath]
            if object is NSNull {
                return (true, nil)
            }else if let dic = object as? [String : AnyObject] where keyPathCompnents.count > 1 {
                let tail = keyPathCompnents.dropFirst()
                return valueFor(tail, dictionary: dic)
            }else if let array = object as? [AnyObject] where keyPathCompnents.count > 1 {
                let tail = keyPathCompnents.dropFirst()
                return valueFor(tail, array: array)
            }else {
                return (object != nil, object)
            }
        }
        
        return (false, nil)
    }
    
    private func valueFor(keyPathComponents: ArraySlice<String>, array: [AnyObject]) -> (Bool, AnyObject?) {
        if keyPathComponents.isEmpty {
            return (false, nil)
        }
        
        if let keyPath = keyPathComponents.first,
            let index = Int(keyPath) where index >= 0 && index < array.count
        {
            let object = array[index]
            
            if object is NSNull {
                return (true, nil)
            } else if let array = object as? [AnyObject] where keyPathComponents.count > 1 {
                let tail = keyPathComponents.dropFirst()
                return valueFor(tail, array: array)
            }else if let dict = object as? [String : AnyObject] where keyPathComponents.count > 1 {
                let tail = keyPathComponents.dropFirst()
                return valueFor(tail, dictionary: dict)
            }else {
                return (true, object)
            }
        }
        
        return (false, nil)
    }
}
