//
//  PopularMoviesViewModel.swift
//  MovieExplorer
//
//

import Foundation
import Combine

@MainActor
final class PopularMoviesViewModel {

    @Published private(set) var movies: [Movie] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil
    
    private var currentPage: Int = 0
    private var totalPages: Int = 1
    
    private let fetchPopularMoviesUseCase: FetchPopularMoviesUseCase
    
    init(fetchPopularMoviesUseCase: FetchPopularMoviesUseCase) {
        self.fetchPopularMoviesUseCase = fetchPopularMoviesUseCase
    }

    func fetchNextPage() async {
        fatalError("Not implemented yet")
    }
}
