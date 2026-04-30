//
//  MovieRepositoryProtocol.swift
//  MovieExplorer
//
//  Created by Liam on 4/30/26.
//

protocol MovieRepositoryProtocol {
    func fetchPopularMovies(page: Int) async throws -> (movies: [Movie], totalPages: Int)
    func searchMovies(query: String, page: Int) async throws -> (movies: [Movie], totalPages: Int)
    func fetchMovieDetail(id: Int) async throws -> MovieDetail
}
