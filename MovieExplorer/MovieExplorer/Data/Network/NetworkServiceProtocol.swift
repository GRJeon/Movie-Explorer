//
//  NetworkServiceProtocol.swift
//  MovieExplorer
//
//  Created by Liam on 4/30/26.
//

import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(endpoint: APIEndpoint) async throws -> T
}
