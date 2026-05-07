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
    private var idSet: Set<Int> = []

    private let fetchPopularMoviesUseCase: FetchPopularMoviesUseCase
    
    init(fetchPopularMoviesUseCase: FetchPopularMoviesUseCase) {
        self.fetchPopularMoviesUseCase = fetchPopularMoviesUseCase
    }

    func fetchNextPage() async {
        guard !isLoading, currentPage < totalPages else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let nextPage = currentPage + 1
            let result = try await fetchPopularMoviesUseCase.execute(page: nextPage)

            let newMovies = result.movies.filter { !idSet.contains($0.id) }
            newMovies.forEach { idSet.insert($0.id) }
            movies.append(contentsOf: newMovies)

            currentPage = nextPage
            totalPages = result.totalPages
        } catch let error as MovieError {
            errorMessage = error.description
        } catch {
            errorMessage = "예기치 못한 오류가 발생했습니다: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
