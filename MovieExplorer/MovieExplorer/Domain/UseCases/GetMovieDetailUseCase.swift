//
//  GetMovieDetailUseCase.swift
//  MovieExplorer
//
//  Created by Liam on 5/7/26.
//

protocol GetMovieDetailUseCase {
    func execute(id: Int) async throws -> MovieDetail
}

struct DefaultGetMovieDetailUseCase: GetMovieDetailUseCase {

    let movieRepository: MovieRepositoryProtocol

    func execute(id: Int) async throws -> MovieDetail {
        try await movieRepository.fetchMovieDetail(id: id)
    }
}
