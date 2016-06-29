//
//  Mappable.swift
//  Offpeak
//
//  Created by ChjpCoj on 6/24/16.
//  Copyright © 2016 Weezi. All rights reserved.
//

import UIKit

public protocol Mappable {
    
    init?(_ map: Map)
    
    mutating func mapping(map: Map)
    
    static func objectForMapping(map: Map) -> Mappable?
}

public extension Mappable {
    
    public static func objectForMapping(map: Map) -> Mappable? {
        return nil
    }
    
    public init?(JSONString: String) {
        if let obj: Self = Mapper().map(JSONString) {
            self = obj
        }else {
            return nil
        }
    }
    
    public init?(JSON: [String: AnyObject]) {
        if let obj: Self = Mapper().map(JSON) {
            self = obj
        }else {
            return nil
        }
    }
    
    public func toJSON() -> [String : AnyObject] {
        return Mapper().toJSON(self)
    }
    
    public func toJSONString(prettyPrint: Bool = false) -> String? {
        return Mapper().toJSONString(self, prettyPrint: prettyPrint)
    }
}

public extension Array where Element: Mappable {
    
    public init?(JSONString: String) {
        if let obj: [Element] = Mapper().mapArray(JSONString) {
            self = obj
        }else {
            return nil
        }
    }
    
    public init?(JSONArray: [[String : AnyObject]]) {
        if let obj: [Element] = Mapper().mapArray(JSONArray) {
            self = obj
        }else {
            return nil
        }
    }
    
    public func toJSON() -> [[String : AnyObject]] {
        return Mapper().toJSONArray(self)
    }
    
    public func toJSONString(prettyPrint: Bool = false) -> String? {
        return Mapper().toJSONString(self, prettyPrint: prettyPrint)
    }
}

public extension Set where Element : Mappable {
    
    public init?(JSONString: String) {
        if let obj: Set<Element> = Mapper().mapSet(JSONString) {
            self = obj
        }else{
            return nil
        }
    }
    
    public init?(JSONArray: [[String : AnyObject]]) {
        if let obj: Set<Element> = Mapper().mapSet(JSONArray) {
            self = obj
        }else{
            return nil
        }
    }
    
    public func toJSON() -> [[String : AnyObject]] {
        return Mapper().toJSONSet(self)
    }
    
    public func toJSONString(prettyPrint: Bool = false) -> String? {
        return Mapper().toJSONString(self, prettyPrint: prettyPrint)
    }
}





























