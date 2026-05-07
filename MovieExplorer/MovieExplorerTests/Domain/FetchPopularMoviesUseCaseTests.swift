//
//  FetchPopularMoviesUseCaseTests.swift
//  MovieExplorerTests
//

import XCTest
@testable import MovieExplorer

final class FetchPopularMoviesUseCaseTests: XCTestCase {
    
    var sut: DefaultFetchPopularMoviesUseCase!
    var mockRepository: MockMovieRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockMovieRepository()
        sut = DefaultFetchPopularMoviesUseCase(movieRepository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func test_페이지가_1미만이면_invalidPage_에러를_던진다() async {
        // Given
        let invalidPage = 0
        
        // When & Then
        do {
            _ = try await sut.execute(page: invalidPage)
            XCTFail("에러가 발생해야 하지만 성공했습니다.")
        } catch let error as MovieError {
            // 도메인 에러인 MovieError.invalidRequest 등으로 매핑할 수 있습니다.
            XCTAssertEqual(error, .invalidRequest)
        } catch {
            XCTFail("예상치 못한 에러: \(error)")
        }
    }

    func test_정상적인_페이지_요청시_Repository의_결과를_반환한다() async throws {
        // Given
        let validPage = 1
        let expectedMovies = [Movie(id: 1, title: "Mock", posterPath: nil, voteAverage: 9.0)]
        let expectedTotalPages = 10
        
        mockRepository.mockResult = .success((expectedMovies, expectedTotalPages))
        
        // When
        let result = try await sut.execute(page: validPage)
        
        // Then
        XCTAssertEqual(mockRepository.fetchPopularMoviesCallCount, 1)
        XCTAssertEqual(mockRepository.lastRequestedPage, validPage)
        XCTAssertEqual(result.movies.count, expectedMovies.count)
        XCTAssertEqual(result.movies.first?.id, expectedMovies.first?.id)
        XCTAssertEqual(result.movies.first?.title, expectedMovies.first?.title)
        XCTAssertEqual(result.movies.first?.posterPath, expectedMovies.first?.posterPath)
        XCTAssertEqual(result.movies.first?.voteAverage, expectedMovies.first?.voteAverage)
        XCTAssertEqual(result.totalPages, expectedTotalPages)
    }

    func test_Repository에서_에러발생시_그대로_전달한다() async {
        // Given
        let validPage = 1
        mockRepository.mockResult = .failure(MovieError.networkFailure)
        
        // When & Then
        do {
            _ = try await sut.execute(page: validPage)
            XCTFail("에러가 발생해야 하지만 성공했습니다.")
        } catch let error as MovieError {
            XCTAssertEqual(error, .networkFailure)
        } catch {
            XCTFail("예상치 못한 에러: \(error)")
        }
    }
}


