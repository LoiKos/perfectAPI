import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import StORM
import PostgreSQL
import PostgresStORM
import Foundation
import PerfectLogger
import PerfectRequestLogger

PostgresConnector.database = "MbaoDB"
PostgresConnector.username = "Supervisor"
PostgresConnector.host = "127.0.0.1"
PostgresConnector.port = 32773
PostgresConnector.password = "1DFSQ894843NKF9F8SND9D"

do {
    
    let connection = PGConnection()
    
    defer {
        connection.close()
    }
    
    connection.connectdb("host=\(PostgresConnector.host) dbname=\(PostgresConnector.database) port=\(PostgresConnector.port) password= \(PostgresConnector.password) username=\(PostgresConnector.username)")
    if connection.status() == .bad {
        throw APIError.databaseConnectionFailed
    }

    try Store().setup()
    try Product().setup()
    try Stock().setup()
} catch {
    print(LogFile.error("impossible to connect to database : \(error)"))
}

let httplogger = RequestLogger()



let server = HTTPServer()
server.serverPort = 8080

server.setRequestFilters([(httplogger, .high)])
server.setResponseFilters([(httplogger, .low)])

var routes = Routes(baseUri:"/api/v1")

routes.add( StoreController().routes )
routes.add( ProductController().routes )
routes.add( StockController().routes )

server.addRoutes( routes )

do {
    try server.start()
} catch PerfectError.networkError(let err,let msg) {
    LogFile.critical("Network error thrown: \(err) \(msg)")
}



