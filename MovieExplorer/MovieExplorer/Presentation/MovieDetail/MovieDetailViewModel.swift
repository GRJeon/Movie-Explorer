//
//  MovieDetailViewModel.swift
//  MovieExplorer
//
//

import Foundation
import Combine

enum DetailViewState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

@MainActor
final class MovieDetailViewModel {
    
    @Published private(set) var state: DetailViewState = .idle
    
    private(set) var movieDetail: MovieDetail?
    var voteAverageText: String? {
        guard let voteAverage = movieDetail?.voteAverage else { return nil }
        return "⭐ " + voteAverage.description
    }
    var releaseDateText: String? {
        guard let dateString = movieDetail?.releaseDate, !dateString.isEmpty else {
            return nil
        }
        return dateString.replacingOccurrences(of: "-", with: ".")
    }

    private let movieId: Int
    private let getMovieDetailUseCase: GetMovieDetailUseCase
    
    init(movieId: Int, getMovieDetailUseCase: GetMovieDetailUseCase) {
        self.movieId = movieId
        self.getMovieDetailUseCase = getMovieDetailUseCase
    }
    
    func fetchDetail() async {
        if state == .loading { return }
        state = .loading
        
        do {
            let result = try await getMovieDetailUseCase.execute(id: movieId)
            movieDetail = result
            state = .loaded
        } catch let error as MovieError {
            movieDetail = nil
            state = .error(error.description)
        } catch {
            movieDetail = nil
            state = .error("예기치 못한 오류가 발생했습니다: \(error.localizedDescription)")
        }
    }
}
