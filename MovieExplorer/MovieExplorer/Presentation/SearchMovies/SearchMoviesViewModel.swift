//
//  SearchMoviesViewModel.swift
//  MovieExplorer
//
//

import Foundation
import Combine

@MainActor
final class SearchMoviesViewModel {
    
    @Published private(set) var searchResults: [SearchResult] = []
    
    private let searchMoviesUseCase: SearchMoviesUseCase
    private var searchTask: Task<Void, Never>?
    
    private let searchQuerySubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(searchMoviesUseCase: SearchMoviesUseCase) {
        self.searchMoviesUseCase = searchMoviesUseCase
        setupBindings()
    }
    
    private func setupBindings() {
        searchQuerySubject
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    func updateSearchQuery(_ query: String) {
        searchQuerySubject.send(query)
    }
    
    func clearSearchQuery() {
        searchTask?.cancel()
        searchResults = []
        searchQuerySubject.send("")
    }
    
    private func performSearch(query: String) {
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        searchTask = Task {
            do {
                let results = try await searchMoviesUseCase.execute(query: query)
                if !Task.isCancelled {
                    self.searchResults = results
                }
            } catch {
                if !Task.isCancelled {
                    self.searchResults = []
                }
            }
        }
    }
}
