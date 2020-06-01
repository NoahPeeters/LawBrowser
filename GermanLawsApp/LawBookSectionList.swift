//
//  LawBookSectionList.swift
//  GermanLawsApp
//
//  Created by Noah Peeters on 01.06.20.
//  Copyright © 2020 Noah Peeters. All rights reserved.
//

import Foundation
import SwiftUI
import CrawlerAPI
import GermanLaws
import LawTextView

struct LawBookSectionList: View {
    @EnvironmentObject var apiClient: CrawlerClient

    let lawListItem: LawListItem

    @State var lawBook: LawBook?

    var body: some View {
        List {
            lawBook.map { lawBook in
                ForEach(lawBook.sections) { section in
                    LawBookListContent(section: section)
                }
            }
        }
        .onAppear {
            self.apiClient.lawBook(for: self.lawListItem)
                .startWithResult {
                    self.lawBook = (try? $0.get())
                }
        }
        .navigationBarTitle(lawListItem.title)
    }
}

struct LawBookListContent: View {
    let section: LawBookSection

    var body: some View {
        Group {
            Section(header: header) {
                ForEach(section.laws) { law in
                    NavigationLink(law.displayTitle, destination: LawDetailView(law: law))
                }
            }

            ForEach(section.subsections) { subsection in
                LawBookListContent(section: subsection)
            }
        }
    }

    var header: some View {
        Text("\(section.sectionNumber.description) \(section.title)")
            .clipped()
            .cornerRadius(10)
            .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1)), radius: 5, x: 1, y: 5)
    }
}

struct LawDetailView: View {
    let law: Law

    var body: some View {
        LawTextView(lawText: law.text)
            .navigationBarTitle(law.displayTitle)
    }
}

extension Law: Identifiable {
    public var id: String? {
        metadata["documentIdentifier"]
    }

    public var displayTitle: String {
        [metadata["enbez"], metadata["titel"]]
            .compactMap { $0 }
        .joined(separator: " ")
    }
}

extension LawBookSection: Identifiable {
    public var id: [Int] {
        sectionNumber.numbers
    }
}
