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
        let endpoint = MovieEndpoint.popular(page: page)
        let response: MovieResponseDTO = try await networkService.request(endpoint: endpoint)
        let movies = response.results.map { $0.toDomain() }
        return (movies: movies, totalPages: response.totalPages)
    }

    func searchMovies(query: String, page: Int) async throws -> (movies: [Movie], totalPages: Int) {
        let endpoint = MovieEndpoint.search(query: query, page: page)
        let response: MovieResponseDTO = try await networkService.request(endpoint: endpoint)
        let movies = response.results.map { $0.toDomain() }
        return (movies: movies, totalPages: response.totalPages)
    }

    func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        let endpoint = MovieEndpoint.detail(id: id)
        let response: MovieDetailResponseDTO = try await networkService.request(endpoint: endpoint)
        return response.toDomain()
    }
}
