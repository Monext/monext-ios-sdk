//
//  NetworkError.swift
//  Monext
//
//  Created by SDK Mobile on 30/04/2025.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case encodingError(Error)
    case decodingError(Error)
    case badRequest
    case unauthorized
    case paymentRequired
    case forbidden
    case notFound
    case requestEntityTooLarge
    case unprocessableEntity
    case http(httpResponse: HTTPURLResponse, data: Data)
    case network(URLError)
    case unknown(Error?)
    
    static func from(statusCode: Int, data: Data) -> NetworkError {
        switch statusCode {
        case 400: return .badRequest
        case 401: return .unauthorized
        case 402: return .paymentRequired
        case 403: return .forbidden
        case 404: return .notFound
        case 413: return .requestEntityTooLarge
        case 422: return .unprocessableEntity
        default: return .http(httpResponse: HTTPURLResponse(), data: data)
        }
    }
}
 
