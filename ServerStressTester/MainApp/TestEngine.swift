//
//  TestEngine.swift
//  ServerStressTester
//
//  Created by Vlad-R on 14/03/15.
//  Copyright (c) 2015 Vlad-R. All rights reserved.
//

import Cocoa

private struct Constants {
    static let RequestBatchSize = 500
}

class TestEngine {
    private let semaphore = dispatch_semaphore_create(1)
    private let test_concurrent_queue = dispatch_queue_create("com.vr.ConcurrentQueue", DISPATCH_QUEUE_CONCURRENT)
    private let test_serial_queue = dispatch_queue_create("com.vr.SerialQueue", DISPATCH_QUEUE_SERIAL)
    
    private let session: NSURLSession
    private let url: NSURL
    private let repetitionCount: Int
    
    private var successes = 0
    private var failures = 0
    private var totalRequestsMade = 0
    
    init(url: NSURL, repetitionCount: Int = 1, timeout: NSTimeInterval = 60.0, HTTPHeaders: [String: String] = [String: String]()) {
        self.url = url
        self.repetitionCount = repetitionCount
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfig.timeoutIntervalForRequest = timeout
        sessionConfig.HTTPAdditionalHeaders = HTTPHeaders
        
        self.session = NSURLSession(configuration: sessionConfig)
    }
    
    func beginTest() {
        println("Starting Test...")
        
        dispatch_async(test_concurrent_queue) {
            for index in 0..<self.repetitionCount {
                if index % Constants.RequestBatchSize == 0 {
                    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER)
                }
                
                let request = NSMutableURLRequest()
                request.URL = self.url
                
                let task = self.session.dataTaskWithRequest(request) {
                    (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                    
                    dispatch_async(self.test_serial_queue) {
                        ++self.totalRequestsMade
                        println("Request Number: \(self.totalRequestsMade)")
                        
                        if error == nil {
                            ++self.successes
                            println("Success")
                        } else {
                            ++self.failures
                            println("Fail")
                            println(error.localizedDescription)
                        }
                        
                        if (self.totalRequestsMade % Constants.RequestBatchSize == 0) ||
                            ((self.totalRequestsMade % Constants.RequestBatchSize != 0) && (self.totalRequestsMade == self.repetitionCount)) {
                                dispatch_semaphore_signal(self.semaphore)
                        }
                        
                        if self.totalRequestsMade == self.repetitionCount {
                            println("Test Completed:")
                            println("Successes: \(self.successes)")
                            println("Failures: \(self.failures)")
                        }
                    }
                }
                task.resume()
            }
        }
    }
}
