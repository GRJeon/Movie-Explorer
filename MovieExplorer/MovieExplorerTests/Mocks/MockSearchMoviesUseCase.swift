//
//  MockSearchMoviesUseCase.swift
//  MovieExplorerTests
//
//

import Foundation
@testable import MovieExplorer

final class MockSearchMoviesUseCase: SearchMoviesUseCase {
    
    var mockResult: Result<[SearchResult], Error>?
    var executeCallCount = 0
    var lastRequestedQuery: String?
    
    func execute(query: String) async throws -> [SearchResult] {
        executeCallCount += 1
        lastRequestedQuery = query
        
        if let result = mockResult {
            switch result {
            case .success(let data):
                return data
            case .failure(let error):
                throw error
            }
        }
        
        return []
    }
}
