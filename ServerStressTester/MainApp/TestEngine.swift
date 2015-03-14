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
    private let test_concurrent_queue = dispatch_queue_create("com.vr.TestQueue", DISPATCH_QUEUE_CONCURRENT)
    
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
}
