//
//  StubbornURLSessionProtocol.swift
//  
//
//  Created by Martin Kim Dung-Pham on 08.09.19.
//

import Foundation

public protocol StubbornURLSession: URLSession {

    /**
     Stub a single request. When the session is asked for a `URLSession` task of a similar request, the task will complete with the prerecorded response, error and data.

     - Parameters:
         - request: The request to stub
         - data: The data to return when the request is fulfilled
         - response: The response when the request is fulfilled
         - error: A potential error when the request is fulfilled
    */
    func stub(_ request: URLRequest, data: Data?, response: URLResponse?, error: Error?)

    /**
     The record mode defines the way the StubbornURLSession behaves. It can record or playback stubs.
     */
    var recordMode: RecordMode {get set}
}
