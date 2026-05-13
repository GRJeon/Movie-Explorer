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
                MovieDTO(id: 1, title: "영화1", posterPath: "/poster1.jpg", voteAverage: 8.5, releaseDate: nil, popularity: nil),
                MovieDTO(id: 2, title: "영화2", posterPath: nil, voteAverage: 7.0, releaseDate: nil, popularity: nil)
            ]
        )
        mockNetworkService.requestResult = dto

        // when
        let result = try await sut.fetchPopularMovies(page: 1)

        // then
        XCTAssertEqual(result.totalPages, 5)
        XCTAssertEqual(result.movies.count, 2)
        let expectedMovie0 = Movie(id: 1, title: "영화1", posterPath: URL(string: "https://image.tmdb.org/t/p/w500/poster1.jpg"), voteAverage: 8.5)
        XCTAssertEqual(result.movies[0].id, expectedMovie0.id)
        XCTAssertEqual(result.movies[0].title, expectedMovie0.title)
        XCTAssertEqual(result.movies[0].posterPath, expectedMovie0.posterPath)
        XCTAssertEqual(result.movies[0].voteAverage, expectedMovie0.voteAverage)
        
        let expectedMovie1 = Movie(id: 2, title: "영화2", posterPath: nil, voteAverage: 7.0)
        XCTAssertEqual(result.movies[1].id, expectedMovie1.id)
        XCTAssertEqual(result.movies[1].title, expectedMovie1.title)
        XCTAssertEqual(result.movies[1].posterPath, expectedMovie1.posterPath)
        XCTAssertEqual(result.movies[1].voteAverage, expectedMovie1.voteAverage)
    }


    // MARK: - searchMovies

    func test_searchMovies_query와_page로_올바른_endpoint를_생성한다() async throws {
        // given
        let query = "인터스텔라"
        let page = 2
        mockNetworkService.requestResult = MovieResponseDTO(
            page: page,
            totalPages: 1,
            results: []
        )

        // when
        _ = try await sut.searchMovies(query: query, page: page)

        // then
        let endpoint = try XCTUnwrap(mockNetworkService.capturedEndpoint as? MovieEndpoint)
        guard case .search(let capturedQuery, let capturedPage) = endpoint else {
            XCTFail("endpoint가 .search가 아닙니다")
            return
        }
        XCTAssertEqual(capturedQuery, query)
        XCTAssertEqual(capturedPage, page)
    }

    func test_searchMovies_networkService에_요청하고_DTO를_도메인으로_변환한다() async throws {
        // given
        let dto = MovieResponseDTO(
            page: 1,
            totalPages: 3,
            results: [
                MovieDTO(id: 10, title: "인터스텔라", posterPath: "/interstellar.jpg", voteAverage: 9.0, releaseDate: "2014-11-05", popularity: 123.4)
            ]
        )
        mockNetworkService.requestResult = dto

        // when
        let result = try await sut.searchMovies(query: "인터스텔라", page: 1)

        // then
        XCTAssertEqual(result.totalPages, 3)
        XCTAssertEqual(result.movies.count, 1)
        let expectedMovie = SearchResult(id: 10, title: "인터스텔라", posterPath: URL(string: "https://image.tmdb.org/t/p/w500/interstellar.jpg"), releaseDate: "2014-11-05", voteAverage: 9.0, popularity: 123.4)
        XCTAssertEqual(result.movies[0].id, expectedMovie.id)
        XCTAssertEqual(result.movies[0].title, expectedMovie.title)
        XCTAssertEqual(result.movies[0].posterPath, expectedMovie.posterPath)
        XCTAssertEqual(result.movies[0].releaseDate, expectedMovie.releaseDate)
        XCTAssertEqual(result.movies[0].voteAverage, expectedMovie.voteAverage)
        XCTAssertEqual(result.movies[0].popularity, expectedMovie.popularity)
    }


    // MARK: - fetchMovieDetail

    func test_fetchMovieDetail_id로_올바른_endpoint를_생성한다() async throws {
        // given
        let movieId = 550
        mockNetworkService.requestResult = MovieDetailResponseDTO(
            id: movieId,
            title: "파이트 클럽",
            overview: "줄거리",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "1999-10-15",
            runtime: 139,
            genres: [],
            voteAverage: 8.4
        )

        // when
        _ = try await sut.fetchMovieDetail(id: movieId)

        // then
        let endpoint = try XCTUnwrap(mockNetworkService.capturedEndpoint as? MovieEndpoint)
        guard case .detail(let capturedId) = endpoint else {
            XCTFail("endpoint가 .detail이 아닙니다")
            return
        }
        XCTAssertEqual(capturedId, movieId)
    }

    func test_fetchMovieDetail_DTO를_도메인으로_변환한다() async throws {
        // given
        let dto = MovieDetailResponseDTO(
            id: 550,
            title: "파이트 클럽",
            overview: "불면증에 시달리는 남자가...",
            posterPath: "/poster.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "1999-10-15",
            runtime: 139,
            genres: [GenreDTO(id: 18, name: "드라마"), GenreDTO(id: 53, name: "스릴러")],
            voteAverage: 8.4
        )
        mockNetworkService.requestResult = dto

        // when
        let result = try await sut.fetchMovieDetail(id: 550)

        // then
        let expected = MovieDetail(
            id: 550,
            title: "파이트 클럽",
            overview: "불면증에 시달리는 남자가...",
            posterPath: URL(string: "https://image.tmdb.org/t/p/w500/poster.jpg"),
            backdropPath: URL(string: "https://image.tmdb.org/t/p/w1280/backdrop.jpg"),
            releaseDate: "1999-10-15",
            runtime: 139,
            genres: ["드라마", "스릴러"],
            voteAverage: 8.4,
            youtubeKey: nil
        )
        XCTAssertEqual(result, expected)
    }

    // MARK: - fetchYoutubeKey

    func test_fetchYoutubeKey_YouTube이면서_Trailer인_키값을_반환한다() async throws {
        // given
        let movieId = 123
        let dto = VideoResponseDTO(
            id: movieId,
            results: [
                VideoDTO(key: "key1", site: "Vimeo", type: "Trailer"),
                VideoDTO(key: "key2", site: "YouTube", type: "Teaser"),
                VideoDTO(key: "targetKey", site: "YouTube", type: "Trailer"),
                VideoDTO(key: "key3", site: "YouTube", type: "Trailer")
            ]
        )
        mockNetworkService.requestResult = dto

        // when
        let key = try await sut.fetchYoutubeKey(id: movieId)

        // then
        let endpoint = try XCTUnwrap(mockNetworkService.capturedEndpoint as? MovieEndpoint)
        guard case .video(let capturedId) = endpoint else {
            XCTFail("endpoint가 .video가 아닙니다")
            return
        }
        XCTAssertEqual(capturedId, movieId)
        XCTAssertEqual(key, "targetKey", "첫 번째 조건에 맞는 키를 반환해야 합니다")
    }

    func test_fetchYoutubeKey_조건에맞는_영상이_없으면_nil을_반환한다() async throws {
        // given
        let dto = VideoResponseDTO(
            id: 123,
            results: [
                VideoDTO(key: "key1", site: "Vimeo", type: "Trailer"),
                VideoDTO(key: "key2", site: "YouTube", type: "Teaser")
            ]
        )
        mockNetworkService.requestResult = dto

        // when
        let key = try await sut.fetchYoutubeKey(id: 123)

        // then
        XCTAssertNil(key)
    }

    func test_fetchYoutubeKey_에러발생시_MovieError를_던진다() async {
        // given
        mockNetworkService.requestError = URLError(.notConnectedToInternet)

        // when & then
        do {
            _ = try await sut.fetchYoutubeKey(id: 123)
            XCTFail("에러가 발생해야 합니다")
        } catch {
            XCTAssertEqual(error as? MovieError, .networkFailure)
        }
    }

    // MARK: - Error Mapping

    func test_fetchPopularMovies_URLError발생시_networkFailure를_반환한다() async {
        // given
        mockNetworkService.requestError = URLError(.notConnectedToInternet)

        // when & then
        do {
            _ = try await sut.fetchPopularMovies(page: 1)
            XCTFail("에러가 발생해야 합니다")
        } catch {
            XCTAssertEqual(error as? MovieError, .networkFailure)
        }
    }

    func test_searchMovies_DecodingError발생시_decodingFailure를_반환한다() async {
        // given
        mockNetworkService.requestError = DecodingError.dataCorrupted(
            .init(codingPath: [], debugDescription: "test")
        )

        // when & then
        do {
            _ = try await sut.searchMovies(query: "test", page: 1)
            XCTFail("에러가 발생해야 합니다")
        } catch {
            XCTAssertEqual(error as? MovieError, .decodingFailure)
        }
    }

    func test_fetchMovieDetail_404에러발생시_invalidRequest를_반환한다() async {
        // given
        mockNetworkService.requestError = NetworkError.httpError(statusCode: 404)

        // when & then
        do {
            _ = try await sut.fetchMovieDetail(id: 999)
            XCTFail("에러가 발생해야 합니다")
        } catch {
            XCTAssertEqual(error as? MovieError, .invalidRequest)
        }
    }

    func test_fetchPopularMovies_500에러발생시_serverError를_반환한다() async {
        // given
        mockNetworkService.requestError = NetworkError.httpError(statusCode: 500)

        // when & then
        do {
            _ = try await sut.fetchPopularMovies(page: 1)
            XCTFail("에러가 발생해야 합니다")
        } catch {
            XCTAssertEqual(error as? MovieError, .serverError)
        }
    }

    func test_searchMovies_알수없는에러발생시_unknown을_반환한다() async {
        // given
        mockNetworkService.requestError = NSError(domain: "test", code: -1)

        // when & then
        do {
            _ = try await sut.searchMovies(query: "test", page: 1)
            XCTFail("에러가 발생해야 합니다")
        } catch {
            XCTAssertEqual(error as? MovieError, .unknown)
        }
    }
}
