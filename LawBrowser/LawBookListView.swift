//
//  LawBookList.swift
//  GermanLawsApp
//
//  Created by Noah Peeters on 31.05.20.
//  Copyright © 2020 Noah Peeters. All rights reserved.
//

import Foundation
import SwiftUI
import LawModel
import LawClient

struct LawBookListView: View {
    @EnvironmentObject var apiClient: LawClient

    @State var bookList: LawBookList?

    var items: [LawBookListItem] {
        bookList?.items ?? []
    }

    var body: some View {
        List(items) { item in
            NavigationLink(destination: LawBookSectionList(lawListItem: item)) {
                LawBookCell(lawBookListItem: item)
            }.isDetailLink(false)
        }
        .navigationBarTitle("Gesetzesbücher")
        .onAppear {
            self.apiClient.fetchBooks()
                .bind(output: self.$bookList)
        }
    }
}

struct LawBookCell: View {
    let lawBookListItem: LawBookListItem

    var body: some View {
        VStack(alignment: .leading) {
            Text(lawBookListItem.juraAbbreviation)
                .font(.title)
            Text(lawBookListItem.title)
        }
    }
}

extension LawBookListItem: Identifiable {
    public var id: String {
        documentIdentifier.rawValue
    }
}
