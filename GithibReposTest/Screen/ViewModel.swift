//
//  ViewModel.swift
//  GithibReposTest
//
//  Created by Maxim on 12.08.2024.
//

import Foundation
import Combine

@MainActor
final class ViewModel: ObservableObject {
    private let networkManager: NetworkManager
    @Published private(set) var repositories: [Repository] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading: Bool = false
    
    // MARK: - Initializer
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    // MARK: - Actions
    func fetchRepositories(for user: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let repos = try await networkManager.fetchRepositories(for: user)
            repositories = repos
            errorMessage = nil
        } catch {
            repositories = []
            errorMessage = error.localizedDescription
        }
    }
}
