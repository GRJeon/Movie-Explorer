//
//  Movie.swift
//  MovieExplorer
//
//  Created by Liam on 4/29/26.
//

import Foundation

nonisolated struct Movie: Equatable, Hashable {
    let id: Int
    let title: String
    let posterPath: URL?
    let voteAverage: Double
}
