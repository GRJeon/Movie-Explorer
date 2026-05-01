//
//  MovieEndpoint.swift
//  MovieExplorer
//
//  Created by Liam on 4/30/26.
//

import Foundation

enum MovieEndpoint: APIEndpoint {
    case popular(page: Int)
    case search(query: String, page: Int)
    case detail(id: Int)

    private static let apiKey = "YOUR_API_KEY"

    var baseURL: String {
        "https://api.themoviedb.org"
    }

    var path: String {
        switch self {
        case .popular:
            return "/3/movie/popular"
        case .search:
            return "/3/search/movie"
        case .detail(let id):
            return "/3/movie/\(id)"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var headers: [String: String]? {
        [
            "Authorization": "Bearer \(MovieEndpoint.apiKey)",
            "Content-Type": "application/json"
        ]
    }

    var queryParameters: [String: Any]? {
        switch self {
        case .popular(let page):
            return [
                "language": "ko-KR",
                "page": page
            ]
        case .search(let query, let page):
            return [
                "language": "ko-KR",
                "query": query,
                "page": page
            ]
        case .detail:
            return [
                "language": "ko-KR"
            ]
        }
    }

    var bodyParameters: Encodable? {
        return nil
    }
}
