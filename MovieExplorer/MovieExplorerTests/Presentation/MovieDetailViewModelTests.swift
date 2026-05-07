//
//  MovieDetailViewModelTests.swift
//  MovieExplorerTests
//
//

import XCTest
@testable import MovieExplorer

@MainActor
final class MovieDetailViewModelTests: XCTestCase {
    
    var sut: MovieDetailViewModel!
    var mockUseCase: MockGetMovieDetailUseCase!
    let mockMovieId = 550
    
    override func setUp() {
        super.setUp()
        mockUseCase = MockGetMovieDetailUseCase()
        sut = MovieDetailViewModel(movieId: mockMovieId, getMovieDetailUseCase: mockUseCase)
    }
    
    override func tearDown() {
        sut = nil
        mockUseCase = nil
        super.tearDown()
    }
    
    func test_정상적으로_상세정보를_가져온다() async {
        // Given
        let expectedDetail = MovieDetail(
            id: mockMovieId,
            title: "파이트 클럽",
            overview: "줄거리",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "1999-10-15",
            runtime: 139,
            genres: ["드라마"],
            voteAverage: 8.4
        )
        mockUseCase.mockResult = .success(expectedDetail)
        
        // When
        await sut.fetchDetail()
        
        // Then
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUseCase.lastRequestedId, mockMovieId)
        XCTAssertEqual(sut.movieDetail, expectedDetail)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_에러발생시_errorMessage가_세팅된다() async {
        // Given
        mockUseCase.mockResult = .failure(MovieError.networkFailure)
        
        // When
        await sut.fetchDetail()
        
        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.movieDetail)
    }
}
