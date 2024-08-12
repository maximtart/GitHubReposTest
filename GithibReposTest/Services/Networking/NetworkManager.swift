//
//  NetworkManager.swift
//  GithibReposTest
//
//  Created by Maxim on 12.08.2024.
//

import Foundation

final class NetworkManager {
    
    static let shared = NetworkManager(session: URLSession.shared)
    private let session: NetworkSession
    
    init(session: NetworkSession) {
        self.session = session
    }
    
    func fetchRepositories(for user: String) async throws -> [Repository] {
        if user.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) != nil || user.isEmpty {
            throw URLError(.unsupportedURL)
        }
        
        let urlString = "https://api.github.com/users/\(user)/repos"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let urlRequest = URLRequest(url: url)
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        do {
            let repositories = try JSONDecoder().decode([Repository].self, from: data)
            return repositories
        } catch {
            throw error
        }
    }
}
