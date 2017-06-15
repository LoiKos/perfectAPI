//
//  Product.swift
//  perfectMbao
//
//  Created by Loic LE PENN on 02/05/2017.
//
//

import StORM
import PostgresStORM
import Foundation


/**
 
 Product model defining a Product table in a postgres database
 this model conform to PostgresStORM.
 
 this model contains all requires functions to work as for example to() and rows().
 
 In addition you get 2 utilities functions :
 asDictionary() -> that send you back a dictionnary based on your object
 toJSON() -> that send you a json representation of your object that can be useful for RestAPI
 
 and also a custom init that allow you to create an instance of the object from a dictionary.
 - Author: Created by Loic LE PENN on 04/05/2017.
 - Version: 1.0
 
 */
class Product : PostgresStORM {
    
    var refproduct : String = Reference.sharedInstance.generateRef()
    var name : String = ""
    var picture : String = ""
    var creationdate : Date = Date()
    
    override open func table() -> String {
        return "products"
    }
    
    override func to(_ this: StORMRow) {
        refproduct = this.data["refproduct"] as? String ?? ""
        name = this.data["name"] as? String ?? ""
        picture = this.data["picture"] as? String ?? ""
        creationdate = this.data["creationdate"] as? Date ?? Date()
    }
    
    func rows() -> [Product] {
        var rows = [Product]()
        for i in 0 ..< self.results.rows.count {
            let row = Product()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func asDictionary() -> [String:Any] {
        return [
            "refproduct": self.refproduct,
            "name": self.name,
            "picture": self.picture,
            "creationdate": self.creationdate.description
        ]
    }
    
    func toJSON() throws -> String {
        return try self.asDictionary().jsonEncodedString()
    }
}

extension Product {

    convenience init(dict:[String:Any]) throws {
        self.init()
        for (key,value) in dict {
            switch key {
                case "name":
                    self.name = try parseToString(value)
                case "picture":
                    self.picture = try parseToString(value)
                case "creationdate":
                    if let date = value as? Date {
                        self.creationdate = date
                    } else {
                        throw APIError.parsingError
                    }
                default :
                    throw APIError.invalidBody
            }
        }
    }
}
