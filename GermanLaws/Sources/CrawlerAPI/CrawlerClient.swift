//
//  CrawlerClient.swift
//  
//
//  Created by Noah Peeters on 30.05.20.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import ReactiveSwift
import GermanLaws
import ZIPFoundation

enum APIClientError: Error {
    case failedToReadZIPArchive
    case zipFileDoesNotContainXMLFile
}

public class CrawlerClient {
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

    private func unzipXMLFile(data: Data) -> SignalProducer<Data, Error> {
        guard let archive = Archive(data: data, accessMode: .read, preferredEncoding: .utf8) else {
            return SignalProducer(error: APIClientError.failedToReadZIPArchive)
        }

        guard let entry = archive.first(where: { $0.path.hasSuffix(".xml") }) else {
            return SignalProducer(error: APIClientError.zipFileDoesNotContainXMLFile)
        }

        return SignalProducer { observer, _ in
            do {
                var uncompressedData = Data(capacity: entry.uncompressedSize)
                _ = try archive.extract(entry) { chunk in
                    uncompressedData += chunk
                }

                observer.send(value: uncompressedData)
                observer.sendCompleted()
            } catch {
                observer.send(error: error)
            }
        }
    }

    public func lawList() -> SignalProducer<[LawListItem], Error> {
        urlSession.reactive.data(with: urlRequest(for: CrawlerClient.lawListURL))
            .map(\.0)
            .attemptMap { data in
                try CrawlerClient.lawListDecoder.decode(LawList.self, from: data)
            }
            .map(\.items)
    }

    public func lawBook(for lawListItem: LawListItem) -> SignalProducer<LawBook, Error> {
        urlSession.reactive.data(with: urlRequest(for: lawListItem.url))
            .map(\.0)
            .flatMap(.concat, unzipXMLFile(data:))
            .attemptMap { data in
                try CrawlerClient.lawDecoder.decode(from: data)
            }
    }
}
