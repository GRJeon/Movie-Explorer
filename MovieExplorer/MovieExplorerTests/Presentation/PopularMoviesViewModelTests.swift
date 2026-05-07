//
//  PopularMoviesViewModelTests.swift
//  MovieExplorerTests
//
//

import XCTest
@testable import MovieExplorer

@MainActor
final class PopularMoviesViewModelTests: XCTestCase {
    
    var sut: PopularMoviesViewModel!
    var mockUseCase: MockFetchPopularMoviesUseCase!
    
    override func setUp() {
        super.setUp()
        mockUseCase = MockFetchPopularMoviesUseCase()
        sut = PopularMoviesViewModel(fetchPopularMoviesUseCase: mockUseCase)
    }
    
    override func tearDown() {
        sut = nil
        mockUseCase = nil
        super.tearDown()
    }

    func test_첫_페이지_요청시_데이터를_잘_가져온다() async {
        // Given
        let expectedMovies = [Movie(id: 1, title: "Test", posterPath: nil, voteAverage: 8.0)]
        mockUseCase.mockResult = .success((movies: expectedMovies, totalPages: 5))
        
        // When
        await sut.fetchNextPage()
        
        // Then
        XCTAssertEqual(sut.movies.count, 1)
        XCTAssertEqual(sut.movies.first?.id, 1)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUseCase.lastRequestedPage, 1)
    }
    
    func test_다음_페이지_요청시_기존_데이터에_추가된다() async {
        // Given: 1페이지 먼저 로드
        let page1Movies = [Movie(id: 1, title: "Movie 1", posterPath: nil, voteAverage: 8.0)]
        mockUseCase.mockResult = .success((movies: page1Movies, totalPages: 5))
        await sut.fetchNextPage()
        
        // When: 2페이지 로드
        let page2Movies = [Movie(id: 2, title: "Movie 2", posterPath: nil, voteAverage: 7.0)]
        mockUseCase.mockResult = .success((movies: page2Movies, totalPages: 5))
        await sut.fetchNextPage()
        
        // Then
        XCTAssertEqual(sut.movies.count, 2)
        XCTAssertEqual(sut.movies[0].id, 1)
        XCTAssertEqual(sut.movies[1].id, 2)
        XCTAssertEqual(mockUseCase.executeCallCount, 2)
        XCTAssertEqual(mockUseCase.lastRequestedPage, 2)
    }
    
    func test_에러발생시_errorMessage가_세팅된다() async {
        // Given
        mockUseCase.mockResult = .failure(MovieError.networkFailure)
        
        // When
        await sut.fetchNextPage()
        
        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.movies.isEmpty)
    }

    func test_로딩중일때는_fetchNextPage가_무시된다() async {
        // Given
        mockUseCase.delayNanoseconds = 100_000_000
        mockUseCase.mockResult = .success((movies: [], totalPages: 5))
        
        // When
        let task1 = Task { await sut.fetchNextPage() }
        let task2 = Task { await sut.fetchNextPage() }
        let task3 = Task { await sut.fetchNextPage() }
        
        _ = await (task1.value, task2.value, task3.value)
        
        // Then
        XCTAssertEqual(mockUseCase.executeCallCount, 1, "동시에 여러 번 호출되어도 UseCase는 1번만 실행되어야 합니다.")
    }
    
    func test_마지막_페이지에_도달하면_더이상_요청하지_않는다() async {
        // Given
        let page1Movies = [Movie(id: 1, title: "Movie 1", posterPath: nil, voteAverage: 8.0)]
        mockUseCase.mockResult = .success((movies: page1Movies, totalPages: 1))
        await sut.fetchNextPage()
        
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
        
        // When
        await sut.fetchNextPage()
        
        // Then
        XCTAssertEqual(mockUseCase.executeCallCount, 1, "마지막 페이지 이후에는 더 이상 UseCase가 호출되지 않아야 합니다.")
    }

    func test_중복된_데이터가_서버에서_내려올경우_하나만_추가된다() async {
        // Given
        let movie1 = Movie(id: 1, title: "니모를 찾아서", posterPath: nil, voteAverage: 8.0)
        mockUseCase.mockResult = .success((movies: [movie1], totalPages: 5))
        await sut.fetchNextPage()
        
        // When
        let duplicateMovie = Movie(id: 1, title: "니모를 찾아서", posterPath: nil, voteAverage: 8.0)
        let movie2 = Movie(id: 2, title: "인크레더블", posterPath: nil, voteAverage: 7.5)
        mockUseCase.mockResult = .success((movies: [duplicateMovie, movie2], totalPages: 5))
        await sut.fetchNextPage()
        
        // Then
        XCTAssertEqual(sut.movies.count, 2, "중복된 데이터는 필터링되어야 합니다.")
        XCTAssertEqual(sut.movies[0].id, 1)
        XCTAssertEqual(sut.movies[1].id, 2)
    }
}
