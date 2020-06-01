import Foundation
import LawModel
import ReactiveSwift

class Converter {
    let baseOutputURL: URL
    let jsonEncoder = JSONEncoder()
    let crawler = CrawlerClient()

    init(baseOutputURL: URL) {
        self.baseOutputURL = baseOutputURL
        jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    private func storeFile(data: Data, path: String) -> SignalProducer<Void, Error> {
        let url = baseOutputURL.appendingPathComponent(path)

        return SignalProducer {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true,
                                                    attributes: [:])
            try data.write(to: url)
        }
    }

    private func storeEncodable<T: Encodable>(_ value: T, path: String) -> SignalProducer<Void, Error> {
        SignalProducer {
            try self.jsonEncoder.encode(value)
        }.flatMap(.concat) {
            self.storeFile(data: $0, path: path)
        }
    }

    let whitelistLaws = ["Strafgesetzbuch", "Bürgerliches Gesetzbuch"]

    func handle(decodeResult: LawDecoderResult) -> SignalProducer<LawBookListItem, Error> {
        self.storeEncodable(decodeResult.lawBook, path: decodeResult.lawBookListItem.documentIdentifier.filename)
            .flatMap(.concat) { SignalProducer(decodeResult.laws) }
            .flatMap(.concat) { self.storeEncodable($0, path: $0.documentIdentifier.filename) }
            .then(SignalProducer(value: decodeResult.lawBookListItem))
    }

    func run() -> SignalProducer<Void, Error> {
        storeMetadata()
            .then(crawler.lawList())
            .flatMap(.concat) { SignalProducer($0) }
            .filter { self.whitelistLaws.contains($0.title) }
            .flatMap(.concat, crawler.lawBook(for:))
            .flatMap(.concat, handle(decodeResult:))
            .collect()
            .map { LawBookList(items: $0) }
            .flatMap(.concat) {
                self.storeEncodable($0, path: "books.json")
            }
    }
}

extension Converter {
    func storeMetadata() -> SignalProducer<Void, Error> {
        storeEncodable(APIMetadata(date: Date()),
                       path: "metadata.json")
    }
}
