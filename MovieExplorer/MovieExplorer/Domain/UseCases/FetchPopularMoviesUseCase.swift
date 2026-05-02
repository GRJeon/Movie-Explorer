//
//  FetchPopularMoviesUseCase.swift
//  MovieExplorer
//
//

import Foundation

protocol FetchPopularMoviesUseCase {
    func execute(page: Int) async throws -> (movies: [Movie], totalPages: Int)
}

struct DefaultFetchPopularMoviesUseCase: FetchPopularMoviesUseCase {
    
    let movieRepository: MovieRepositoryProtocol
    
    func execute(page: Int) async throws -> (movies: [Movie], totalPages: Int) {
        guard page >= 1 else {
            throw MovieError.invalidRequest
        }
        return try await movieRepository.fetchPopularMovies(page: page)
    }
}
