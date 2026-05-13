//
//  MockMovieRepository.swift
//  MovieExplorerTests
//

import Foundation
@testable import MovieExplorer

final class MockMovieRepository: MovieRepositoryProtocol {
    
    var mockResult: Result<(movies: [Movie], totalPages: Int), Error>?
    var mockDetailResult: Result<MovieDetail, Error>?
    
    var fetchPopularMoviesCallCount = 0
    var lastRequestedPage: Int?
    
    var fetchMovieDetailCallCount = 0
    var lastRequestedId: Int?
    
    func fetchPopularMovies(page: Int) async throws -> (movies: [Movie], totalPages: Int) {
        fetchPopularMoviesCallCount += 1
        lastRequestedPage = page
        
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
    
    var mockSearchResult: Result<(movies: [SearchResult], totalPages: Int), Error>?
    var searchMoviesCallCount = 0
    var lastRequestedQuery: String?

    func searchMovies(query: String, page: Int) async throws -> (movies: [SearchResult], totalPages: Int) {
        searchMoviesCallCount += 1
        lastRequestedQuery = query
        lastRequestedPage = page
        
        if let result = mockSearchResult {
            switch result {
            case .success(let data):
                return data
            case .failure(let error):
                throw error
            }
        }
        
        return ([], 0)
    }
    
    func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        fetchMovieDetailCallCount += 1
        lastRequestedId = id
        
        if let result = mockDetailResult {
            switch result {
            case .success(let detail):
                return detail
            case .failure(let error):
                throw error
            }
        }
        
        fatalError("mockDetailResult is not set")
    }

    var mockYoutubeKeyResult: Result<String?, Error>?
    var fetchYoutubeKeyCallCount = 0
    
    func fetchYoutubeKey(id: Int) async throws -> String? {
        fetchYoutubeKeyCallCount += 1
        lastRequestedId = id
        
        if let result = mockYoutubeKeyResult {
            switch result {
            case .success(let key):
                return key
            case .failure(let error):
                throw error
            }
        }
        
        fatalError("mockYoutubeKeyResult is not set")
    }
}
