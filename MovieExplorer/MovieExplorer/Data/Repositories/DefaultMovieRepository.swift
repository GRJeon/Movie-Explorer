//
//  DefaultMovieRepository.swift
//  MovieExplorer
//
//  Created by Liam on 4/30/26.
//

import Foundation

final class DefaultMovieRepository: MovieRepositoryProtocol {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchPopularMovies(page: Int) async throws -> (movies: [Movie], totalPages: Int) {
        fatalError("Not implemented")
    }

    func searchMovies(query: String, page: Int) async throws -> (movies: [Movie], totalPages: Int) {
        fatalError("Not implemented")
    }

    func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        fatalError("Not implemented")
    }
}
