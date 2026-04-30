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
        do {
            let endpoint = MovieEndpoint.popular(page: page)
            let response: MovieResponseDTO = try await networkService.request(endpoint: endpoint)
            let movies = response.results.map { $0.toDomain() }
            return (movies: movies, totalPages: response.totalPages)
        } catch {
            throw mapError(error)
        }
    }

    func searchMovies(query: String, page: Int) async throws -> (movies: [Movie], totalPages: Int) {
        do {
            let endpoint = MovieEndpoint.search(query: query, page: page)
            let response: MovieResponseDTO = try await networkService.request(endpoint: endpoint)
            let movies = response.results.map { $0.toDomain() }
            return (movies: movies, totalPages: response.totalPages)
        } catch {
            throw mapError(error)
        }
    }

    func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        do {
            let endpoint = MovieEndpoint.detail(id: id)
            let response: MovieDetailResponseDTO = try await networkService.request(endpoint: endpoint)
            return response.toDomain()
        } catch {
            throw mapError(error)
        }
    }

    private func mapError(_ error: Error) -> MovieError {
        if let movieError = error as? MovieError { return movieError }
        if error is URLError { return .networkFailure }
        if error is DecodingError { return .decodingFailure }
        if case NetworkError.httpError(let statusCode) = error {
            switch statusCode {
            case 400..<500: return .invalidRequest
            case 500..<600: return .serverError
            default: break
            }
        }
        return .unknown
    }
}
