//
//  BasicController.swift
//  perfectMbao
//
//  Created by Loic LE PENN on 26/04/2017.
//
//

import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectLogger

// Responsibility: call appropriate func, deal with request/response, exception handling

final class StoreController {
    
    var routes: [Route] {
        return [
            Route(method: .post,   uri: "/stores",          handler:createStore),
            Route(method: .get,    uri: "/stores",          handler: findAllStore),
            Route(method: .get,    uri: "/stores/{id}",     handler: findStoreById),
            Route(method: .delete, uri: "/stores/{id}",     handler: deleteStoreById),
            Route(method: .patch,    uri: "/stores/{id}",     handler: updateStoreById)
        ]
    }
    
    private func updateStoreById(request: HTTPRequest, response: HTTPResponse) {
        do {
            let id = try retrieveId(request: request)
            let json = try StoreAPI.update(id:id, withJSONRequest: request.postBodyString)
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed(status: .ok)
        } catch {
            LogFile.error("Store Controller generate error when update: \(error)")
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: errorStatus(error))
        }
    }
    
    private func deleteStoreById(request: HTTPRequest, response: HTTPResponse){
        do {
           let id = try retrieveId(request: request)
           let json = try StoreAPI.delete(id: id)
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed(status: .ok)
        } catch {
            LogFile.error("Store Controller generate error when delete: \(error)")
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: errorStatus(error))
        }
    }
    
    private func findStoreById(request: HTTPRequest, response: HTTPResponse){
        do {
           let id = try retrieveId(request: request)
           let json = try StoreAPI.find(id:id)
                response.setBody(string: json)
                    .setHeader(.contentType, value: "application/json")
                    .completed(status: .ok)
        } catch {
            LogFile.error("Store Controller generate error when find by id: \(error)")
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: errorStatus(error))
        }
    }
    
    private func findAllStore(request: HTTPRequest, response: HTTPResponse) {
        do {
            let limit : Int = Int(request.param(name: "limit") ?? "") ?? 0
            let offset : Int = Int(request.param(name: "offset") ?? "") ?? 0
            let json : String
            if limit == 0 && offset == 0 {
               json = try StoreAPI.all()
            } else {
               json = try StoreAPI.all(limit: limit, offset: offset)
            }
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed(status: .ok)
        } catch {
            LogFile.error("Store Controller generate error when find all: \(error)")
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: errorStatus(error))
        }
    }
    
    private func createStore(request: HTTPRequest, response: HTTPResponse) {
        do {
            let json = try StoreAPI.new(withJSONRequest: request.postBodyString)
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed(status: .created)
        } catch {
            LogFile.error("Store Controller generate error when create: \(error)")
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: errorStatus(error))
        }
    }
}

