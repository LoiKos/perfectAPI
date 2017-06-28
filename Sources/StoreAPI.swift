//
//  storeAPI.swift
//  perfectMbao
//
//  Created by Loic LE PENN on 26/04/2017.
//
//

import Foundation
import StORM
// Responsibility: Convert to/from JSON, interact w/ Store class

class StoreAPI {
    
    /**
        Create a new store from json body String
     */
    static func new(withJSONRequest json: String?) throws -> String {
        guard let json = json,
            let dict = try json.jsonDecode() as? [String: Any],
            dict["name"] != nil else {
                throw APIError.missingRequireAttribut
        }
        
        let store = try Store(dict:dict)
        try store.create()
        return try store.toJSON()
    }
    
    /**
        Update a store from id from json body that contains all the properties to update
     */
    static func update(id:String, withJSONRequest json: String?) throws -> String {
        guard let json = json,
            let dict = try json.jsonDecode() as? [String: Any] else {
            throw APIError.parsingError
        }
        var tuples = [(String,Any)]()
        for (key,value) in dict {
            tuples.append((key,value))
        }
        let store = Store()
        try store.get(id)
        guard store.refstore == id else {
            throw APIError.notFound
        }
        try store.update(data: tuples, idName: "refstore", idValue: id)
        return try store.toJSON()
    }

    /**
        Find all store in the table
     */
    static func all() throws -> String {
        let stores = Store()
        try stores.findAll()
        var response = [String:Any]()
        let rows = stores.rows()
        response["total"] = rows.count
        response["data"] = self.storesToDictionary(rows)
        return try response.jsonEncodedString()
    }
    
    /**
     Find all store in the table using offset and limit parameters to offer pagination
     */
    static func all(limit:Int = 0, offset:Int = 0) throws -> String {
        let stores = Store()
        let cursor = StORMCursor(limit: limit, offset: offset)
        try stores.select(whereclause: "true", params: [], orderby: [], cursor: cursor)
        var response = [String:Any]()
        let rows = stores.rows()
        response["total"] = try self.count(stores)
        response["limit"] = limit
        response["offset"] = offset
        response["data"] = self.storesToDictionary(rows)
        return try response.jsonEncodedString()
    }
    
    /**
     Find a store by id
     */
    static func find(id: String) throws -> String {
       let store = Store()
       try store.get(id)
       if store.refstore == id {
            return try store.toJSON()
        } else {
            throw APIError.notFound
        }
    }
    
    /**
     Delete a store by id
     */
    static func delete(id: String) throws -> String {
        let store = Store()
        try store.get(id)
        if store.refstore == id {
            try store.delete()
            return try store.toJSON()
        } else {
            throw APIError.notFound
        }
    }
    
    /**
     Convert an array of store to an array of dictionary
     */
    static func storesToDictionary(_ stores: [Store]) -> [[String: Any]] {
        var storesJson: [[String: Any]] = []
        for row in stores {
            storesJson.append(row.asDictionary())
        }
        return storesJson
    }
    
    /**
     Count all the instance of store in the table
     */
    static func count(_ stores:Store) throws -> Int {
        let count = try stores.sqlRows("select count(*) from \(stores.table())", params: [])
        if let response = count.first?.data["count"] as? Int {
            return response
        } else {
            throw APIError.unexpectedData
        }
    }
    
    /**
     Check if an store exist by checking is id
     */
    static func exist(id:String) throws -> Bool {
        let store = Store()
        try store.get(id)
        return store.refstore == id ? true : false
    }
}

