//
//  SearchMoviesUseCaseTests.swift
//  MovieExplorerTests
//
//

import XCTest
@testable import MovieExplorer

final class SearchMoviesUseCaseTests: XCTestCase {

    private var sut: DefaultSearchMoviesUseCase!
    private var mockMovieRepository: MockMovieRepository!

    override func setUp() {
        super.setUp()
        mockMovieRepository = MockMovieRepository()
        sut = DefaultSearchMoviesUseCase(movieRepository: mockMovieRepository)
    }

    override func tearDown() {
        sut = nil
        mockMovieRepository = nil
        super.tearDown()
    }

    // MARK: - 쿼리 필터링 테스트

    func test_마지막글자가_미완성된_자음인경우_탈락시키고_요청한다() async throws {
        // given
        let query = "인터스텔ㄹ"
        mockMovieRepository.mockSearchResult = .success((movies: [], totalPages: 1))
        
        // when
        _ = try await sut.execute(query: query)
        
        // then
        let capturedQuery = mockMovieRepository.lastRequestedQuery
        XCTAssertEqual(capturedQuery, "인터스텔")
    }
    
    func test_마지막글자가_미완성된_모음인경우_탈락시키고_요청한다() async throws {
        // given
        let query = "어벤져스ㅏ"
        mockMovieRepository.mockSearchResult = .success((movies: [], totalPages: 1))
        
        // when
        _ = try await sut.execute(query: query)
        
        // then
        let capturedQuery = mockMovieRepository.lastRequestedQuery
        XCTAssertEqual(capturedQuery, "어벤져스")
    }

    func test_미완성된문자가_아니면_원래_문자열그대로_요청한다() async throws {
        // given
        let query = "인터스텔라"
        mockMovieRepository.mockSearchResult = .success((movies: [], totalPages: 1))
        
        // when
        _ = try await sut.execute(query: query)
        
        // then
        let capturedQuery = mockMovieRepository.lastRequestedQuery
        XCTAssertEqual(capturedQuery, "인터스텔라")
    }

    // MARK: - 빈 문자열 테스트

    func test_쿼리가_비어있을_경우_요청하지_않고_빈_배열을_반환한다() async throws {
        // given
        let query = ""
        
        // when
        let result = try await sut.execute(query: query)
        
        // then
        XCTAssertEqual(mockMovieRepository.searchMoviesCallCount, 0)
        XCTAssertTrue(result.isEmpty)
    }

    func test_공백만_있는_쿼리일_경우_요청하지_않고_빈_배열을_반환한다() async throws {
        // given
        let query = "   "
        
        // when
        let result = try await sut.execute(query: query)
        
        // then
        XCTAssertEqual(mockMovieRepository.searchMoviesCallCount, 0)
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_미완성문자를_제거한_결과가_빈문자열이면_요청하지_않고_빈_배열을_반환한다() async throws {
        // given
        let query = "ㄱ"
        
        // when
        let result = try await sut.execute(query: query)
        
        // then
        XCTAssertEqual(mockMovieRepository.searchMoviesCallCount, 0)
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Page 파라미터 테스트

    func test_요청시_page는_항상_1로_고정된다() async throws {
        // given
        let query = "test"
        mockMovieRepository.mockSearchResult = .success((movies: [], totalPages: 1))
        
        // when
        _ = try await sut.execute(query: query)
        
        // then
        XCTAssertEqual(mockMovieRepository.lastRequestedPage, 1)
    }

    // MARK: - 정렬 테스트

    func test_반환되는_결과는_popularity를_기준으로_내림차순_정렬된다() async throws {
        // given
        let query = "영화"
        let movies = [
            SearchResult(id: 1, title: "영화1", posterPath: nil, releaseDate: "2020", voteAverage: 8.0, popularity: 10.5),
            SearchResult(id: 2, title: "영화2", posterPath: nil, releaseDate: "2021", voteAverage: 7.0, popularity: 50.2),
            SearchResult(id: 3, title: "영화3", posterPath: nil, releaseDate: "2022", voteAverage: 9.0, popularity: 3.1),
            SearchResult(id: 4, title: "영화4", posterPath: nil, releaseDate: "2023", voteAverage: 6.0, popularity: 20.0)
        ]
        mockMovieRepository.mockSearchResult = .success((movies: movies, totalPages: 1))
        
        // when
        let result = try await sut.execute(query: query)
        
        // then
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result[0].id, 2) // popularity: 50.2
        XCTAssertEqual(result[1].id, 4) // popularity: 20.0
        XCTAssertEqual(result[2].id, 1) // popularity: 10.5
        XCTAssertEqual(result[3].id, 3) // popularity: 3.1
    }

    // MARK: - 에러 반환 테스트

    func test_레포지토리에서_에러발생시_에러를_그대로_던진다() async {
        // given
        let query = "error"
        mockMovieRepository.mockSearchResult = .failure(MovieError.networkFailure)
        
        // when & then
        do {
            _ = try await sut.execute(query: query)
            XCTFail("에러가 던져져야 합니다")
        } catch {
            XCTAssertEqual(error as? MovieError, MovieError.networkFailure)
        }
    }
}
