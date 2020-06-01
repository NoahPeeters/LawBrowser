import Foundation

public struct LawBookList: Codable {
    public let items: [LawBookListItem]

    public init(items: [LawBookListItem]) {
        self.items = items
    }
}

public struct LawBookListItem: Codable {
    public let documentIdentifier: DocumentIdentifier
    public let title: String
    public let juraAbbreviation: String
    public let officeAbbreviation: String
    public let versionComments: [String]
    public let date: Date

    public init(documentIdentifier: DocumentIdentifier,
                title: String,
                juraAbbreviation: String,
                officeAbbreviation: String,
                versionComments: [String],
                date: Date) {
        self.documentIdentifier = documentIdentifier
        self.title = title
        self.juraAbbreviation = juraAbbreviation
        self.officeAbbreviation = officeAbbreviation
        self.versionComments = versionComments
        self.date = date
    }
}
