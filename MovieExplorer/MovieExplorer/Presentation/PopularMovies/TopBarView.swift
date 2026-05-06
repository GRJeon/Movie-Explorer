//
//  TopBarView.swift
//  MovieExplorer
//
//

import UIKit
import SnapKit

final class TopBarView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let rightButtonContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubview(titleLabel)
        addSubview(rightButtonContainer)
        
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(16)
        }
        
        rightButtonContainer.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(16)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(16)
        }
    }

    func setRightView(_ view: UIView) {
        rightButtonContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rightButtonContainer.addArrangedSubview(view)
    }
}
