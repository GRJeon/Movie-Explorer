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

    enum CodingKeys: String, CodingKey {
        case id, title
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
    }

    func toDomain() -> Movie {
        Movie(
            id: id,
            title: title,
            posterPath: posterPath,
            voteAverage: voteAverage
        )
    }
}
