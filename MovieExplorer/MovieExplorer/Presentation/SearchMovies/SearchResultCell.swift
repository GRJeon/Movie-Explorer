//
//  SearchResultCell.swift
//  MovieExplorer
//
//

import UIKit
import SnapKit
import Kingfisher

final class SearchResultCell: UICollectionViewCell {
    static let reuseIdentifier = "SearchResultCell"

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()

    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var labelStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, releaseDateLabel, ratingLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = nil
        titleLabel.text = nil
        releaseDateLabel.text = nil
        ratingLabel.text = nil
    }

    private func setupUI() {
        contentView.addSubview(posterImageView)
        contentView.addSubview(labelStack)

        posterImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(8)
            make.width.equalTo(60)
        }

        labelStack.snp.makeConstraints { make in
            make.leading.equalTo(posterImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalTo(posterImageView)
        }
    }

    func configure(with result: SearchResult) {
        titleLabel.text = result.title
        releaseDateLabel.text = result.releaseDate.isEmpty ? nil : result.releaseDate
        ratingLabel.text = "⭐ \(String(format: "%.1f", result.voteAverage))"

        posterImageView.kf.setImage(
            with: result.posterPath,
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        )
    }
}
