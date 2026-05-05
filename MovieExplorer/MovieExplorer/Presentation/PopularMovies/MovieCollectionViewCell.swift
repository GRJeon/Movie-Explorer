//
//  MovieCollectionViewCell.swift
//  MovieExplorer
//
//

import UIKit
import SnapKit
import Kingfisher

final class MovieCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "MovieCollectionViewCell"

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        return label
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse( )
        posterImageView.image = nil
        titleLabel.text = nil
        ratingLabel.text = nil
    }

    private func setupUI() {
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(ratingLabel)

        posterImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-8)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.equalTo(ratingLabel.snp.top).offset(-4)
        }
        
        ratingLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.equalToSuperview().inset(4)
        }
    }

    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        ratingLabel.text = "⭐ " + movie.voteAverage.description

        let width = UIScreen.main.bounds.width / 3.0
        let height = width * 2
        let processor = DownsamplingImageProcessor(size: CGSize(width: width, height: height))
                        |> RoundCornerImageProcessor(cornerRadius: 8)

        posterImageView.kf.setImage(
            with: movie.posterPath,
            placeholder: UIImage(systemName: "globe.badge.clock"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ]
        )
    }
}
