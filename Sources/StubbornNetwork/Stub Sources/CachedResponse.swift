//
//  CachedResponse.swift
//  
//
//  Created by Martin Kim Dung-Pham on 14.03.20.
//

import Foundation

struct CachedResponse {
    let originalRequest: URLRequest
    let originalResponse: URLResponse?
    let data: Data?
    let error: Error?
}
