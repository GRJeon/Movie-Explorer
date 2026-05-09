//
//  MovieDetailViewController.swift
//  MovieExplorer
//
//

import UIKit
import Combine
import SnapKit
import Kingfisher

final class MovieDetailViewController: UIViewController {
    
    private let viewModel: MovieDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let backdropImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        return iv
    }()

    private let gradientView = UIView()
    private let gradientLayer = CAGradientLayer()

    private let posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        iv.backgroundColor = .gray
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title3)
        label.numberOfLines = 2
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()

    private let overviewHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "줄거리"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()

    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        
        Task {
            await viewModel.fetchDetail()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(false, animated: true)

        view.addSubview(backdropImageView)
        view.addSubview(gradientView)
        applyGradient()

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        view.addSubview(loadingIndicator)
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoStackView)
        contentView.addSubview(overviewHeaderLabel)
        contentView.addSubview(overviewLabel)

        backdropImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(backdropImageView.snp.width).multipliedBy(9.0 / 16.0)
        }

        gradientView.snp.makeConstraints { make in
            make.edges.equalTo(backdropImageView)
        }

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        posterImageView.snp.makeConstraints { make in
            make.top.equalTo(backdropImageView.snp.centerY)
            make.bottom.equalTo(backdropImageView.snp.bottom)
            make.leading.equalTo(contentView.snp.trailing).multipliedBy(0.05)
            make.width.equalTo(posterImageView.snp.height).multipliedBy(2.0 / 3.0)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.top).inset(8)
            make.leading.equalTo(posterImageView.snp.trailing).offset(15)
            make.trailing.equalToSuperview().inset(20)
        }

        overviewHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.bottom).offset(40)
            make.leading.equalTo(contentView.snp.trailing).multipliedBy(0.05)
        }

        overviewLabel.snp.makeConstraints { make in
            make.top.equalTo(overviewHeaderLabel.snp.bottom).offset(12)
            make.leading.equalTo(contentView.snp.trailing).multipliedBy(0.05)
            make.trailing.equalToSuperview().inset(20)
        }
    }

    private func applyGradient() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.0, 0.9]
        gradientView.layer.addSublayer(gradientLayer)
    }

    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .loading:
                    self?.loadingIndicator.startAnimating()
                    self?.scrollView.isHidden = true
                case .loaded:
                    self?.loadingIndicator.stopAnimating()
                    self?.scrollView.isHidden = false
                    self?.updateUI()
                case .error(let message):
                    self?.loadingIndicator.stopAnimating()
                    self?.showError(message)
                case .idle:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateUI() {
        guard let movie = viewModel.movieDetail else { return }
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview


        if let url = viewModel.movieDetail?.backdropPath {
            backdropImageView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
        }
        if let url = viewModel.movieDetail?.posterPath {
            posterImageView.kf.setImage(with: url)
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

#if DEBUG
import SwiftUI

struct MovieDetailPreview: PreviewProvider {

    static var previews: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 60) {
                VStack {
                    Text("iPhone 17 Pro").font(.headline).foregroundColor(.gray)
                    UIViewControllerPreview {
                        makeViewController(movieId: 12)
                    }
                    .frame(width: 402, height: 874)
                    .border(Color.gray.opacity(0.5), width: 2)
                    .clipped()
                }

                VStack {
                    Text("iPad Pro 13-inch").font(.headline).foregroundColor(.gray)
                    UIViewControllerPreview {
                        makeViewController(movieId: 12)
                    }
                    .frame(width: 1032, height: 1376)
                    .border(Color.gray.opacity(0.5), width: 2)
                    .clipped()
                }
            }
            .padding(40)
        }
        .previewLayout(.sizeThatFits)
    }

    static func makeViewController(movieId: Int) -> UIViewController {
        let networkService = NetworkService()
        let repository = DefaultMovieRepository(networkService: networkService)
        let useCase = DefaultGetMovieDetailUseCase(movieRepository: repository)
        let viewModel = MovieDetailViewModel(movieId: 12, getMovieDetailUseCase: useCase)
        let vc = MovieDetailViewController(viewModel: viewModel)
        return UINavigationController(rootViewController: vc)
    }
}
#endif
