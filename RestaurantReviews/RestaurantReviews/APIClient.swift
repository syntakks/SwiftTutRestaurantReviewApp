//
//  APIClient.swift
//  RestaurantReviews
//
//  Created by Stephen Wall on 2/13/20.
//  Copyright © 2020 syntaks.io. All rights reserved.
//

import Foundation

enum APIError: Error {
    case requestFailed
    case jsonConversionFailure
    case invalidData
    case responseUnsuccessful
    case jsonParsingFailure
    
    var localizedDescription: String {
        switch self {
        case .requestFailed: return "Request Failed"
        case .invalidData: return "Invalid Data"
        case .responseUnsuccessful: return "Response Unsuccessful"
        case .jsonParsingFailure: return "JSON Parsing Failure"
        case .jsonConversionFailure: return "JSON Conversion Failure"
        }
    }
}

protocol APIClient {
    var session: URLSession { get }
    // Singular Object
    func fetch<T: JSONDecodable>(
        with request: URLRequest,
        parse: @escaping (JSON) -> T?,
        completion: @escaping (Result<T, APIError>) -> Void)
    // Array of objects
    func fetch<T: JSONDecodable>(
        with request: URLRequest,
        parse: @escaping (JSON) -> [T],
        completion: @escaping (Result<[T], APIError>) -> Void)
}

extension APIClient {
    typealias JSON = [String: AnyObject]
    typealias JSONTaskCompletionHandler = (JSON?, APIError?) -> Void
    
    func jsonTask(with request: URLRequest, completionHandler completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { data, response, error in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, .requestFailed)
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                        completion(json, nil)
                    } catch {
                        completion(nil, .jsonConversionFailure)
                    }
                } else {
                    completion(nil, .invalidData)
                }
            } else {
                completion(nil, .responseUnsuccessful)
            }
        }
        
        return task
    }
    
    func fetch<T: JSONDecodable>(
        with request: URLRequest,
        parse: @escaping (JSON) -> T?,
        completion: @escaping (Result<T, APIError>) -> Void) {
        
        let task = jsonTask(with: request) { json, error in
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(Result.failure(error))
                    } else {
                        completion(Result.failure(.invalidData))
                    }
                    return
                }
                
                print(json)
                
                if let value = parse(json) {
                    completion(Result.success(value))
                } else {
                    completion(Result.failure(.jsonParsingFailure))
                }
            }
        }
        task.resume()
    }
    
    func fetch<T: JSONDecodable>(
        with request: URLRequest,
        parse: @escaping (JSON) -> [T],
        completion: @escaping (Result<[T], APIError>) -> Void) {
        
        let task = jsonTask(with: request) { json, error in
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(Result.failure(error))
                    } else {
                        completion(Result.failure(.invalidData))
                    }
                    return
                }
                
                print(json)
                
                let value = parse(json)
                
                if !value.isEmpty {
                    completion(Result.success(value))
                } else {
                    completion(Result.failure(.jsonParsingFailure))
                }
            }
        }
        task.resume()
    }
    
    
}
