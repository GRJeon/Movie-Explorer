//
//  NetworkError.swift
//  MovieExplorer
//
//  Created by Liam on 4/30/26.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case httpError(statusCode: Int)
    case unknown
}
