//
//  SearchMoviesUseCase.swift
//  MovieExplorer
//

import Foundation

protocol SearchMoviesUseCase {
    func execute(query: String) async throws -> [SearchResult]
}

struct DefaultSearchMoviesUseCase: SearchMoviesUseCase {
    
    let movieRepository: MovieRepositoryProtocol
    
    func execute(query: String) async throws -> [SearchResult] {
        var processedQuery = query
        if let lastChar = processedQuery.last, 
           let scalar = lastChar.unicodeScalars.first, 
           (0x3131...0x318E).contains(scalar.value) {
            processedQuery.removeLast()
        }
        
        let trimmedQuery = processedQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedQuery.isEmpty else {
            return []
        }

        let (movies, _) = try await movieRepository.searchMovies(query: trimmedQuery, page: 1)

        return movies.sorted { $0.popularity > $1.popularity }
    }
}
