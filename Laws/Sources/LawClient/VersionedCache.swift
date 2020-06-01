import Foundation

public class VersionedCache {
    let baseURL: URL
    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()

    var versionID: Int

    public init(baseURL: URL, versionID: Int = 0) {
        self.baseURL = baseURL
        self.versionID = versionID
        jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    private func fileUrl(for key: String) -> URL {
        baseURL.appendingPathComponent(key)
    }

    func store<Value: Codable>(value: Value, for key: String) throws {
        let url = fileUrl(for: key)
        let entry = CacheEntry(versionID: versionID, value: value)
        let data = try self.jsonEncoder.encode(entry)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                withIntermediateDirectories: true,
                                                attributes: [:])
        try data.write(to: url)
    }

    func load<Value: Codable>(_: Value.Type, for key: String) throws -> Value? {
        let url = fileUrl(for: key)
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }

        let entry = try jsonDecoder.decode(CacheEntry<Value>.self, from: data)
        guard entry.versionID >= versionID else {
            // outdated
            try? FileManager.default.removeItem(at: url)
            return nil
        }

        return entry.value
    }
}

private struct CacheEntry<Value: Codable>: Codable {
    let versionID: Int
    let value: Value
}
