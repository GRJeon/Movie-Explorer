//
//  NetworkService.swift
//  MovieExplorer
//
//

import Foundation

final class NetworkService: NetworkServiceProtocol {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(endpoint: APIEndpoint) async throws -> T {

        guard let baseURL = URL(string: endpoint.baseURL) else {
            throw NetworkError.invalidURL
        }
        
        let path = endpoint.path.hasPrefix("/") ? String(endpoint.path.dropFirst()) : endpoint.path
        let fullURL = baseURL.appendingPathComponent(path)
        
        guard var components = URLComponents(url: fullURL, resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL
        }

        if let queryParameters = endpoint.queryParameters, !queryParameters.isEmpty {
            components.queryItems = queryParameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let bodyParameters = endpoint.bodyParameters {
            request.httpBody = try JSONEncoder().encode(bodyParameters)
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidURL
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        let decodedData = try JSONDecoder().decode(T.self, from: data)
        return decodedData
    }
}
