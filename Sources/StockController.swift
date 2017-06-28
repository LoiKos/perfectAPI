//
//  StockController.swift
//  perfectMbao
//
//  Created by Loic LE PENN on 04/05/2017.
//
//

import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectLogger

// Responsibility: call appropriate func, deal with request/response, exception handling

final class StockController {
    let baseUri = "/stores/{storeid}"
    
    var routes: [Route] {
        return [
            Route(method: .post,   uri: "\(baseUri)/products",                 handler: createProductInStock),
            Route(method: .get,    uri: "\(baseUri)/products",                 handler: getProductsInStock),
            Route(method: .get,    uri: "\(baseUri)/products/{productid}",     handler: getProductInStockById),
            Route(method: .delete, uri: "\(baseUri)/products/{productid}",     handler: deleteProductInStockById),
            Route(method: .custom("PATCH"),    uri: "\(baseUri)/products/{productid}",     handler: updateProductInStockById)
        ]
    }
    
    /**
        Create a new product and add it to stock
     */
    private func createProductInStock(request: HTTPRequest, response: HTTPResponse){
        do{
            let id = try retrieveId(request: request, idname: "storeid")
            let json = try StockAPI.new(storeid: id, json: request.postBodyString)
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed(status: .created)
        } catch {
            LogFile.error("Stock Controller generate error when create: \(error)")
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: errorStatus(error))
        }
    }
    
    /**
        Find all products in stock for a store ... you can use pagination with limit and offset parameters
     */
    private func getProductsInStock(request: HTTPRequest, response: HTTPResponse){
        do{
            let id = try retrieveId(request: request, idname: "storeid")
            let limit : Int = Int(request.param(name: "limit") ?? "") ?? 0
            let offset : Int = Int(request.param(name: "offset") ?? "") ?? 0
            let json = try StockAPI.all(storeid: id, limit: limit, offset: offset)
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed(status: .ok)
        } catch {
            LogFile.error("Stock Controller generate error when find all: \(error)")
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: errorStatus(error))
        }

    }
    
    /**
     Find a product from a store stock
     */
    private func getProductInStockById(request: HTTPRequest, response: HTTPResponse){
        do{
            let storeId = try retrieveId(request: request, idname: "storeid")
            let productId = try retrieveId(request: request, idname: "productid")
            let json = try StockAPI.find(storeid: storeId, productid: productId)
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed(status: .ok)
        } catch {
            LogFile.error("Stock Controller generate error when find by id: \(error)")
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: errorStatus(error))
        }
    }
    
    /**
     Delete a product from a store stock
     */
    private func deleteProductInStockById(request: HTTPRequest, response: HTTPResponse){
        do{
            let storeId = try retrieveId(request: request, idname: "storeid")
            let productId = try retrieveId(request: request, idname: "productid")
            let json = try StockAPI.delete(storeid: storeId, productid: productId)
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed(status: .ok)
        } catch {
            LogFile.error("Stock Controller generate error  when delete: \(error)")
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: errorStatus(error))
        }
    }
    
    /**
        Update a product from a store stock
     */
    private func updateProductInStockById(request: HTTPRequest, response: HTTPResponse){
        do{
            let storeId = try retrieveId(request: request, idname: "storeid")
            let productId = try retrieveId(request: request, idname: "productid")
            let json = try StockAPI.update(storeid: storeId, productid: productId, json: request.postBodyString)
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed(status: .ok)
        } catch {
            LogFile.error("Stock Controller generate error when update: \(error)")
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: errorStatus(error))
        }
    }
    
}
