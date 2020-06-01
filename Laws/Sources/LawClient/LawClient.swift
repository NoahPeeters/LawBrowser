//
//  File.swift
//  
//
//  Created by Noah Peeters on 01.06.20.
//

import Foundation
import Combine
import LawModel

public class LawClient {
    let baseURL: URL
    let cache: VersionedCache
    let urlSession: URLSession
    let jsonDecoder = JSONDecoder()

    public init(baseURL: URL, cache: VersionedCache, urlSession: URLSession) {
        self.baseURL = baseURL
        self.cache = cache
        self.urlSession = urlSession
    }

    private func fetch<Value: Codable>(_: Value.Type,
                                       path: String,
                                       cacheStrategy: CacheStrategy) -> AnyPublisher<Value, Error> {
        switch cacheStrategy {
        case .useCache:
            if let cacheValue = try? cache.load(Value.self, for: path) {
                return Just(cacheValue).setFailureType(to: Error.self).eraseToAnyPublisher()
            } else {
                return fetch(Value.self, path: path, cacheStrategy: .ignoreCache)
                    .handleEvents(receiveOutput: {
                        try? self.cache.store(value: $0, for: path)
                    })
                    .eraseToAnyPublisher()
            }
        case .ignoreCache:
            let url = baseURL.appendingPathComponent(path)
            return urlSession.dataTaskPublisher(for: url)
                .map(\.data)
                .decode(type: Value.self, decoder: jsonDecoder)
                .eraseToAnyPublisher()
        }
    }

    public func refreshMetadata() -> AnyPublisher<Void, Error> {
        fetch(APIMetadata.self, path: "metadata.json", cacheStrategy: .ignoreCache)
            .map {
                self.cache.versionID = $0.versionID
            }
            .eraseToAnyPublisher()
    }

    public func fetchBooks() -> AnyPublisher<LawBookList, Error> {
        fetch(LawBookList.self, path: "books.json", cacheStrategy: .useCache)
    }

    public func fetchSections(for lawBookListItem: LawBookListItem) -> AnyPublisher<LawBook, Error> {
        fetch(LawBook.self, path: lawBookListItem.documentIdentifier.filename, cacheStrategy: .useCache)
    }

    public func fetchLaw(for lawListItem: LawListItem) -> AnyPublisher<Law, Error> {
        fetch(Law.self, path: lawListItem.documentIdentifier.filename, cacheStrategy: .useCache)
    }
}

public enum CacheStrategy {
    case ignoreCache
    case useCache
}
