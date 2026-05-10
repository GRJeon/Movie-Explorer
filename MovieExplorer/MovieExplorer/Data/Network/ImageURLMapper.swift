//
//  ImageURLMapper.swift
//  MovieExplorer
//
//  Created by Liam on 5/4/26.
//

import Foundation
import UIKit

enum ImageURLMapper {
    enum ImageType {
        case poster
        case backdrop
    }

    static let baseURL = "https://image.tmdb.org/t/p/"
    static let sizeForPoster: String = UIDevice.current.userInterfaceIdiom == .pad ? "w780" : "w500"
    static let sizeForBackdrop: String = UIDevice.current.userInterfaceIdiom == .pad ? "original" : "w1280"

    static func makeFullPath(imagePath: String?, type: ImageType = .poster) -> URL? {
        guard let imagePath, !imagePath.isEmpty else { return nil }

        let size: String
        switch type {
        case .poster:
            size = sizeForPoster
        case .backdrop:
            size = sizeForBackdrop
        }

        return URL(string: baseURL)?
            .appendingPathComponent(size)
            .appendingPathComponent(imagePath)
    }
}
