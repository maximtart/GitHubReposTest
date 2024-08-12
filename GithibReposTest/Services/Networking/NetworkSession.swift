//
//  NetworkSession.swift
//  GithibReposTest
//
//  Created by Maxim on 12.08.2024.
//

import Foundation
import Foundation

public protocol NetworkSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {}
