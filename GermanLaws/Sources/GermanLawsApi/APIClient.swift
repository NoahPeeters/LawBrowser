//
//  APIClient.swift
//  
//
//  Created by Noah Peeters on 30.05.20.
//

import Foundation
import Combine
import GermanLaws
import ZIPFoundation

enum APIClientError: Error {
    case failedToReadZIPArchive
    case zipFileDoesNotContainXMLFile
}

public class APIClient {
    private static let lawListURL = URL(string: "https://www.gesetze-im-internet.de/gii-toc.xml")!
    private static let lawListDecoder = LawListDecoder()
    private static let lawDecoder = LawsDecoder()

    private let urlSession: URLSession

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    private func urlRequest(for url: URL) -> URLRequest {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return URLRequest(url: url)
        }

        components.scheme = "https"

        guard let updatedURL = components.url else {
            return URLRequest(url: url)
        }

        return URLRequest(url: updatedURL)
    }

    private func unzipXMLFile(data: Data) -> AnyPublisher<Data, Error> {
        guard let archive = Archive(data: data, accessMode: .read, preferredEncoding: .utf8) else {
            return Fail(error: APIClientError.failedToReadZIPArchive).eraseToAnyPublisher()
        }

        guard let entry = archive.first(where: { $0.path.hasSuffix(".xml") }) else {
            return Fail(error: APIClientError.zipFileDoesNotContainXMLFile).eraseToAnyPublisher()
        }

        return Future { promise in
            do {
                _ = try archive.extract(entry) { data in
                    promise(.success(data))
                }
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }

    public func lawList() -> AnyPublisher<[LawListItem], Error> {
        urlSession.dataTaskPublisher(for: urlRequest(for: APIClient.lawListURL))
            .map(\.data)
            .decode(type: LawList.self, decoder: APIClient.lawListDecoder)
            .map(\.items)
            .eraseToAnyPublisher()
    }

    public func lawBook(for lawListItem: LawListItem) -> AnyPublisher<LawBook, Error> {
        urlSession.dataTaskPublisher(for: urlRequest(for: lawListItem.url))
            .map(\.data)
            .mapError { $0 }
            .flatMap { self.unzipXMLFile(data: $0) }
            .decode(type: LawBook.self, decoder: APIClient.lawDecoder)
            .eraseToAnyPublisher()
    }
}
