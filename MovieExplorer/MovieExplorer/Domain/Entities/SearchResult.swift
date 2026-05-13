//
//  SearchResult.swift
//  MovieExplorer
//
//  Created by Liam on 5/13/26.
//

import Foundation

nonisolated struct SearchResult: Equatable, Hashable {
    let id: Int
    let title: String
    let posterPath: URL?
    let releaseDate: String
    let voteAverage: Double
    let popularity: Double
}

extension SearchResult {
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
