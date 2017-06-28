//
//  ProductAPI.swift
//  perfectMbao
//
//  Created by Loic LE PENN on 02/05/2017.
//
//

import Foundation
import StORM

class ProductAPI {
    
    /**
     Create a new product in database with json body
    */
    static func new(withJSONRequest json: String?) throws -> String  {
        guard let json = json,
        let dict = try json.jsonDecode() as? [String: Any],
        dict["name"] != nil else {
            throw APIError.missingRequireAttribut
        }
        let product = try Product(dict:dict)
        try product.create()
        return try product.toJSON()
    }
    
    /**
     Find a product by id
     */
    static func find(id: String) throws -> String {
        let obj = Product()
        try obj.get(id)
        if obj.refproduct == id {
            return try obj.toJSON()
        } else {
            throw APIError.notFound
        }
    }
    
    /**
     Delete a product by id
     */
    static func delete(id: String) throws -> String {
        let obj = Product()
        try obj.get(id)
        if obj.refproduct == id {
            try obj.delete()
            return try obj.toJSON()
        } else {
            throw APIError.notFound
        }
    }
    
    /**
     Update a product by id with json body
    */
    static func update(id:String, json: String?) throws -> String {
        let obj = Product()
        try obj.get(id)
        if obj.refproduct == id {
            guard let json = json,
                let dict = try json.jsonDecode() as? [String: Any] else {
                    throw APIError.parsingError
            }
            for (key,value) in dict {
                switch(key){
                    case "name":
                        if let value = value as? String {
                            obj.name = value
                        } else {
                            throw APIError.unexpectedData
                        }
                    case "picture":
                        if let value = value as? String {
                            obj.picture = value
                        } else {
                            throw APIError.unexpectedData
                        }
                    default:
                        throw APIError.invalidBody
                }
            }
            return try obj.toJSON()
        } else {
            throw APIError.notFound
        }
    }
    
    /**
     Retrieve all products from database
     */
    static func all() throws -> String {
        let products = Product()
        try products.findAll()
        var response = [String:Any]()
        response["total"] = products.rows().count
        var data = [[String:Any]]()
        products.rows().forEach({ row in
           data.append(row.asDictionary())
        })
        response["data"] = data
        return try response.jsonEncodedString()
    }
    
    /**
     Retrieve all product from database using limit and offset parameters
     */
    static func all(limit:Int = 0, offset:Int = 0) throws  -> String {
        let products = Product()
        var response = [String:Any]()
        response["total"] = try self.count(products: products)
        if limit > 0 {
            response["limit"] = limit
        }
        if offset > 0 {
            response["offset"] = offset
        }
        let cursor = StORMCursor(limit: limit, offset: offset)
        try products.select(whereclause: "true", params: [], orderby: [], cursor: cursor)
        var data = [Any]()
        for row in products.rows(){
            data.append(row.asDictionary())
        }
        response["data"] = data
        return try response.jsonEncodedString()
    }
    
    /**
     Count products in current table products
     */
    static func count(products:Product) throws -> Int {
        let count = try products.sqlRows("select count(*) from \(products.table())", params: [])
        if let response = count.first?.data["count"] as? Int {
            return response
        } else {
            throw APIError.unexpectedData
        }
    }
    
}
