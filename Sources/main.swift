import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import StORM
import PostgreSQL
import PostgresStORM
import Foundation
import PerfectLogger
import PerfectRequestLogger

if let  db = ProcessInfo.processInfo.environment["DATABASE_DB"],
  let username = ProcessInfo.processInfo.environment["DATABASE_USER"],
  let host = ProcessInfo.processInfo.environment["DATABASE_HOST"],
  let port =  ProcessInfo.processInfo.environment["DATABASE_PORT"],
  let password = ProcessInfo.processInfo.environment["DATABASE_PASSWORD"] {
      PostgresConnector.database = db
      PostgresConnector.username = username
      PostgresConnector.host = host
      PostgresConnector.port = Int(port) ?? 32768
      PostgresConnector.password = password
} else {
       throw APIError.databaseConnectionFailed
}

do {

    let connection = PGConnection()

    let stringConnection = "host=\(PostgresConnector.host) port=\(PostgresConnector.port) dbname=\(PostgresConnector.database) user=\(PostgresConnector.username) password=\(PostgresConnector.password)"

    if connection.connectdb(stringConnection) == .bad {
        throw APIError.databaseConnectionFailed
    }

    defer {
        connection.close()
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
