//
//  ImageURLMapper.swift
//  MovieExplorer
//
//  Created by Liam on 5/4/26.
//

import Foundation
import UIKit

enum ImageURLMapper {
    static let baseURL = "https://image.tmdb.org/t/p/"
    static let size: String = {
        if UIDevice.current.userInterfaceIdiom == .pad {
            "w780"
        } else {
            "w500"
        }
    }()

    static func makeFullPath(imagePath: String?) -> URL? {
        guard let imagePath, !imagePath.isEmpty else { return nil }
        return URL(string: baseURL + size + imagePath)
    }
}
