//
//  MovieDetail.swift
//  MovieExplorer
//
//  Created by Liam on 4/29/26.
//

import Foundation

nonisolated struct MovieDetail: Equatable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: URL?
    let backdropPath: URL?
    let releaseDate: String
    let runtime: Int?
    let genres: [String]
    let voteAverage: Double
    let youtubeKey: String?
}
