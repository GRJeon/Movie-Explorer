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
        async let fetchedDetail = movieRepository.fetchMovieDetail(id: id)
        async let fetchedYoutubeKey = try? movieRepository.fetchYoutubeKey(id: id)

        let detail = try await fetchedDetail
        let youtubeKey = await fetchedYoutubeKey

        return MovieDetail(
            id: detail.id,
            title: detail.title,
            overview: detail.overview,
            posterPath: detail.posterPath,
            backdropPath: detail.backdropPath,
            releaseDate: detail.releaseDate,
            runtime: detail.runtime,
            genres: detail.genres,
            voteAverage: detail.voteAverage,
            youtubeKey: youtubeKey
        )
    }
}
