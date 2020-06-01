//
//  LawBookList.swift
//  GermanLawsApp
//
//  Created by Noah Peeters on 31.05.20.
//  Copyright © 2020 Noah Peeters. All rights reserved.
//

import Foundation
import SwiftUI
import GermanLaws
import CrawlerAPI
import ReactiveCombine

struct LawBookList: View {
    @EnvironmentObject var apiClient: CrawlerClient

    @State var items: [LawListItem] = []

    var body: some View {
        List(items) { item in
            NavigationLink(destination: LawBookSectionList(lawListItem: item)) {
                Text(item.title)
            }.isDetailLink(false)
        }
        .navigationBarTitle("Gesetzesbücher")
        .onAppear {
            self.apiClient.lawList().startWithResult {
                self.items = ((try? $0.get()) ?? []).sorted {
                    if $0.title == "Strafgesetzbuch" {
                        return true
                    } else if $1.title == "Strafgesetzbuch" {
                        return false
                    } else {
                        return $0.title < $1.title
                    }
                }
            }
        }
    }
}

extension LawListItem: Identifiable {
    public var id: String {
        url.absoluteString
    }
}
