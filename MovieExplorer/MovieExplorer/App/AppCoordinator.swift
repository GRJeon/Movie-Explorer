//
//  AppCoordinator.swift
//  MovieExplorer
//
//

import UIKit

final class AppCoordinator {

    private let navigationController: UINavigationController
    private let repository: MovieRepositoryProtocol

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        let networkService = NetworkService()
        self.repository = DefaultMovieRepository(networkService: networkService)
    }

    func start() {
        showMovieList()
    }

    // MARK: - Navigation

    private func showMovieList() {
        let popularUseCase = DefaultFetchPopularMoviesUseCase(movieRepository: repository)
        let searchUseCase = DefaultSearchMoviesUseCase(movieRepository: repository)

        let popularVM = PopularMoviesViewModel(fetchPopularMoviesUseCase: popularUseCase)
        let searchVM = SearchMoviesViewModel(searchMoviesUseCase: searchUseCase)

        let vc = PopularMoviesViewController(viewModel: popularVM, searchViewModel: searchVM)
        vc.onMovieSelected = { [weak self] movieId in
            self?.showMovieDetail(movieId: movieId)
        }
        vc.onInfoTapped = { [weak self] in
            self?.showAppInfo()
        }

        navigationController.setViewControllers([vc], animated: false)
    }

    private func showMovieDetail(movieId: Int) {
        let getMovieDetailUseCase = DefaultGetMovieDetailUseCase(movieRepository: repository)
        let viewModel = MovieDetailViewModel(movieId: movieId, getMovieDetailUseCase: getMovieDetailUseCase)
        let vc = MovieDetailViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    private func showAppInfo() {
        let infoVC = AppInfoViewController()
        if let sheet = infoVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        navigationController.present(infoVC, animated: true)
    }
}
