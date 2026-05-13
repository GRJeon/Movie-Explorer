//
//  MovieResponseDTO.swift
//  MovieExplorer
//
//  Created by Liam on 4/30/26.
//

import Foundation

struct MovieResponseDTO: Decodable {
    let page: Int
    let totalPages: Int
    let results: [MovieDTO]

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
    }
}

struct MovieDTO: Decodable {
    let id: Int
    let title: String
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String?
    let popularity: Double?

    enum CodingKeys: String, CodingKey {
        case id, title
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case popularity
    }

    func toDomain() -> Movie {
        Movie(
            id: id,
            title: title,
            posterPath: ImageURLMapper.makeFullPath(imagePath: posterPath),
            voteAverage: voteAverage
        )
    }

    func toSearchResultDomain() -> SearchResult {
        SearchResult(
            id: id,
            title: title,
            posterPath: ImageURLMapper.makeFullPath(imagePath: posterPath),
            releaseDate: releaseDate ?? "",
            voteAverage: voteAverage,
            popularity: popularity ?? 0.0
        )
    }
}
