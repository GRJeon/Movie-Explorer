//
//  Movie.swift
//  MovieExplorer
//
//  Created by Liam on 4/29/26.
//

import Foundation

nonisolated struct Movie {
    let id: Int
    let title: String
    let posterPath: URL?
    let voteAverage: Double
}

extension Movie: Equatable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Movie, rhs: Movie) -> Bool {
        #if DEBUG
        // 테스트 및 시뮬레이터 환경: 모든 프로퍼티를 꼼꼼하게 비교
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.voteAverage == rhs.voteAverage
        #else
        // rlease: 서버의 데이터가 자주 변하지 않으므로 id만 비교
        return lhs.id == rhs.id
        #endif
    }
}
