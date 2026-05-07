//
//  MockGetMovieDetailUseCase.swift
//  MovieExplorerTests
//
//

import Foundation
@testable import MovieExplorer

final class MockGetMovieDetailUseCase: GetMovieDetailUseCase {
    var mockResult: Result<MovieDetail, Error>?
    var executeCallCount = 0
    var lastRequestedId: Int?
    
    func execute(id: Int) async throws -> MovieDetail {
        executeCallCount += 1
        lastRequestedId = id
        
        if let result = mockResult {
            switch result {
            case .success(let detail): return detail
            case .failure(let error): throw error
            }
        }
        fatalError("mockResult not set")
    }
}
