//
//  Movie.swift
//  MovieExplorer
//
//  Created by Liam on 4/29/26.
//

nonisolated struct Movie: Equatable {
    let id: Int
    let title: String
    let posterPath: String?
    let voteAverage: Double
}
