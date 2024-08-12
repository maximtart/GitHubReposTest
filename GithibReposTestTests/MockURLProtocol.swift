//
//  MockURLProtocol.swift
//  GithibReposTestTests
//
//  Created by Maxim on 12.08.2024.
//

import Foundation

final class MockURLProtocol: URLProtocol {
    static var loadingHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?, Error?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        
        guard let handler = MockURLProtocol.loadingHandler else {
            fatalError("Handler not set.")
        }
        
        do {
            let (mockResponse, data, error) = try handler(request)
            guard error == nil else { throw error! }
            
            let response = mockResponse ?? HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            
            client?.urlProtocol(
                self,
                didReceive: response,
                cacheStoragePolicy: .notAllowed
            )
            
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {
        // No action needed
    }
}
