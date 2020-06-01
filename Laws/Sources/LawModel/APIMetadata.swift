import Foundation

public struct APIMetadata: Codable {
    public let versionID: Int

    public init(date: Date) {
        self.versionID  = Int(date.timeIntervalSince1970)
    }
}

public struct DocumentIdentifier: RawRepresentable, Codable {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public var filename: String {
        let prefixLength = min(20, rawValue.count - 1)
        let lookupPrefix = rawValue.prefix(prefixLength).map(String.init).joined(separator: "/")
        let nameSuffix = rawValue.dropFirst(prefixLength)

        return "document/\(lookupPrefix)/\(nameSuffix).json"
    }
}
