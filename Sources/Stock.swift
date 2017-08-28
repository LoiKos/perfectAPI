
import Foundation
import StORM
import PostgresStORM

/**

 Stock model defining a Stock table in a postgres database
 this model conform to PostgresStORM, provide a custom setup function that instanciate the table in the database.
 
 this model contains all requires functions to work as to() and rows().
 
 In addition you get 2 utilities functions :
 asDictionary() -> that send you back a dictionnary based on your object
 toJSON() -> that send you a json representation of your object that can be useful for RestAPI
 
 and also a custom init that allow you to create an instance of the object from a dictionary.
 - Author: Created by Loic LE PENN on 04/05/2017.
 - Version: 1.0
 
 */
class Stock : PostgresStORM {
    
    var refstore : String = ""
    var refproduct : String = ""
    var quantity : Int = 0
    var creationdate : Date = Date()
    var lastupdate : Date? = nil
    var status : String = ""
    var priceht : Int = 0
    var vat : Int = 0
    
    override open func table() -> String {
        return "stock"
    }
    
    override func to(_ this: StORMRow) {
        refstore = this.data["refstore"] as? String ?? ""
        refproduct = this.data["refproduct"] as? String ?? ""
        quantity = this.data["quantity"] as? Int ?? 0
        creationdate = this.data["creationdate"] as? Date ?? Date()
        lastupdate = this.data["lastupdate"] as? Date ?? nil
        status = this.data["status"] as? String ?? ""
        priceht = this.data["priceht"] as? Int ?? 0
        vat = this.data["vat"] as? Int ?? 0
    }
    
    func rows() -> [Stock] {
        var rows = [Stock]()
        for value in self.results.rows {
            let row = Stock()
            row.to(value)
            rows.append(row)
        }
        return rows
    }

    func asDictionary() -> [String: Any] {
        return [
            "refstore": self.refstore,
            "refproduct": self.refproduct,
            "quantity": self.quantity/100,
            "vat": Double(self.vat)/100,
            "creationdate": self.creationdate.description,
            "lastupdate": self.lastupdate?.description ?? "",
            "status": self.status,
            "priceht": Double(self.priceht)/100
        ]
    }
    
    func toJSON() throws -> String {
        return try self.asDictionary().jsonEncodedString()
    }
    
    func setup() throws {
        let str = "create table if not exists stock ("
            + "refstore varchar(255) REFERENCES stores(refstore),"
            + "refproduct varchar(255) REFERENCES products(refproduct),"
            + "quantity integer,"
            + "creationdate varchar(255),"
            + "lastupdate varchar(255),"
            + "status varchar(255),"
            + "priceht integer,"
            + "vat integer,"
            + "constraint primaryKey PRIMARY KEY (refstore,refproduct) )"
        try self.setup(str)
    }
    
}

extension Stock {
    
    convenience init(dict : [String:Any]) throws {
        self.init()
        for (key,value) in dict {
            switch key {
            case "quantity":
                self.quantity = try toInt(value)
            case "status":
                self.status = try parseToString(value)
            case "vat":
                self.vat =  try toInt(value)
            case "priceht":
                self.priceht = try toInt(value)
            default :
                throw APIError.invalidBody
            }
        }
    }
}
