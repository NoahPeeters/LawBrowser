//
//  LawsDecoder.swift
//  
//
//  Created by Noah Peeters on 30.05.20.
//

import Foundation
import GermanLaws

public enum LawsDecoderError: Error {
    case parsingFailed
}

public class LawsDecoder {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter
    }()

    public typealias Input = Data

    public func decode(from data: Data) throws -> LawBook {
        let parser = XMLParser(data: data)
        let delegate = ParserDelegate()
        parser.delegate = delegate
        parser.parse()

        if let error = parser.parserError {
            throw error
        }

        guard let lawBook = delegate.lawBook else {
            throw LawsDecoderError.parsingFailed
        }

        return lawBook
    }

    public init() {}

    private class ParserDelegate: NSObject, XMLParserDelegate {
        let listBaseTabWidth = 100
        let listLevelTabWidth = 500
        let listExtraTabWidth = 500

        private var documentIdentifier: String?
        private var documentMetadata: [String: String]?
        private var documentSections: [LawBookSection] = []
        private var date: Date?
        private var sections: [MutableLawBookSection] = []

        enum State {
            case `default`
            case document
            case norm
            case ignoredNorm
            case metadata
            case textdata
            case text
            case content
        }

        var state = State.default

        var normText = "" {
            didSet {
                lastWasNewline = false
            }
        }
        var metadata: [String: String] = [:]
        var currentMetadataKey: [String] = []
        var currentMetadataValue = ""
        var indentLevel = 0
        var documentIndentLevel = -1
        var needsIndent = false
        var lastWasNewline = false

        var indentText: String {
            if indentLevel > 0 {
                return String(repeating: #"\tab"#, count: indentLevel * 2) + " "
            } else {
                return ""
            }
        }

        func flushSection() {
            guard let section = sections.popLast() else {
                return
            }

            if let last = sections.last {
                last.subsections.append(section.nonMutable)
            } else {
                documentSections.append(section.nonMutable)
            }
        }

        func currentSection() -> MutableLawBookSection {
            if let last = sections.last {
                return last
            } else {
                let section = MutableLawBookSection(title: "Inhalt", sectionNumber: SectionNumber(numbers: 1))
                sections.append(section)
                return section
            }
        }

        func completeNorm() {
            normText += "}"

            if documentMetadata == nil {
                documentMetadata = metadata
            } else if let rawSectionNumber = metadata["gliederungseinheit.gliederungskennzahl"] {
                let sectionNumber = SectionNumber(string: rawSectionNumber)
                let title = (metadata["gliederungseinheit.gliederungstitel"] ??
                             metadata["gliederungseinheit.gliederungsbez"] ??
                             "Unbenanter Abschnitt")
                    .components(separatedBy: .whitespacesAndNewlines).joined(separator: " ")

                while let last = sections.last, !sectionNumber.isSubsection(of: last.sectionNumber) {
                    flushSection()
                }
                sections.append(MutableLawBookSection(title: title, sectionNumber: sectionNumber))
            } else {
                currentSection().laws.append(Law(metadata: metadata, text: normText))
            }
        }

        func completeDocument() {
            while !sections.isEmpty {
                flushSection()
            }
        }

        func insertTab() {
            normText += #"\tab "#
        }

        func startNewParagraph(spacingBefore: Bool = false) {
            normText += #"\pard"#
            if indentLevel > 0 {
                let itemTabWidth = listBaseTabWidth + listLevelTabWidth * (indentLevel - 1)
                let textTabWidth = itemTabWidth + listExtraTabWidth
                normText += #"\tx\#(itemTabWidth)\tx\#(textTabWidth)\li\#(textTabWidth)\fi-\#(textTabWidth)"#
            }
            if spacingBefore {
                normText += #"\sb100"#
            }
            normText += #"\#n"#
        }

        func insertIndentationMarkersIfRequired() {
            if indentLevel != documentIndentLevel {
                documentIndentLevel = indentLevel
                startNewParagraph()
            }
        }

        func insertNewline(force: Bool = false) {
            guard !lastWasNewline || force else {
                insertIndentationMarkersIfRequired()
                return
            }
            needsIndent = true
            normText += #"\\#n"#
            insertIndentationMarkersIfRequired()
            lastWasNewline = true
        }

        func insertText(_ text: String) {
            if text.allSatisfy({ $0 == " " }) {
                return
            }

            if needsIndent {
                insertIndentationMarkersIfRequired()
                normText += indentText
                needsIndent = false
            }

            let encodedString = text.map { char in
                guard !char.isASCII else { return String(char) }

                return "{" + char.utf16.map { #"\u\#(String(format: "%04d", $0))"# }.joined() + "}"
            }.joined()
            normText += encodedString
        }

        func parser(_ parser: XMLParser, foundCharacters string: String) {
            switch state {
            case .text:
                insertText(string)
            case .metadata:
                currentMetadataValue += string
            default:
                break
            }
        }

        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            let name = elementName.lowercased()

            switch (state, name) {
            case (.default, "dokumente"):
                documentIdentifier = attributeDict["doknr"]
                date = attributeDict["builddate"].flatMap { LawsDecoder.dateFormatter.date(from: $0) }
                state = .document
            case (.document, "norm"):
                // clear everything
                normText = #"{\rtf1\ansi{\fonttbl\f0\fswiss Helvetica;}\f0\#n"#
                metadata = [:]
                metadata["documentIdentifier"] = attributeDict["doknr"]
                metadata["data"] = attributeDict["builddate"]
                state = .norm
                documentIndentLevel = -1
                indentLevel = 0
                needsIndent = false
            case (.ignoredNorm, _):
                break
            case (.norm, "metadaten"):
                state = .metadata
            case (.metadata, let key):
                currentMetadataKey.append(key)
                currentMetadataValue = ""
            case (.norm, "textdaten"):
                state = .textdata
            case (.textdata, "text"):
                state = .text
            case (.textdata, "fussnoten"):
                state = .text
                insertNewline(force: true)
                normText += #"{\b "#
                insertText("Fußnoten")
                normText += #"}"#
            case (.text, "i"):
                normText += #"{\i "#
            case (.text, "dl"):
                indentLevel += 1
                insertNewline()
            case (.text, "dt"):
                insertTab()
                needsIndent = false
            case (.text, "dd"):
                insertTab()
            case (.text, "p"):
                startNewParagraph(spacingBefore: true)
            case (.text, "br"):
                insertNewline(force: true)
            case (.text, "la"), (.text, "content"), (.text, "abwformat"), (.text, "pre"):
                break
            default:
                print("unknown start element \(name) for state \(state)")
            }
        }

        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            let name = elementName.lowercased()

            switch (state, name) {
            case (.document, "dokumente"):
                completeDocument()
                state = .default
            case (.norm, "norm"):
                completeNorm()
                state = .document
            case (.ignoredNorm, "norm"):
                state = .document
            case (.ignoredNorm, _):
                break
            case (.metadata, "metadaten"):
                state = .norm
            case (.metadata, currentMetadataKey.last):
                let key = currentMetadataKey.joined(separator: ".")
                currentMetadataKey.removeLast()
                // Do not parse toc
                if key == "enbez" && currentMetadataValue == "Inhaltsübersicht" {
                    state = .ignoredNorm
                    break
                }

                if !currentMetadataValue.isEmpty {
                    metadata[key] = currentMetadataValue
                    currentMetadataValue = ""
                }
            case (.textdata, "textdaten"):
                state = .norm
            case (.text, "text"):
                state = .textdata
            case (.text, "fussnoten"):
                state = .textdata
            case (.text, "i"):
                normText += #"}"#
            case (.text, "dl"):
                indentLevel -= 1
            case (.text, "dt"):
                break
            case (.text, "dd"):
                break
            case (.text, "p"):
                insertNewline()
            case (.text, "la"):
                insertNewline()
            case (.text, "content"), (.text, "abwformat"), (.text, "br"), (.text, "pre"):
                break
            default:
                print("unknown end element \(name) for state \(state)")
            }
        }

        var lawBook: LawBook? {
            guard let documentIdentifier = documentIdentifier,
                  let documentMetadata = documentMetadata,
                  let date = date else { return nil }

            return LawBook(documentIdentifier: documentIdentifier,
                           date: date,
                           metadata: documentMetadata,
                           sections: documentSections)
        }
    }
}

private class MutableLawBookSection {
    let title: String
    let sectionNumber: SectionNumber
    var laws: [Law] = []
    var subsections: [LawBookSection] = []

    init(title: String, sectionNumber: SectionNumber) {
        self.title = title
        self.sectionNumber = sectionNumber
    }

    var nonMutable: LawBookSection {
        return LawBookSection(
            title: title,
            sectionNumber: sectionNumber,
            laws: laws,
            subsections: subsections)
    }
}

public struct LawBook {
    public let documentIdentifier: String
    public let date: Date
    public let metadata: [String: String]
    public let sections: [LawBookSection]
}

public struct LawBookSection {
    public let title: String
    public let sectionNumber: SectionNumber
    public let laws: [Law]
    public let subsections: [LawBookSection]
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
}
