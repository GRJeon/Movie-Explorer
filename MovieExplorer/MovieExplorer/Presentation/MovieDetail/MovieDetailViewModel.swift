//
//  MovieDetailViewModel.swift
//  MovieExplorer
//
//

import Foundation
import Combine

@MainActor
final class MovieDetailViewModel {
    
    @Published private(set) var movieDetail: MovieDetail?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil
    
    private let movieId: Int
    private let getMovieDetailUseCase: GetMovieDetailUseCase
    
    init(movieId: Int, getMovieDetailUseCase: GetMovieDetailUseCase) {
        self.movieId = movieId
        self.getMovieDetailUseCase = getMovieDetailUseCase
    }
    
    func fetchDetail() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await getMovieDetailUseCase.execute(id: movieId)
            movieDetail = result
        } catch let error as MovieError {
            errorMessage = error.description
        } catch {
            errorMessage = "예기치 못한 오류가 발생했습니다: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
