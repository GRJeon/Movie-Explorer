//
//  NetworkService.swift
//  MovieExplorer
//
//

import Foundation

final class NetworkService: NetworkServiceProtocol {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(endpoint: APIEndpoint) async throws -> T {
        fatalError("Not implemented yet")
    }
}
