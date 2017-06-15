//
//  ProductController.swift
//  perfectMbao
//
//  Created by Loic LE PENN on 02/05/2017.
//
//
import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectLogger

final class ProductController {
    
    /**
        class property routes contains all routes from Product controller
     */
    var routes : [Route] {
        return [
            Route(method: .post,    uri: "/products",       handler:createProduct),
            Route(method: .get,     uri: "/products/{id}",  handler: getProductById),
            Route(method: .get,     uri: "/products",       handler: findAll),
            Route(method: .delete,  uri: "/products/{id}",  handler: deleteProductById),
            Route(method: .put,     uri: "/products/{id}",  handler: updateProductById)
        ]
    }
    
    /**
        Update a product by Id
     */
    private func updateProductById(request: HTTPRequest, response: HTTPResponse) {
        do{
            let id = try retrieveId(request: request)
            let json = try ProductAPI.update(id:id, json: request.postBodyString)
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed(status: .ok)
        } catch {
            LogFile.error("Product Controller generate error when update: \(error)")
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: errorStatus(error))
        }
    }
    
    /**
       find all products that allow limit and offset parameters
     */
    private func findAll(request: HTTPRequest, response: HTTPResponse) {
        do{
            let limit : Int = Int(request.param(name: "limit") ?? "") ?? 0
            let offset : Int = Int(request.param(name: "offset") ?? "") ?? 0
            let json : String
            if limit == 0 && offset == 0 {
                json = try ProductAPI.all()
            } else {
                json = try ProductAPI.all(limit: limit, offset: offset)
            }
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed(status: .ok)
        } catch {
            LogFile.error("Product Controller generate error when find all: \(error)")
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: errorStatus(error))
        }
    }
    
    /**
        Create a new product by request body in JSON
     */
    private func createProduct(request: HTTPRequest, response: HTTPResponse) {
        do{
            let json = try ProductAPI.new(withJSONRequest: request.postBodyString)
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed(status: .created)
        } catch {
            LogFile.error("Product Controller generate error when create: \(error)")
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: errorStatus(error))
        }
    }
    
    /**
        Retrieve a product by Id
     */
    private func getProductById(request: HTTPRequest, response: HTTPResponse) {
        do{
            let id = try retrieveId(request: request)
            let json = try ProductAPI.find(id:id)
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed(status: .ok)
        } catch {
            LogFile.error("Product Controller generate error when find by id: \(error)")
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: errorStatus(error))
        }
    }
    
    /**
        Delete a product by Id
     */
    private func deleteProductById(request: HTTPRequest, response: HTTPResponse) {
        do{
            let id = try retrieveId(request: request)
            let json = try ProductAPI.delete(id:id)
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed(status: .ok)
        } catch {
            LogFile.error("Product Controller generate error when delete: \(error)")
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: errorStatus(error))
        }
    }
}
