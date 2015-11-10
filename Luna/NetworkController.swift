//
//  NetworkController.swift
//  Luna
//
//  Created by Andrew Shepard on 1/19/15.
//  Copyright (c) 2015 Andrew Shepard. All rights reserved.
//

import Foundation

typealias TaskResult = (result: Result<NSData>) -> Void

class NetworkController {
    
    let configuration: NSURLSessionConfiguration
    
    init(configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()) {
        self.configuration = configuration
    }
    
    private class SessionDelegate: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate {
        
        @objc func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
            completionHandler(.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
        }
        
        @objc func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
            completionHandler(request)
        }
    }
    
    /**
    Creates an NSURLSessionTask for the request
    
    - parameter request: A reqeust object to return a task for
    - parameter completion:
    
    - returns: An NSURLSessionTask associated with the request
    */
    
    func task(request: NSURLRequest, result: TaskResult) -> NSURLSessionTask {
        
        // handle the task completion job on the main thread
        let finished: TaskResult = {(taskResult) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                result(result: taskResult)
            })
        }
        
        let sessionDelegate = SessionDelegate()
        let session = NSURLSession(configuration: configuration, delegate: sessionDelegate, delegateQueue: NSOperationQueue.mainQueue())
        
        // return a basic NSURLSession for the request, with basic error handling
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
            guard let data = data else {
                guard let err = err else {
                    return finished(result: .Failure(.NoData))
                }
                
                return finished(result: .Failure(.Other(err)))
            }
            
            guard let response = response as? NSHTTPURLResponse else {
                return finished(result: .Failure(.BadResponse))
            }
            
            switch response.statusCode {
                case 200...204:
                    finished(result: success(data))
                default:
                    let reason = Reason.NoSuccessStatusCode(statusCode: response.statusCode)
                    finished(result: .Failure(reason))
            }
        })
        
        return task;
    }
}
