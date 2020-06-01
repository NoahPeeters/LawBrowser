import Foundation

public struct LawBook {
    public let documentIdentifier: String
    public let date: Date
    public let metadata: [String: String]
    public let sections: [LawBookSection]

    public init(documentIdentifier: String, date: Date, metadata: [String: String], sections: [LawBookSection]) {
        self.documentIdentifier = documentIdentifier
        self.date = date
        self.metadata = metadata
        self.sections = sections
    }
}

public class LawBookSection {
    public let title: String
    public let sectionNumber: SectionNumber
    public let laws: [Law]
    public let subsections: [LawBookSection]

    public init(title: String, sectionNumber: SectionNumber, laws: [Law], subsections: [LawBookSection]) {
        self.title = title
        self.sectionNumber = sectionNumber
        self.laws = laws
        self.subsections = subsections
    }
}

public struct SectionNumber: CustomStringConvertible {
    public let numbers: [Int]

    public init(numbers: Int...) {
        self.numbers = numbers
    }

    public init(string: String) {
        var numbers: [Int] = []

        var iterator = string.makeIterator()
        while let number1 = iterator.next(),
              let number2 = iterator.next(),
              let _ = iterator.next(),
              let number = Int("\(number1)\(number2)") {
                numbers.append(number)
        }

        self.numbers = numbers
    }

    public var description: String {
        numbers.map(String.init).joined(separator: ".")
    }

    public func isSubsection(of other: SectionNumber) -> Bool {
        Array(numbers.prefix(other.numbers.count)) == other.numbers
    }
}

public struct LawMetadata: Codable {
    let juridicalAbbreviation: String

    public enum CodingKeys: String, CodingKey {
        case juridicalAbbreviation = "jurabk"
    }
}

public struct Law {
    public let metadata: [String: String]
    public let text: String

    public init(metadata: [String: String], text: String) {
        self.metadata = metadata
        self.text = text
    }
}
