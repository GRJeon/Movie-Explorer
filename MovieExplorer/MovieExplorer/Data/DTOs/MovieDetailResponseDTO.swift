//
//  MovieDetailResponseDTO.swift
//  MovieExplorer
//
//  Created by Liam on 4/30/26.
//

import Foundation

struct MovieDetailResponseDTO: Decodable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String
    let runtime: Int?
    let genres: [GenreDTO]
    let voteAverage: Double

    enum CodingKeys: String, CodingKey {
        case id, title, overview, runtime, genres
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
    }

    func toDomain() -> MovieDetail {
        MovieDetail(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            runtime: runtime,
            genres: genres.map { $0.name },
            voteAverage: voteAverage
        )
    }
}

struct GenreDTO: Decodable {
    let id: Int
    let name: String
}
