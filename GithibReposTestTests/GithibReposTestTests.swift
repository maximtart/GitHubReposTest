//
//  GithibReposTestTests.swift
//  GithibReposTestTests
//
//  Created by Maxim on 12.08.2024.
//

import XCTest
@testable import GithibReposTest

final class GithibReposTestTests: XCTestCase {
    private var networkManager: NetworkManager!
    
    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        networkManager = NetworkManager(session: session)
    }
    
    override func tearDown() {
        networkManager = nil
        super.tearDown()
    }
    
    func testFetchRepositories_Success() async {
        let expectedRepo = Repository(name: "test-repo", description: "test-description")
        let data = try! JSONEncoder().encode([expectedRepo])
        
        MockURLProtocol.loadingHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            
            return (response, data, nil)
        }

        do {
            let repositories = try await networkManager.fetchRepositories(for: "Apple")
            
            XCTAssertEqual(repositories.count, 1)
            XCTAssertEqual(repositories.first?.name, expectedRepo.name)
            XCTAssertEqual(repositories.first?.description, expectedRepo.description)
        } catch {
            XCTFail("Expected success but got error: \(error)")
        }
    }
    
    func testFetchRepositories_InvalidUser() async {
        MockURLProtocol.loadingHandler = { request in
            (nil, nil, URLError(.badServerResponse))
        }
        
        do {
            _ = try await networkManager.fetchRepositories(for: "InvalidUserName123")
            XCTFail("Expected failure but got success")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testFetchRepositories_InvalidStatusCode() async {
        MockURLProtocol.loadingHandler = { request in
            return (nil, nil, URLError(.badServerResponse))
        }
    
        do {
            _ = try await networkManager.fetchRepositories(for: "Apple")
            XCTFail("Expected failure but got success")
        } catch {
            XCTAssertNotNil(error)
            XCTAssertEqual((error as? URLError)?.code, .badServerResponse)
        }
    }
    
    func testFetchRepositories_SpecialCharacters() async {
        MockURLProtocol.loadingHandler = { _ in (nil, nil, nil) }
        
        do {
            _ = try await networkManager.fetchRepositories(for: "OAIR_22")
            XCTFail("Expected failure but got success")
        } catch {
            // Assert
            XCTAssertNotNil(error)
            XCTAssertEqual((error as? URLError)?.code, .unsupportedURL)
        }
    }
    
    func testFetchRepositories_EmptyUserName() async {
        MockURLProtocol.loadingHandler = { _ in (nil, nil, nil) }
        
        do {
            _ = try await networkManager.fetchRepositories(for: "")
            XCTFail("Expected failure but got success")
        } catch {
            XCTAssertNotNil(error)
            XCTAssertEqual((error as? URLError)?.code, .unsupportedURL)
        }
    }
    
    func testFetchRepositories_NetworkTimeout() async {
        MockURLProtocol.loadingHandler = { _ in
            (nil, nil, URLError(.timedOut))
        }
        
        do {
            _ = try await networkManager.fetchRepositories(for: "Apple")
            XCTFail("Expected timeout error but got success")
        } catch {
            XCTAssertNotNil(error)
            XCTAssertEqual((error as? URLError)?.code, .timedOut, "Expected URLError.timedOut but got: \(error)")
        }
    }
    
    func testFetchRepositories_SlowNetwork() async {
        let expectedRepo = Repository(name: "test-repo", description: "test-description")
        let data = try! JSONEncoder().encode([expectedRepo])
        
        MockURLProtocol.loadingHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            
            return (response, data, URLError(.cannotConnectToHost))
        }
        
        do {
            _ = try await networkManager.fetchRepositories(for: "Apple")
            XCTFail("Expected cannot connect to host error but got success")
        } catch {
            // Assert
            XCTAssertNotNil(error)
            XCTAssertEqual((error as? URLError)?.code, .cannotConnectToHost)
        }
    }
    
    func testFetchRepositories_NoInternetConnection() async {
        MockURLProtocol.loadingHandler = { _ in
            (nil, nil, URLError(.notConnectedToInternet))
        }
        
        do {
            _ = try await networkManager.fetchRepositories(for: "Apple")
            XCTFail("Expected no internet connection error but got success")
        } catch {
            // Assert
            XCTAssertNotNil(error)
            XCTAssertEqual((error as? URLError)?.code, .notConnectedToInternet, "Expected URLError.notConnectedToInternet but got: \(error)")
        }
    }
    
    func testFetchRepositories_DecodingFailure() async {
        let invalidJSON = """
        {
            "invalid_key": "invalid_value"
        }
        """.data(using: .utf8)!
        MockURLProtocol.loadingHandler = { _ in
            (nil, invalidJSON, nil)
        }
        
        do {
            _ = try await networkManager.fetchRepositories(for: "Apple")
            XCTFail("Expected decoding failure but got success")
        } catch {
            // Assert
            XCTAssertNotNil(error)
            XCTAssertTrue(error is DecodingError, "Expected DecodingError but got: \(error)")
        }
    }
    
    func testFetchRepositories_EmptyResponse() async {
        MockURLProtocol.loadingHandler = { _ in
            (nil, Data(), nil)
        }
        
        do {
            _ = try await networkManager.fetchRepositories(for: "Apple")
            XCTFail("Expected failure but got success")
        } catch {
            XCTAssertNotNil(error)
            XCTAssertTrue(error is DecodingError, "Expected DecodingError but got: \(error)")
        }
        
    }
    
    func testFetchRepositories_EmptyList() async {
        let emptyList = """
            [
            ]
            """.data(using: .utf8)!
        MockURLProtocol.loadingHandler = { _ in
            (nil, emptyList, nil)
        }
        
        do {
            let repositories = try await networkManager.fetchRepositories(for: "Apple")
            XCTAssertTrue(repositories.isEmpty, "Expected empty array, but got: \(repositories)")
        } catch {
            XCTFail("Expected success but got error: \(error)")
        }
    }
    
    func testFetchRepositories_InvalidJSONStructure() async {
        let invalidJSONStructure = """
        [{
            "wrong_key": "wrong_value"
        }]
        """.data(using: .utf8)!
        MockURLProtocol.loadingHandler = { _ in
            (nil, invalidJSONStructure, nil)
        }
        
        // Act
        do {
            _ = try await networkManager.fetchRepositories(for: "Apple")
            XCTFail("Expected decoding error but got success")
        } catch {
            // Assert
            XCTAssertNotNil(error)
            XCTAssertTrue(error is DecodingError, "Expected DecodingError but got: \(error)")
        }
    }
    
    func testFetchRepositories_LargeResponse() async {
        // Arrange
        let largeRepos = Array(repeating: Repository(name: "test-repo", description: "test-description"), count: 1000)
        let data = try! JSONEncoder().encode(largeRepos)
        MockURLProtocol.loadingHandler = { _ in
            (nil, data, nil)
        }
        
        // Act
        do {
            let repositories = try await networkManager.fetchRepositories(for: "Apple")
            
            // Assert
            XCTAssertEqual(repositories.count, 1000, "Expected 1000 repositories, but got: \(repositories.count)")
        } catch {
            XCTFail("Expected success but got error: \(error)")
        }
    }
}
