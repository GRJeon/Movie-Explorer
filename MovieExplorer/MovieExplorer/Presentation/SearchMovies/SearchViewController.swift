//
//  SearchViewController.swift
//  MovieExplorer
//
//

import UIKit
import Combine
import SnapKit

final class SearchViewController: UIViewController {

    nonisolated private enum Section: Hashable {
        case main
    }

    private let viewModel: SearchMoviesViewModel
    private var dataSource: UICollectionViewDiffableDataSource<Section, SearchResult>!
    private var cancellables = Set<AnyCancellable>()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.backgroundColor = .systemBackground
        cv.register(SearchResultCell.self, forCellWithReuseIdentifier: SearchResultCell.reuseIdentifier)
        cv.keyboardDismissMode = .onDrag
        return cv
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "검색 결과가 없습니다"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.isHidden = true
        return label
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "영화 제목을 검색해보세요"
        label.textAlignment = .center
        label.textColor = .tertiaryLabel
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()

    // MARK: - Init

    init(viewModel: SearchMoviesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureDataSource()
        bindViewModel()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        view.addSubview(emptyStateLabel)
        view.addSubview(placeholderLabel)

        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        placeholderLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(90)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(90)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, SearchResult>(
            collectionView: collectionView
        ) { cv, indexPath, result in
            guard let cell = cv.dequeueReusableCell(
                withReuseIdentifier: SearchResultCell.reuseIdentifier,
                for: indexPath
            ) as? SearchResultCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: result)
            return cell
        }
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.$searchResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                self?.applySnapshot(results)
                self?.updateEmptyState(for: results)
            }
            .store(in: &cancellables)
    }

    private func applySnapshot(_ results: [SearchResult]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SearchResult>()
        snapshot.appendSections([.main])
        snapshot.appendItems(results, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func updateEmptyState(for results: [SearchResult]) {
        let hasQuery = !(viewModel.searchResults.isEmpty && results.isEmpty)
        let isQueryActive = !results.isEmpty || hasQuery

        placeholderLabel.isHidden = isQueryActive
        emptyStateLabel.isHidden = !results.isEmpty || !isQueryActive
    }
}
