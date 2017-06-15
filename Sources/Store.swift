import StORM
import PostgresStORM

/**
 
 Store model defining a Store table in a postgres database
 this model conform to PostgresStORM.
 
 this model contains all requires functions to work as to() and rows().
 
 In addition you get 2 utilities functions :
 asDictionary() -> that send you back a dictionnary based on your object
 toJSON() -> that send you a json representation of your object that can be useful for RestAPI
 
 and also a custom init that allow you to create an instance of the object from a dictionary.
 - Author: Created by Loic LE PENN on 04/05/2017.
 - Version: 1.0
 
 */
class Store : PostgresStORM {
    
    var refstore : String = Reference.sharedInstance.generateRef()
    var picture : String = ""
    var name : String = ""
    var vat : Int = 0
    var currency : String = ""
    var merchantkey : String = ""
    
    override open func table() -> String {
        return "stores"
    }
    
    override func to(_ this: StORMRow) {
        refstore = this.data["refstore"] as? String ?? ""
        picture = this.data["picture"] as? String ?? ""
        name = this.data["name"] as? String ?? ""
        vat = this.data["vat"] as? Int ?? 0
        currency = this.data["currency"] as? String ?? ""
        merchantkey = this.data["merchantkey"] as? String ?? ""
    }
    
    func rows() -> [Store] {
        var rows = [Store]()
        for i in 0 ..< self.results.rows.count {
            let row = Store()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func asDictionary() -> [String: Any] {
        
        let vatDouble : Double
        if self.vat > 100 {
            vatDouble = Double(self.vat)/100
        } else {
            vatDouble = Double(self.vat)
        }
        
        return [
            "refstore": self.refstore,
            "picture": self.picture,
            "name": self.name,
            "vat": vatDouble,
            "currency": self.currency,
            "merchantkey": self.merchantkey
        ]
    }
    
    func toJSON() throws -> String {
        return try self.asDictionary().jsonEncodedString()
    }
}


/**
    Store extension to add new init
 */
extension Store {

    convenience init(dict:[String:Any]) throws {
        self.init()
        
        for (key,value) in dict {
            switch key {
            case "name":
                self.name = try parseToString(value)
            case "picture":
                self.picture = try parseToString(value)
            case "vat":
                if let value = value as? Int,
                    value > 0 && value < 100 {
                    self.vat = value
                } else if let value = value as? Double,
                    value > 0 && value < 100 {
                    let temp_value = value * 100
                    self.vat = Int(temp_value.rounded())
                } else {
                    throw APIError.invalidVat
                }
            case "currency":
                self.currency = try parseToString(value)
            case "merchantkey" :
                self.merchantkey = try parseToString(value)
            default :
                throw APIError.invalidBody
            }
        }
    }
}




