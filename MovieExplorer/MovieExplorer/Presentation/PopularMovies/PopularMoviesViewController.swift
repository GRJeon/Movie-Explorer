//
//  PopularMoviesViewController.swift
//  MovieExplorer
//
//

import Combine
import Kingfisher
import SnapKit
import UIKit

final class PopularMoviesViewController: UIViewController {

    nonisolated private enum Section: Hashable, Sendable {
        case main
    }
    private enum ColumnsIcon: String {
        case two = "square.grid.2x2.fill"
        case three = "square.grid.3x2.fill"
        case four = "square.grid.4x3.fill"
    }

    private let viewModel: PopularMoviesViewModel
    private let searchViewModel: SearchMoviesViewModel
    private lazy var searchResultsVC = SearchViewController(viewModel: searchViewModel)

    var onMovieSelected: ((Int) -> Void)?

    private var dataSource: UICollectionViewDiffableDataSource<Section, Movie>!
    private var cancellables = Set<AnyCancellable>()
    private var imagePrefetchers: [IndexPath: ImagePrefetcher] = [:]

    // MARK: - UI

    private lazy var topBarView: TopBarView = {
        return TopBarView(title: "Movie Explorer")
    }()

    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "영화를 검색해보세요"
        bar.searchBarStyle = .minimal
        bar.delegate = self
        return bar
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.reuseIdentifier)
        cv.delegate = self
        cv.prefetchDataSource = self
        return cv
    }()

    // MARK: - Init

    init(viewModel: PopularMoviesViewModel, searchViewModel: SearchMoviesViewModel) {
        self.viewModel = viewModel
        self.searchViewModel = searchViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
        setupSearchResultsChild()
        configureDataSource()
        bindViewModel()

        Task {
            await viewModel.fetchNextPage()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(topBarView)
        view.addSubview(searchBar)
        view.addSubview(collectionView)

        topBarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(topBarView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // 레이아웃 메뉴
        let menu = UIMenu(
            title: "레이아웃 변경",
            children: [
                UIAction(
                    title: "2열",
                    image: UIImage(systemName: ColumnsIcon.two.rawValue)
                ) { [weak self] _ in
                    self?.changeLayout(columns: 2)
                },
                UIAction(
                    title: "3열",
                    image: UIImage(systemName: ColumnsIcon.three.rawValue)
                ) { [weak self] _ in
                    self?.changeLayout(columns: 3)
                },
                UIAction(
                    title: "4열",
                    image: UIImage(systemName: ColumnsIcon.four.rawValue)
                ) { [weak self] _ in
                    self?.changeLayout(columns: 4)
                }
            ]
        )

        let layoutButton = UIButton(type: .system)
        layoutButton.setImage(UIImage(systemName: "square.grid.2x2"), for: .normal)
        layoutButton.showsMenuAsPrimaryAction = true
        layoutButton.menu = menu

        topBarView.setRightView(layoutButton)
    }

    private func setupSearchResultsChild() {
        searchResultsVC.onMovieSelected = { [weak self] id in
            self?.onMovieSelected?(id)
        }

        addChild(searchResultsVC)
        view.addSubview(searchResultsVC.view)
        searchResultsVC.didMove(toParent: self)

        searchResultsVC.view.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        searchResultsVC.view.isHidden = true
    }

    private func showSearchResults() {
        view.bringSubviewToFront(searchResultsVC.view)
        searchResultsVC.view.isHidden = false
    }

    private func hideSearchResults() {
        searchResultsVC.view.isHidden = true
    }

    // MARK: - Layout

    private func changeLayout(columns: Int) {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems.sorted()
        let firstVisibleIndexPath = visibleIndexPaths.first
        let layout = createCompositionalLayout(columns: columns)
        collectionView.setCollectionViewLayout(layout, animated: true)

        if let firstVisibleIndexPath {
            collectionView.scrollToItem(at: firstVisibleIndexPath, at: .top, animated: false)
        }
    }

    private func createCompositionalLayout(columns: Int = 3) -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            let groupHeight = containerWidth / CGFloat(columns) * 1.5 + 40
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(groupHeight)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            return NSCollectionLayoutSection(group: group)
        }
    }

    // MARK: - DataSource

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Movie>(collectionView: collectionView) { (cv, indexPath, movie) in
            guard let cell = cv.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.reuseIdentifier, for: indexPath) as? MovieCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: movie)
            return cell
        }
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.$movies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] movies in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Movie>()
                snapshot.appendSections([.main])
                snapshot.appendItems(movies, toSection: .main)
                self?.dataSource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] errorMessage in
                let alert = UIAlertController(title: "알림", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(alert, animated: true)
            }
            .store(in: &cancellables)
    }
}

// MARK: - UISearchBarDelegate
extension PopularMoviesViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        showSearchResults()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchViewModel.updateSearchQuery(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        searchViewModel.clearSearchQuery()
        hideSearchResults()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDelegate
extension PopularMoviesViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let movie = dataSource.itemIdentifier(for: indexPath) else { return }
        onMovieSelected?(movie.id)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let currentItemCount = viewModel.movies.count

        if currentItemCount > 0, indexPath.row >= currentItemCount - 4 {
            Task {
                await viewModel.fetchNextPage()
            }
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching
extension PopularMoviesViewController: UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard indexPath.item < viewModel.movies.count else { continue }

            if let url = viewModel.movies[indexPath.item].posterPath {
                let prefetcher = ImagePrefetcher(resources: [url])
                imagePrefetchers[indexPath] = prefetcher
                prefetcher.start()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            imagePrefetchers[indexPath]?.stop()
            imagePrefetchers.removeValue(forKey: indexPath)
        }
    }
}

#if DEBUG
import SwiftUI

struct PopularMoviesVC_Preview: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            let networkService = NetworkService()
            let repository = DefaultMovieRepository(networkService: networkService)
            let useCase = DefaultFetchPopularMoviesUseCase(movieRepository: repository)
            let searchUseCase = DefaultSearchMoviesUseCase(movieRepository: repository)
            let viewModel = PopularMoviesViewModel(fetchPopularMoviesUseCase: useCase)
            let searchViewModel = SearchMoviesViewModel(searchMoviesUseCase: searchUseCase)
            let vc = PopularMoviesViewController(viewModel: viewModel, searchViewModel: searchViewModel)
            return UINavigationController(rootViewController: vc)
        }
    }
}
#endif
