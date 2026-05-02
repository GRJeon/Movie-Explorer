//
//  MockFetchPopularMoviesUseCase.swift
//  MovieExplorerTests
//
//

import Foundation
@testable import MovieExplorer

final class MockFetchPopularMoviesUseCase: FetchPopularMoviesUseCase {
    
    var mockResult: Result<(movies: [Movie], totalPages: Int), Error>?
    var executeCallCount = 0
    var lastRequestedPage: Int?
    
    // 중복 호출(Loading) 상태를 테스트하기 위한 지연 시간 프로퍼티
    var delayNanoseconds: UInt64 = 0
    
    func execute(page: Int) async throws -> (movies: [Movie], totalPages: Int) {
        executeCallCount += 1
        lastRequestedPage = page
        
        // 로딩 상태를 길게 유지하고 싶을 때 사용
        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }
        
        if let result = mockResult {
            switch result {
            case .success(let data):
                return data
            case .failure(let error):
                throw error
            }
        }
        
        return ([], 0)
    }
}
