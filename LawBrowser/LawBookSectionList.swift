//
//  LawBookSectionList.swift
//  GermanLawsApp
//
//  Created by Noah Peeters on 01.06.20.
//  Copyright © 2020 Noah Peeters. All rights reserved.
//

import Foundation
import SwiftUI
import LawModel
import LawClient
import LawTextView

struct LawBookSectionList: View {
    @EnvironmentObject var apiClient: LawClient

    let lawListItem: LawBookListItem

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
            self.apiClient.fetchSections(for: self.lawListItem)
                .bind(output: self.$lawBook)
        }
        .navigationBarTitle(lawListItem.title)
    }
}

struct LawBookListContent: View {
    let section: LawBookSection

    var body: some View {
        Group {
            Section(header: header) {
                ForEach(section.laws) { lawListItem in
                    LawCell(lawListItem: lawListItem)
                }
            }

            ForEach(section.subsections) { subsection in
                LawBookListContent(section: subsection)
            }
        }
    }

    var header: some View {
        Text("\(section.sectionNumber.description) \(section.title)")
    }
}

struct LawCell: View {
    let lawListItem: LawListItem

    var body: some View {
        Group {
            if lawListItem.isCeased {
                Text(lawListItem.displayTitle)
                    .foregroundColor(.gray)
            } else {
                NavigationLink(destination: LawDetailView(lawListItem: lawListItem)) {
                    Text(lawListItem.displayTitle)
                }
            }
        }
    }
}

struct LawDetailView: View {
    @EnvironmentObject var apiClient: LawClient

    let lawListItem: LawListItem

    @State var law: Law?

    var body: some View {
        Group {
            law.map { law in
                LawTextView(lawText: law.text)
                    .edgesIgnoringSafeArea(.bottom)
            }
        }
        .navigationBarTitle(lawListItem.displayTitle)
        .onAppear {
            self.apiClient.fetchLaw(for: self.lawListItem)
                .bind(output: self.$law)
        }
    }
}

extension LawListItem: Identifiable {
    public var id: String {
        documentIdentifier.rawValue
    }
}

extension LawBookSection: Identifiable {
    public var id: String {
        documentIdentifier.rawValue
    }
}
