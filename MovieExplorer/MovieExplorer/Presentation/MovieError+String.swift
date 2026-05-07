//
//  MovieError+String.swift
//  MovieExplorer
//
//  Created by Liam on 5/7/26.
//

extension MovieError {
    var description: String {
        switch self {
        case .networkFailure:
            return "네트워크 연결이 불안정합니다. 인터넷 연결을 확인해주세요."
        case .serverError:
            return "서버에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        case .invalidRequest:
            return "잘못된 요청입니다."
        case .decodingFailure:
            return "데이터를 불러오는 중 오류가 발생했습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
