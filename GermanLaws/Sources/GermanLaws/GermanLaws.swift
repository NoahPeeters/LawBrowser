import Foundation

public struct LawBook: Codable {
    public let identifier: String
    public let date: Date
    public let laws: [Law]

    public enum CodingKeys: String, CodingKey {
        case identifier = "doknr"
        case date = "builddate"
        case laws = "norm"
    }
}

public struct LawMetadata: Codable {
    let juridicalAbbreviation: String

    public enum CodingKeys: String, CodingKey {
        case juridicalAbbreviation = "jurabk"
    }
}

public struct Law: Codable {

}
