import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import StORM
import PostgreSQL
import PostgresStORM
import Foundation
import PerfectLogger
import PerfectRequestLogger


guard let db = ProcessInfo.processInfo.environment["DATABASE_DB"],
    let host = ProcessInfo.processInfo.environment["DATABASE_HOST"],
    let port =  ProcessInfo.processInfo.environment["DATABASE_PORT"] else {
        //throw APIError.databaseConnectionFailed
        print("failed connection to database")
        exit(0)
}

PostgresConnector.database = db
PostgresConnector.host = host
PostgresConnector.port = Int(port) ?? 32768
PostgresConnector.username = ProcessInfo.processInfo.environment["DATABASE_USER"] ?? ""
PostgresConnector.password = ProcessInfo.processInfo.environment["DATABASE_PASSWORD"] ?? ""

try checkDBConn()

try Store().setup()
try Product().setup()
try Stock().setup()




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
