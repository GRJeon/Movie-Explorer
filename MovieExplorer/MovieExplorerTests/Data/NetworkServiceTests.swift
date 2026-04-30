//
//  NetworkServiceTests.swift
//  MovieExplorerTests
//

import XCTest
@testable import MovieExplorer

final class NetworkServiceTests: XCTestCase {

    var sut: NetworkService!
    var mockSession: URLSession!

    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: configuration)
        
        sut = NetworkService(session: mockSession)
    }

    override func tearDown() {
        sut = nil
        mockSession = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func test_request가_URLRequest를_정확히_생성한다() async throws {
        // Given
        let endpoint = MockEndpoint(
            baseURL: "https://api.test.com",
            path: "/v1/data",
            method: .post,
            headers: ["Authorization": "Bearer Token"],
            queryParameters: ["query": "test"],
            bodyParameters: ["key": "value"]
        )
        
        var capturedRequest: URLRequest?
        let mockData = try JSONEncoder().encode(MockModel(id: 1, name: "Test"))
        
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockData)
        }
        
        // When
        let _: MockModel? = try? await sut.request(endpoint: endpoint)
        
        // Then
        XCTAssertNotNil(capturedRequest, "URLRequest가 캡처되지 않았습니다.")
        
        // URL 검증
        XCTAssertTrue(capturedRequest?.url?.absoluteString.starts(with: "https://api.test.com/v1/data") ?? false)
        
        // Query Parameters 검증
        if let url = capturedRequest?.url,
           let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           let queryItems = components.queryItems {
            XCTAssertTrue(queryItems.contains(URLQueryItem(name: "query", value: "test")))
        } else {
            XCTFail("Query parameters가 설정되지 않았습니다.")
        }
        
        // Method 및 Headers 검증
        XCTAssertEqual(capturedRequest?.httpMethod, "POST")
        XCTAssertEqual(capturedRequest?.allHTTPHeaderFields?["Authorization"], "Bearer Token")
        
        // Body 검증
        if let httpBody = capturedRequest?.httpBody,
           let jsonObject = try JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: String] {
            XCTAssertEqual(jsonObject["key"], "value")
        } else {
            XCTFail("Body parameters가 잘못 설정되었습니다.")
        }
    }

    func test_request가_InvlaidStatusCode를_처리() async {
        // Given
        let endpoint = MockEndpoint(path: "/error")
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        
        // When & Then
        do {
            let _: MockModel = try await sut.request(endpoint: endpoint)
            XCTFail("에러가 발생해야 하지만 성공했습니다.")
        } catch let error as NetworkError {
            guard case .httpError(let statusCode) = error else {
                XCTFail("잘못된 에러가 발생했습니다: \(error)")
                return
            }
            XCTAssertEqual(statusCode, 404)
        } catch {
            XCTFail("예상치 못한 에러.")
        }
    }

    func test_request가_URLError_를_처리() async {
        // Given
        let endpoint = MockEndpoint(path: "/network-error")
        let expectedError = URLError(.notConnectedToInternet)
        
        MockURLProtocol.requestHandler = { _ in
            throw expectedError
        }
        
        // When & Then
        do {
            let _: MockModel = try await sut.request(endpoint: endpoint)
            XCTFail("네트워크 에러가 발생해야 하지만 성공했습니다.")
        } catch let error as URLError {
            XCTAssertEqual(error.code, .notConnectedToInternet)
        } catch {
            XCTFail("URLError가 아닌 다른 에러가 발생했습니다: \(error)")
        }
    }

    func test_request_JSON_데이터를_디코딩해_반환() async throws {
        // Given
        let endpoint = MockEndpoint(path: "/success")
        let expectedModel = MockModel(id: 777, name: "Success Data")
        let responseData = try JSONEncoder().encode(expectedModel)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseData)
        }
        
        // When
        let result: MockModel = try await sut.request(endpoint: endpoint)
        
        // Then
        XCTAssertEqual(result.id, expectedModel.id)
        XCTAssertEqual(result.name, expectedModel.name)
    }
}

// MARK: - Mocks for Testing

struct MockModel: Codable, Equatable {
    let id: Int
    let name: String
}

struct MockEndpoint: APIEndpoint {
    var baseURL: String = "https://mock.com"
    var path: String = "/mock"
    var method: HTTPMethod = .get
    var headers: [String: String]? = nil
    var queryParameters: [String: Any]? = nil
    var bodyParameters: [String: Any]? = nil
}
