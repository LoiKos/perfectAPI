//
//  Helper.swift
//  perfectMbao
//
//  Created by Loic LE PENN on 26/04/2017.
//
//

import Foundation
import PerfectHTTP

// This file is dedicated to valuable utility function for the API

/**
    Use this function to try parsing an object of Any type to String
    - parameter value: Any object of type Any that could be convert to string
    - Throws : APIError.parsingError if parsing failed
 */
func parseToString(_ value:Any) throws -> String {
    guard let value = value as? String else {
        throw APIError.parsingError
    }
    return value
}

/**
    this function is an helper to convert a value to any to Int.
    It's a function specific that should only be use in the context of Stock.
 */
func toInt(_ value:Any) throws -> Int {
    if let value = value as? Double {
        return Int((value * 100).rounded())
    } else if let value = value as? Int {
        return value * 100
    } else {
        throw APIError.unexpectedData
    }
}

/**
    a function to return error. As we create an api error enum we have this functionality to handle Error type.
    It use in response case when you catch an error.
 */
func errorStatus(_ error:Error) -> HTTPResponseStatus {
    if let error = error as? APIError {
        return error.status
    } else {
        return HTTPResponseStatus.internalServerError
    }
}

/**
    this function is used by controllers to retrieve an id from url variables.
 */
func retrieveId(request: HTTPRequest, idname: String = "id") throws -> String {
    if let id = request.urlVariables[idname] {
        return id
    } else {
        throw APIError.missingRequireAttribut
    }
}

extension Dictionary {
    
    /** 
        this helper provide a way to merge to dictionary in one.
     */
    func merge(other:Dictionary<Key,Value>, conflictIdentifier: String = "products") throws -> Dictionary<Key, Value> {
        var map = Dictionary<Key,Value>()
        
        for (k,v) in self {
            map[k] = v
         }
        
        for (k,v) in other {
            if let key = "\(conflictIdentifier)_\(k)" as? Key {
                    map[key] = v
            } else {
                throw APIError.parsingError
            }
        }
        
        return map
    }
}

