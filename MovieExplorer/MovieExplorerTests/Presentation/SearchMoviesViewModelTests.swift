//
//  SearchMoviesViewModelTests.swift
//  MovieExplorerTests
//
//

import XCTest
@testable import MovieExplorer

@MainActor
final class SearchMoviesViewModelTests: XCTestCase {
    
    private var sut: SearchMoviesViewModel!
    private var mockUseCase: MockSearchMoviesUseCase!

    override func setUp() {
        super.setUp()
        mockUseCase = MockSearchMoviesUseCase()
        sut = SearchMoviesViewModel(searchMoviesUseCase: mockUseCase)
    }

    override func tearDown() {
        sut = nil
        mockUseCase = nil
        super.tearDown()
    }

    // MARK: - 입력 및 디바운싱 테스트

    func test_검색어를_입력하면_300ms_디바운싱_이후에_UseCase를_호출한다() async {
        // given
        mockUseCase.mockResult = .success([])

        // when
        sut.updateSearchQuery("인터")
        sut.updateSearchQuery("인터스")
        sut.updateSearchQuery("인터스텔라")
        
        // 300ms 보다 적게 기다리면 아직 호출되지 않아야 함
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(mockUseCase.executeCallCount, 0)
        
        // 300ms 이후에는 단 한 번만 호출되어야 함 (마지막 쿼리)
        try? await Task.sleep(nanoseconds: 300_000_000) // 총 400ms 대기
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUseCase.lastRequestedQuery, "인터스텔라")
    }

    func test_동일한_검색어가_연속으로_입력되면_removeDuplicates로_인해_중복요청을_방지한다() async {
        // given
        mockUseCase.mockResult = .success([])
        
        // when: 첫 번째 쿼리 입력
        sut.updateSearchQuery("다크나이트")
        try? await Task.sleep(nanoseconds: 350_000_000)
        let initialCallCount = mockUseCase.executeCallCount
        
        // when: 동일한 쿼리 다시 입력
        sut.updateSearchQuery("다크나이트")
        try? await Task.sleep(nanoseconds: 350_000_000)
        
        // then: 호출 횟수가 증가하지 않아야 함
        XCTAssertEqual(mockUseCase.executeCallCount, initialCallCount)
    }

    // MARK: - 검색 결과 제공 테스트

    func test_UseCase에서_성공적으로_결과를_가져오면_searchResults를_업데이트한다() async {
        // given
        let expectedMovies = [
            SearchResult(id: 1, title: "인터스텔라", posterPath: nil, releaseDate: "2014-11-05", voteAverage: 9.0, popularity: 120.0)
        ]
        mockUseCase.mockResult = .success(expectedMovies)
        
        // when
        sut.updateSearchQuery("인터스텔라")
        try? await Task.sleep(nanoseconds: 350_000_000)
        
        // then
        XCTAssertEqual(sut.searchResults.count, 1)
        XCTAssertEqual(sut.searchResults.first?.title, "인터스텔라")
    }

    // MARK: - 쿼리 초기화 테스트

    func test_쿼리를_지우면_디바운싱중인_요청이_취소되고_결과가_빈배열로_초기화된다() async {
        // given
        let expectedMovies = [SearchResult(id: 1, title: "인터스텔라", posterPath: nil, releaseDate: "2014", voteAverage: 9.0, popularity: 120.0)]
        mockUseCase.mockResult = .success(expectedMovies)
        
        // 먼저 쿼리를 보내고 결과를 받음
        sut.updateSearchQuery("인터스텔라")
        try? await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertEqual(sut.searchResults.count, 1)
        
        // when: 새로운 쿼리를 입력하고 디바운싱 중에 clear 호출
        sut.updateSearchQuery("다크나이트")
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms 지남 (아직 디바운싱 중)
        sut.clearSearchQuery() // 즉시 초기화 및 "" 전송
        
        // then: 취소되었으므로 "다크나이트"는 요청되지 않아야 함
        try? await Task.sleep(nanoseconds: 400_000_000)
        // 첫 번째 "인터스텔라" 성공 후, clear()에 의한 ""가 ViewModel에서 차단됨
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUseCase.lastRequestedQuery, "인터스텔라")
        XCTAssertTrue(sut.searchResults.isEmpty)
    }
}
