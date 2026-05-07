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
    private var set: Set<Int> = []

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

            let newMovies = result.movies.filter { !set.contains($0.id) }
            newMovies.forEach { set.insert($0.id) }
            movies.append(contentsOf: newMovies)

            currentPage = nextPage
            totalPages = result.totalPages
        } catch let error as MovieError {
            switch error {
            case .networkFailure:
                errorMessage = "네트워크 연결이 불안정합니다. 인터넷 연결을 확인해주세요."
            case .serverError:
                errorMessage = "서버에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
            case .invalidRequest:
                errorMessage = "잘못된 요청입니다."
            case .decodingFailure:
                errorMessage = "데이터를 불러오는 중 오류가 발생했습니다."
            case .unknown:
                errorMessage = "알 수 없는 오류가 발생했습니다."
            }
        } catch {
            errorMessage = "예기치 못한 오류가 발생했습니다: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
