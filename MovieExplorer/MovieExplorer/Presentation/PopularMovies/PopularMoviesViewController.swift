//
//  PopularMoviesViewController.swift
//  MovieExplorer
//
//

import UIKit
import Combine
import SnapKit

final class PopularMoviesViewController: UIViewController {

    nonisolated private enum Section: Hashable, Sendable {
        case main
    }

    private let viewModel: PopularMoviesViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.reuseIdentifier)
        cv.prefetchDataSource = self
        return cv
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Movie>!
    
    init(viewModel: PopularMoviesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureDataSource()
        bindViewModel()
        
        Task {
            await viewModel.fetchNextPage()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func createCompositionalLayout(columns: Int = 3) -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        // 포스터 크기 동적 계산, 텍스트 높이는 정적
        let groupHeight = UIScreen.main.bounds.width / CGFloat(columns) * 1.5 + 40
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(groupHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Movie>(collectionView: collectionView) { (cv: UICollectionView, indexPath: IndexPath, movie: Movie) -> UICollectionViewCell? in
            guard let cell = cv.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.reuseIdentifier, for: indexPath) as? MovieCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: movie)
            return cell
        }
    }
    
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

extension PopularMoviesViewController: UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let lastIndexPath = indexPaths.last else { return }

        let currentItemCount = viewModel.movies.count
        if currentItemCount > 0, lastIndexPath.row >= currentItemCount - 3 {
            Task {
                await viewModel.fetchNextPage()
            }
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
            let viewModel = PopularMoviesViewModel(fetchPopularMoviesUseCase: useCase)
            let vc = PopularMoviesViewController(viewModel: viewModel)
            return UINavigationController(rootViewController: vc)
        }
    }
}
#endif
