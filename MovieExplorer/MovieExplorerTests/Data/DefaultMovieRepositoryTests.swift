//
//  DefaultMovieRepositoryTests.swift
//  MovieExplorerTests
//
//  Created by Liam on 4/30/26.
//

import XCTest
@testable import MovieExplorer

final class DefaultMovieRepositoryTests: XCTestCase {

    private var sut: DefaultMovieRepository!
    private var mockNetworkService: MockNetworkService!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        sut = DefaultMovieRepository(networkService: mockNetworkService)
    }

    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        super.tearDown()
    }

    // MARK: - fetchPopularMovies

    func test_fetchPopularMovies_page파라미터로_올바른_endpoint를_생성한다() async throws {
        // given
        let page = 3
        mockNetworkService.requestResult = MovieResponseDTO(
            page: page,
            totalPages: 10,
            results: []
        )

        // when
        _ = try await sut.fetchPopularMovies(page: page)

        // then
        let endpoint = try XCTUnwrap(mockNetworkService.capturedEndpoint as? MovieEndpoint)
        guard case .popular(let capturedPage) = endpoint else {
            XCTFail("endpoint가 .popular이 아닙니다")
            return
        }
        XCTAssertEqual(capturedPage, page)
    }

    func test_fetchPopularMovies_networkService에_요청하고_DTO를_도메인으로_변환한다() async throws {
        // given
        let dto = MovieResponseDTO(
            page: 1,
            totalPages: 5,
            results: [
                MovieDTO(id: 1, title: "영화1", posterPath: "/poster1.jpg", voteAverage: 8.5),
                MovieDTO(id: 2, title: "영화2", posterPath: nil, voteAverage: 7.0)
            ]
        )
        mockNetworkService.requestResult = dto

        // when
        let result = try await sut.fetchPopularMovies(page: 1)

        // then
        XCTAssertEqual(result.totalPages, 5)
        XCTAssertEqual(result.movies.count, 2)
        XCTAssertEqual(result.movies[0], Movie(id: 1, title: "영화1", posterPath: "/poster1.jpg", voteAverage: 8.5))
        XCTAssertEqual(result.movies[1], Movie(id: 2, title: "영화2", posterPath: nil, voteAverage: 7.0))
    }

    func test_fetchPopularMovies_networkService_에러시_에러를_전달한다() async {
        // given
        mockNetworkService.requestError = NSError(domain: "test", code: -1)

        // when & then
        do {
            _ = try await sut.fetchPopularMovies(page: 1)
            XCTFail("에러가 발생해야 합니다")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
