import Foundation

public struct LawBook: Codable {
    public let documentIdentifier: DocumentIdentifier
    public let sections: [LawBookSection]

    public init(documentIdentifier: DocumentIdentifier, sections: [LawBookSection]) {
        self.documentIdentifier = documentIdentifier
        self.sections = sections
    }
}

public class LawBookSection: Codable {
    public let documentIdentifier: DocumentIdentifier
    public let title: String
    public let sectionNumber: SectionNumber
    public let laws: [LawListItem]
    public let subsections: [LawBookSection]

    public init(documentIdentifier: DocumentIdentifier,
                title: String,
                sectionNumber: SectionNumber,
                laws: [LawListItem],
                subsections: [LawBookSection]) {
        self.documentIdentifier = documentIdentifier
        self.title = title
        self.sectionNumber = sectionNumber
        self.laws = laws
        self.subsections = subsections
    }
}

public struct SectionNumber: Codable, CustomStringConvertible, RawRepresentable {
    public typealias RawValue = [Int]

    public let numbers: [Int]

    public var rawValue: [Int] {
        return numbers
    }

    public init(numbers: Int...) {
        self.numbers = numbers
    }

    public init(rawValue: [Int]) {
        self.numbers = rawValue
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

public struct LawListItem: Codable {
    public let documentIdentifier: DocumentIdentifier
    public let title: String
    public let paragraph: String

    public init(documentIdentifier: DocumentIdentifier, title: String, paragraph: String) {
        self.documentIdentifier = documentIdentifier
        self.title = title
        self.paragraph = paragraph
    }

    public var isCeased: Bool {
        paragraph.hasPrefix("(XXXX)") || title.hasSuffix("(weggefallen)")
    }

    private var displayParagraph: String {
        paragraph.replacingOccurrences(of: "(XXXX) ", with: "")
    }

    public var displayTitle: String {
        "\(self.displayParagraph) \(self.title)"
    }
}

public struct Law: Codable {
    public let documentIdentifier: DocumentIdentifier
    public let text: String

    public init(documentIdentifier: DocumentIdentifier, text: String) {
        self.documentIdentifier = documentIdentifier
        self.text = text
    }
}
