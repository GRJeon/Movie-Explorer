//
//  MovieTrailerView.swift
//  MovieExplorer
//

import UIKit
import WebKit
import SnapKit

final class MovieTrailerView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "예고편"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = .systemGray6
        webView.layer.cornerRadius = 8
        webView.clipsToBounds = true
        webView.scrollView.isScrollEnabled = false
        return webView
    }()
    
    private lazy var youtubeButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "YouTube에서 보기"
        config.image = UIImage(systemName: "play.rectangle.fill")
        config.imagePadding = 8
        config.baseBackgroundColor = .systemRed
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        
        let button = UIButton(configuration: config)
        button.addAction(UIAction { [weak self] _ in
            self?.openYoutubeApp()
        }, for: .touchUpInside)
        return button
    }()
    
    private var youtubeKey: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(webView)
        addSubview(youtubeButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        webView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(webView.snp.width).multipliedBy(9.0 / 16.0)
        }
        
        youtubeButton.snp.makeConstraints { make in
            make.top.equalTo(webView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalToSuperview()
        }
    }
    
    func configure(with youtubeKey: String?) {
        guard let youtubeKey, !youtubeKey.isEmpty else {
            isHidden = true
            return
        }
        isHidden = false
        self.youtubeKey = youtubeKey
        
        guard let url = URL(string: "https://www.youtube.com/embed/\(youtubeKey)?playsinline=1") else { return }

        var request = URLRequest(url: url)
        let bundleID = Bundle.main.bundleIdentifier ?? "com.myApp.default"
        request.setValue("https://\(bundleID)", forHTTPHeaderField: "Referer")

        webView.load(request)
    }
    
    private func openYoutubeApp() {
        guard let key = youtubeKey else { return }
        
        if let appURL = URL(string: "youtube://\(key)"),
           UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else if let webURL = URL(string: "https://www.youtube.com/watch?v=\(key)") {
            UIApplication.shared.open(webURL)
        }
    }
}
