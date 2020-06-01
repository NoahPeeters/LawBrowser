//
//  ContentView.swift
//  GermanLawsApp
//
//  Created by Noah Peeters on 30.05.20.
//  Copyright © 2020 Noah Peeters. All rights reserved.
//

import SwiftUI
import LawModel
import LawTextView

struct ContentView: View {
    var body: some View {
        NavigationView {
            LawBookListView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
