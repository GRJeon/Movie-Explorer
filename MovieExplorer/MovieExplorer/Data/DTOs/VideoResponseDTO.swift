//
//  VideoResponseDTO.swift
//  MovieExplorer
//

import Foundation

struct VideoResponseDTO: Decodable {
    let id: Int
    let results: [VideoDTO]
}

struct VideoDTO: Decodable {
    let key: String
    let site: String
    let type: String
}
