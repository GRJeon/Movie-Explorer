//
//  MockNetworkService.swift
//  MovieExplorerTests
//
//  Created by Liam on 4/30/26.
//

import Foundation
@testable import MovieExplorer

final class MockNetworkService: NetworkServiceProtocol {

    var requestResult: Any?
    var requestError: Error?
    var capturedEndpoint: APIEndpoint?

    func request<T: Decodable>(endpoint: APIEndpoint) async throws -> T {
        capturedEndpoint = endpoint

        if let error = requestError {
            throw error
        }

        guard let result = requestResult as? T else {
            fatalError("MockNetworkService: requestResult 타입이 맞지 않습니다.")
        }

        return result
    }
}
