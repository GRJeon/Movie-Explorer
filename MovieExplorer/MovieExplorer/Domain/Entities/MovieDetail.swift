//
//  MovieDetail.swift
//  MovieExplorer
//
//  Created by Liam on 4/29/26.
//

struct MovieDetail: Equatable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String
    let runtime: Int?
    let genres: [String]
    let voteAverage: Double
}
