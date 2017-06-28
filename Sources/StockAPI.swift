//
//  StockAPI.swift
//  perfectMbao
//
//  Created by Loic LE PENN on 04/05/2017.
//
//

import Foundation
import StORM
import PostgresStORM

class StockAPI {

    /**
        this function create new product and associate it with the stock of a store.
        To work this function need two things :
        first a valid storeid
        second a json body that at least contains a name for the product and the following stock informations :  quantity, priceht and vat
        - parameters:
            - storeid: a string represent a valid storeid
            - json: the json request body as a string
        - throws: APIError.notFound, APIError.missingRequireAttribut
     */
    static func new(storeid:String, json: String?) throws -> String {
        var product = Product()
        var stock = Stock()

        guard try StoreAPI.exist(id: storeid) else {
            throw APIError.notFound
        }

        guard let json = try json?.jsonDecode() as? [String:Any] else{
            throw APIError.missingRequireAttribut
        }

        let (productDict, stockDict) = try self.jsonToStock(json: json)

        product = try Product(dict: productDict)

        stock = try Stock(dict:stockDict)
        stock.refstore = storeid
        stock.refproduct = product.refproduct
        stock.creationdate = Date()

        try product.create()
        try stock.create()

        let dict = try stock.asDictionary().merge(other: product.asDictionary())

        return try dict.jsonEncodedString()
    }

    /**
     This function retrieve information about all store stock ( Product + stock). You can paginate your result.
     - parameters:
        - storeid : a valid store id in String format
        - limit : if you want to paginate you can use this parameter to limit the resultset size
        - offset : if you want to paginate you can use this parameter to ignore some result
     - throws: APIError.notFound
     */
    static func all(storeid:String, limit:Int = 0, offset:Int = 0) throws -> String {
        guard try StoreAPI.exist(id: storeid) else {
            throw APIError.notFound
        }

        let product = Product()
        let stock = Stock()

        var response = [String:Any]()

        response["total"] = try self.count(storeid: storeid)

        if limit > 0 {
             response["limit"] = limit
        }
        if offset > 0 {
             response["offset"] = offset
        }

        let cursor = StORMCursor(limit: limit, offset: offset)
        try stock.select(whereclause: "true", params: [], orderby: [], cursor: cursor)

        var array = [[String:Any]]()
        for row in stock.rows() {
            try product.get(row.refproduct)
            let dict = try row.asDictionary().merge(other: product.asDictionary())
            array.append(dict)
        }
        response["data"] = array
        return try response.jsonEncodedString()
    }

    /**
     This function retrieve information about a store stock ( Product + stock)
     - parameters:
        - storeid : a valid store id in String format
        - productid : a valid product id in String format
    - throws: APIError.notFound
     */
    static func find(storeid:String, productid:String) throws -> String {
        guard try StoreAPI.exist(id: storeid) else {
            throw APIError.notFound
        }

        let product = Product()
        let stock = Stock()
        
        try stock.select(whereclause: "refstore = $1 and refproduct = $2", params: [storeid, productid], orderby: [])
        try product.get(productid)
        
        guard product.refproduct == productid,
              stock.refstore == storeid,
            stock.refproduct == productid else {
                throw APIError.notFound
        }

        return try stock.asDictionary().merge(other: product.asDictionary()).jsonEncodedString()
    }

    /**
     this function provide an easy way to provide a delete on product and on stock at the same time.
        - parameters:
            - storeid : a valid store id in String format
            - productid : a valid product id in String format
        - throws: APIError.notFound
     */
    static func delete(storeid:String, productid:String) throws -> String {
        guard try StoreAPI.exist(id: storeid) else {
            throw APIError.notFound
        }

        let stock = Stock()
        let product = Product()
        
        try product.get(productid)
        try stock.select(whereclause: "refstore = $1 and refproduct = $2", params: [storeid,productid], orderby: [])
        
        guard product.refproduct == productid,
              stock.refstore == storeid,
            stock.refproduct == productid else {
                throw APIError.notFound
        }
        
        try stock.sqlRows("delete from \(stock.table()) where refstore = $1 and refproduct = $2", params: [storeid,productid])
        try product.delete()
        return try stock.asDictionary().merge(other: product.asDictionary()).jsonEncodedString()
    }


    /**
        This function is use in the case where you need to perform an update on the stock and/or on the product.
        - parameters:
            - storeid : a valid store id in String format
            - productid : a valid product id in String format
            - json : a json containing all the informations that should be updated
        - Warning:
            At the time i'm writing this function PERFECT FRAMEWORK don't perform any relational request. It's a bit complicated to perform the needed action so there is a lot a custom behaviour.
            Need to be improve and updated as soon as perfect release a better way to handle relation with PostgresSQL
     */
    static func update(storeid:String, productid:String, json: String?) throws -> String {
        guard try StoreAPI.exist(id: storeid) else {
            throw APIError.notFound
        }
        
        guard let json = json else {
            throw APIError.missingRequireAttribut
        }
        
        let jsonbody : [String:Any]
        
        do {
            guard let data = try json.jsonDecode() as? [String:Any] else {
                throw APIError.parsingError
            }
            jsonbody = data
        } catch {
            throw APIError.invalidBody
        }
        
        guard !jsonbody.isEmpty else {
            throw APIError.missingRequireAttribut
        }
        
        let product = Product(),
            stock = Stock()
        var productT = [(String,Any)]()

        var updateRequest = "update stock set"

        var requestupdated = false

        for (key,value) in jsonbody {
            switch (key,value) {

            case let ("product_name", value) where value is String:
                productT.append(("name",value))
            case let ("product_creationdate", value) where value is String:
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                if let date = formatter.date(from: String(describing: value)) {
                    productT.append(("creationdate",date))
                } else {
                    throw APIError.parsingError
                }
            case let ("product_picture", value) where value is String:
                productT.append(("picture",value))
            case let ("quantity",value) where value is Int:
                if let value = value as? Int{
                    updateRequest += " \(key) = \(value * 100)"
                    requestupdated = true
                }
            case let ("status",value) where value is String:
                updateRequest += " \(key) = '\(value)'"
                requestupdated = true
            case let ("priceht",value):
                if let value = value as? Double{
                    updateRequest += " \(key) = \(Int((value * 100).rounded()))"
                    requestupdated = true
                } else if let value = value as? Int {
                    updateRequest += " \(key) = \(value * 100)"
                    requestupdated = true
                } else {
                    throw APIError.parsingError
                }
            case let ("vat",value) :
                if let value = value as? Double {
                    updateRequest += " \(key) = \(Int((value * 100).rounded()))"
                    requestupdated = true
                } else if let value = value as? Int {
                    updateRequest += " \(key) = \(value * 100)"
                    requestupdated = true
                } else {
                    throw APIError.parsingError
                }
            default :
                throw APIError.unexpectedData
            }
            if requestupdated == true {
                updateRequest += ","
            }
            requestupdated = false
        }

        updateRequest += " lastupdate = '\(Date())' where refstore = $1 and refproduct = $2"
        try stock.sqlRows(updateRequest, params: [storeid,productid])
        if !productT.isEmpty {
            try product.update(data: productT, idName: "refproduct", idValue: productid)
        }
        var dict = try self.join(table1: stock, table2: product, commonRef: "refproduct", whereclause: "where stock.refstore = $1 and  stock.refproduct = $2", params: [storeid,productid])

        if let quantity = dict["quantity"] as? Int {
            dict["quantity"] = quantity / 100
        }

        if let vat = dict["vat"] as? Int {
            dict["vat"] = Double(vat) / 100
        }

        if let priceht = dict["priceht"] as? Int {
             dict["priceht"] = Double(priceht) / 100
        }

        return try dict.jsonEncodedString()
    }


    /**
     this function is useful in the case you search for the total of instance of a store in stock table with a given id
     - parameters:
        - storeid: the store id as String
     - throws: APIError.notFound
     */
    static func count(storeid:String) throws -> Int{
        let stock = Stock()
        if try StoreAPI.exist(id: storeid) {
            try stock.find(["refstore":storeid])
            return stock.rows().count
        } else {
            throw APIError.notFound
        }
    }

    /**
     Create a new stock and product in database from a json
     - parameters:
        - json:  a json dictionnary
     - throws: if you provide unexpected data in json or if there are a require attribut missing
     */
    static private func jsonToStock(json:[String:Any]) throws -> ([String:Any],[String:Any]) {

        var product = [String:Any]()
        var stock = [String:Any]()

        for (key,value) in json {
            switch key {
                case "product_name":
                    product["name"] = value
                case "product_picture":
                    product["picture"] = value
                case "quantity":
                    stock["quantity"] = value
                case "status":
                    stock["status"] = value
                case "priceht":
                    stock["priceht"] = value
                case "vat":
                    stock["vat"] = value
                default :
                    throw APIError.invalidBody
            }
        }
        guard product["name"] != nil,
              stock["quantity"] != nil,
              stock["vat"] != nil,
              stock["priceht"] != nil else {
                throw APIError.missingRequireAttribut
        }

        return (product,stock)
    }



    /**
        This function is a helper providing an easier way to play with jointure
        - parameters:
            - table1: table from where the join start
            - table2: the other table
            - commonRef: as this function goal is to stay simple i wonder that the table get the same name in the 2 tables
            - whereclause: A where clause write in SQL (ex: where table1.id = table2.customer)
            - params: if you need or want to provide sql parameter in whereclause for example
        - throws: if the data recover is not as expected ([String : Any])
        - version: 1.0
     */
    static private func join(table1:PostgresStORM, table2:PostgresStORM, commonRef:String, whereclause: String = "", params: [String]) throws -> Dictionary<String,Any> {
        var str = "select \(table1.table()).*, "

        var tmp = 0
        for col in table2.cols() {
            str += "\(table2.table()).\(col.0) as \(table2.table())_\(col.0)"
            tmp += 1
            if tmp < table2.cols().count {
                str += ", "
            } else {
                str += " "
            }
        }

        str +=  "from \(table1.table()) inner join \(table2.table()) on \(table1.table()).\(commonRef) = \(table2.table()).\(commonRef) "

        if !whereclause.isEmpty {
            str += "\(whereclause)"
        }
        let result = try table1.sqlRows(str, params: params)
        if let data = result.first?.data {
            return data
        } else {
            throw APIError.unexpectedData
        }
    }
}
