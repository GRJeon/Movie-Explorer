//
//  MovieError.swift
//  MovieExplorer
//
//  Created by Liam on 4/30/26.
//

enum MovieError: Error {
    case networkFailure
    case serverError
    case invalidRequest
    case decodingFailure
    case unknown
}
