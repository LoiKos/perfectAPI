//
//  APIError.swift
//  perfectMbao
//
//  Created by Loic LE PENN on 26/04/2017.
//
//

import Foundation
import PerfectHTTP


/**
    APIError
    Handle error generate by the API
    A status variable is use to get an HTTPStatus link to an APIError
 */
enum APIError : Error {
    case missingRequireAttribut
    case parsingError
    case invalidBody
    case invalidVat
    case notFound
    case unexpectedData
    case databaseConnectionFailed
    
    
    var status : HTTPResponseStatus {
        switch self {
        case .invalidBody,.missingRequireAttribut,.invalidVat:
            return HTTPResponseStatus.badRequest
        case  .notFound:
            return HTTPResponseStatus.notFound
        default:
            return HTTPResponseStatus.internalServerError
        }
    }
}
