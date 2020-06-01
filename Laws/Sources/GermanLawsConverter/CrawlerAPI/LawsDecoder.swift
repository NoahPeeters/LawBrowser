//
//  LawsDecoder.swift
//  
//
//  Created by Noah Peeters on 30.05.20.
//

import Foundation
import LawModel
#if canImport(FoundationXML)
import FoundationXML
#endif

public enum LawsDecoderError: Error {
    case parsingFailed
}

//swiftlint:disable type_body_length
public class LawsDecoder {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter
    }()

    public typealias Input = Data

    public func decode(from data: Data) throws -> LawDecoderResult {
        let parser = XMLParser(data: data)
        let delegate = ParserDelegate()
        parser.delegate = delegate
        parser.parse()

        if let error = parser.parserError {
            throw error
        }

        guard let result = delegate.result else {
            throw LawsDecoderError.parsingFailed
        }

        return result
    }

    public init() {}

    //swiftlint:disable type_body_length
    private class ParserDelegate: NSObject, XMLParserDelegate {
        let listBaseTabWidth = 100
        let listLevelTabWidth = 500
        let listExtraTabWidth = 500

        private var bookDocumentIdentifier: DocumentIdentifier?
        private var bookMetadata: [String: [String]]?
        private var bookSections: [LawBookSection] = []
        private var date: Date?
        private var sections: [MutableLawBookSection] = []
        private var laws: [Law] = []

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
        var metadata: [String: [String]] = [:]
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
                bookSections.append(section.nonMutable)
            }
        }

        func currentSection() -> MutableLawBookSection {
            if let last = sections.last {
                return last
            } else {
                let rawDocumentIdentifier = (bookDocumentIdentifier?.rawValue ?? "") + "Content"
                let documentIdentifier = DocumentIdentifier(rawValue: rawDocumentIdentifier)
                let section = MutableLawBookSection(documentIdentifier: documentIdentifier,
                                                    title: "Inhalt",
                                                    sectionNumber: SectionNumber(numbers: 1))
                sections.append(section)
                return section
            }
        }

        func completeNorm() {
            normText += "}"

            if bookMetadata == nil {
                bookMetadata = metadata
            } else if let rawDocumentIdentifier = metadata["documentIdentifier"]?.first,
                      let rawSectionNumber = metadata["gliederungseinheit.gliederungskennzahl"]?.first {
                      let sectionNumber = SectionNumber(string: rawSectionNumber)
                      let title = (metadata["gliederungseinheit.gliederungstitel"]?.first ??
                                   metadata["gliederungseinheit.gliederungsbez"]?.first ??
                                   "Unbenanter Abschnitt")
                    .components(separatedBy: .whitespacesAndNewlines).joined(separator: " ")

                while let last = sections.last, !sectionNumber.isSubsection(of: last.sectionNumber) {
                    flushSection()
                }
                let documentIdentifier = DocumentIdentifier(rawValue: rawDocumentIdentifier)
                sections.append(MutableLawBookSection(documentIdentifier: documentIdentifier,
                                                      title: title,
                                                      sectionNumber: sectionNumber))
            } else if let rawDocumentIdentifier = metadata["documentIdentifier"]?.first,
                      let title = metadata["titel"]?.first,
                      let paragraph = metadata["enbez"]?.first {
                let documentIdentifier = DocumentIdentifier(rawValue: rawDocumentIdentifier)
                currentSection().laws.append(LawListItem(documentIdentifier: documentIdentifier,
                                                         title: title,
                                                         paragraph: paragraph))
                laws.append(Law(documentIdentifier: documentIdentifier,
                                text: normText))
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

        // swiftlint:disable:next cyclomatic_complexity function_body_length
        func parser(_ parser: XMLParser,
                    didStartElement elementName: String,
                    namespaceURI: String?,
                    qualifiedName qName: String?,
                    attributes attributeDict: [String: String] = [:]) {
            let name = elementName.lowercased()

            switch (state, name) {
            case (.default, "dokumente"):
                bookDocumentIdentifier = attributeDict["doknr"].map(DocumentIdentifier.init(rawValue:))
                date = attributeDict["builddate"].flatMap(LawsDecoder.dateFormatter.date(from:))
                state = .document
            case (.document, "norm"):
                // clear everything
                normText = #"{\rtf1\ansi{\fonttbl\f0\fswiss Helvetica;}\f0\#n"#
                metadata = [
                    "documentIdentifier": attributeDict["doknr"],
                    "date": attributeDict["builddate"]
                    ].compactMapValues { $0 }.mapValues { [$0] }
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

        // swiftlint:disable:next cyclomatic_complexity function_body_length
        func parser(_ parser: XMLParser,
                    didEndElement elementName: String,
                    namespaceURI: String?,
                    qualifiedName qName: String?) {
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
                    metadata[key, default: []].append(currentMetadataValue)
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

        private var lawBook: LawBook? {
            guard let documentIdentifier = bookDocumentIdentifier else { return nil }

            return LawBook(documentIdentifier: documentIdentifier,
                           sections: bookSections)
        }

        private var lawBookListItem: LawBookListItem? {
            guard let documentIdentifier = bookDocumentIdentifier,
                  let documentMetadata = bookMetadata,
                  let title = documentMetadata["langue"]?.first,
                  let juraAbbreviation = documentMetadata["jurabk"]?.first,
                  let officeAbbreviation = documentMetadata["amtabk"]?.first,
                  let versionComments = documentMetadata["standangabe.standkommentar"] else { return nil }

            // TODO parse date + source

            return LawBookListItem(documentIdentifier: documentIdentifier,
                                   title: title,
                                   juraAbbreviation: juraAbbreviation,
                                   officeAbbreviation: officeAbbreviation,
                                   versionComments: versionComments,
                                   date: Date())
        }

        var result: LawDecoderResult? {
            guard let lawBook = lawBook, let lawBookListItem = lawBookListItem else { return nil }
            return LawDecoderResult(lawBookListItem: lawBookListItem, lawBook: lawBook, laws: laws)
        }
    }
}

private class MutableLawBookSection {
    let documentIdentifier: DocumentIdentifier
    let title: String
    let sectionNumber: SectionNumber
    var laws: [LawListItem] = []
    var subsections: [LawBookSection] = []

    init(documentIdentifier: DocumentIdentifier, title: String, sectionNumber: SectionNumber) {
        self.documentIdentifier = documentIdentifier
        self.title = title
        self.sectionNumber = sectionNumber
    }

    var nonMutable: LawBookSection {
        return LawBookSection(documentIdentifier: documentIdentifier,
                              title: title,
                              sectionNumber: sectionNumber,
                              laws: laws,
                              subsections: subsections)
    }
}

public struct LawDecoderResult {
    let lawBookListItem: LawBookListItem
    let lawBook: LawBook
    let laws: [Law]
}
