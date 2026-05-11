//
//  GetMovieDetailUseCaseTests.swift
//  MovieExplorerTests
//
//

import XCTest
@testable import MovieExplorer

final class GetMovieDetailUseCaseTests: XCTestCase {
    
    var sut: DefaultGetMovieDetailUseCase!
    var mockRepository: MockMovieRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockMovieRepository()
        sut = DefaultGetMovieDetailUseCase(movieRepository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func test_성공시_레포지토리의_결과를_그대로_반환한다() async throws {
        // Given
        let movieId = 550
        let expectedDetail = MovieDetail(
            id: movieId,
            title: "파이트 클럽",
            overview: "줄거리",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "1999-10-15",
            runtime: 139,
            genres: ["드라마"],
            voteAverage: 8.4,
            youtubeKey: nil
        )
        mockRepository.mockDetailResult = .success(expectedDetail)
        
        // When
        let result = try await sut.execute(id: movieId)
        
        // Then
        XCTAssertEqual(mockRepository.fetchMovieDetailCallCount, 1)
        XCTAssertEqual(mockRepository.lastRequestedId, movieId)
        XCTAssertEqual(result, expectedDetail)
    }
    
    func test_레포지토리에서_에러발생시_그대로_전달한다() async {
        // Given
        let movieId = 550
        mockRepository.mockDetailResult = .failure(MovieError.networkFailure)
        
        // When & Then
        do {
            _ = try await sut.execute(id: movieId)
            XCTFail("에러가 발생해야 하지만 성공했습니다.")
        } catch let error as MovieError {
            XCTAssertEqual(error, .networkFailure)
        } catch {
            XCTFail("예상치 못한 에러: \(error)")
        }
    }
}
