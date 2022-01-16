//
//  Future+URLSession.swift
//  
//
//  Created by Asiel Cabrera Gonzalez on 1/16/22.
//

import Foundation

extension URLSession {
    
    func request(url: URL) -> Future<Data, Error> {
        // We'll start by constructing a Promise, that will later be
        // returned as a Future:
        let promise = Promise<Data, Error>()
        
        // Perform a data task, just like we normally would:
        let task = dataTask(with: url) { data, _, error in
            // Reject or resolve the promise, depending on the result:
            if let error = error {
                promise.fail(error: error)
            } else {
                promise.succeed(value: data ?? Data())
            }
        }
        
        task.resume()
        return promise.future
    }
    
    func request(urlRequest: URLRequest) -> Future<Data, Error> {
        // We'll start by constructing a Promise, that will later be
        // returned as a Future:
        let promise = Promise<Data, Error>()
        
        // Perform a data task, just like we normally would:
        let task = dataTask(with: urlRequest) { data, _, error in
            // Reject or resolve the promise, depending on the result:
            if let error = error {
                promise.fail(error: error)
            } else {
                promise.succeed(value: data ?? Data())
            }
        }

        task.resume()
        return promise.future
    }
}

