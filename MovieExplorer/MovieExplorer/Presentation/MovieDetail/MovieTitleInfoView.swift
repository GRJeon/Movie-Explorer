//
//  MovieTitleInfoView.swift
//  MovieExplorer
//

import UIKit
import SnapKit

final class MovieTitleInfoView: UIView {
    
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
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let dateStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        return stack
    }()
    
    private let calendarImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "calendar"))
        iv.tintColor = .gray
        return iv
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(infoStackView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.bottom.equalToSuperview()
        }
        
        dateStackView.addArrangedSubview(calendarImageView)
        dateStackView.addArrangedSubview(dateLabel)
        
        infoStackView.addArrangedSubview(ratingLabel)
        infoStackView.addArrangedSubview(dateStackView)
    }
    
    func configure(title: String?, voteAverageText: String?, releaseDateText: String?) {
        titleLabel.text = title
        
        ratingLabel.text = voteAverageText
        ratingLabel.isHidden = (voteAverageText == nil)
        
        if let date = releaseDateText {
            dateLabel.text = date
            dateStackView.isHidden = false
        } else {
            dateStackView.isHidden = true
        }
    }
}
