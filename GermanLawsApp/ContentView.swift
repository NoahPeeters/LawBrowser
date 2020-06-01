//
//  ContentView.swift
//  GermanLawsApp
//
//  Created by Noah Peeters on 30.05.20.
//  Copyright © 2020 Noah Peeters. All rights reserved.
//

import SwiftUI
import GermanLaws
import LawTextView

struct ContentView: View {
    var body: some View {
        NavigationView {
            LawBookList()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension String {
    static var exampleLawText: String {
        //swiftlint:disable line_length
        #"""
        {\rtf1\ansi{\fonttbl\f0\fswiss Helvetica;}\f0
        (1) Im Sinne dieses Gesetzes ist \

        \pard\tx1\tx401\li401\fi-401\
         1.\tab Angeh{\u0246}riger:wer zu den folgenden Personen geh{\u0246}rt:\
        \tab
        \pard\tx501\tx901\li901\fi-901\
        \tab a)\tab Verwandte und Verschw{\u0228}gerte gerader Linie, der Ehegatte, der Lebenspartner, der Verlobte, Geschwister, Ehegatten oder Lebenspartner der Geschwister, Geschwister der Ehegatten oder Lebenspartner, und zwar auch dann, wenn die Ehe oder die Lebenspartnerschaft, welche die Beziehung begr{\u0252}ndet hat, nicht mehr besteht oder wenn die Verwandtschaft oder Schw{\u0228}gerschaft erloschen ist,\
        \tab b)\tab Pflegeeltern und Pflegekinder;\
         2.\tab Amtstr{\u0228}ger:wer nach deutschem Recht\
        \tab
        \pard\tx501\tx901\li901\fi-901\
        \tab a)\tab Beamter oder Richter ist,\
        \tab b)\tab in einem sonstigen {\u0246}ffentlich-rechtlichen Amtsverh{\u0228}ltnis steht oder\
        \tab c)\tab sonst dazu bestellt ist, bei einer Beh{\u0246}rde oder bei einer sonstigen Stelle oder in deren Auftrag Aufgaben der {\u0246}ffentlichen Verwaltung unbeschadet der zur Aufgabenerf{\u0252}llung gew{\u0228}hlten Organisationsform wahrzunehmen;\
         2a.\tab Europ{\u0228}ischer Amtstr{\u0228}ger:wer \
        \tab
        \pard\tx501\tx901\li901\fi-901\
        \tab a)\tab Mitglied der Europ{\u0228}ischen Kommission, der Europ{\u0228}ischen Zentralbank, des Rechnungshofs oder eines Gerichts der Europ{\u0228}ischen Union ist,\
        \tab b)\tab Beamter oder sonstiger Bediensteter der Europ{\u0228}ischen Union oder einer auf der Grundlage des Rechts der Europ{\u0228}ischen Union geschaffenen Einrichtung ist oder\
        \tab c)\tab mit der Wahrnehmung von Aufgaben der Europ{\u0228}ischen Union oder von Aufgaben einer auf der Grundlage des Rechts der Europ{\u0228}ischen Union geschaffenen Einrichtung beauftragt ist;\
         3.\tab Richter:wer nach deutschem Recht Berufsrichter oder ehrenamtlicher Richter ist;\
         4.\tab f{\u0252}r den {\u0246}ffentlichen Dienst besonders Verpflichteter:wer, ohne Amtstr{\u0228}ger zu sein,\
        \tab
        \pard\tx501\tx901\li901\fi-901\
        \tab a)\tab bei einer Beh{\u0246}rde oder bei einer sonstigen Stelle, die Aufgaben der {\u0246}ffentlichen Verwaltung wahrnimmt, oder\
        \tab b)\tab bei einem Verband oder sonstigen Zusammenschlu{\u0223}, Betrieb oder Unternehmen, die f{\u0252}r eine Beh{\u0246}rde oder f{\u0252}r eine sonstige Stelle Aufgaben der {\u0246}ffentlichen Verwaltung ausf{\u0252}hren,besch{\u0228}ftigt oder f{\u0252}r sie t{\u0228}tig und auf die gewissenhafte Erf{\u0252}llung seiner Obliegenheiten auf Grund eines Gesetzes f{\u0246}rmlich verpflichtet ist;\
         5.\tab rechtswidrige Tat:nur eine solche, die den Tatbestand eines Strafgesetzes verwirklicht;\
         6.\tab Unternehmen einer Tat:deren Versuch und deren Vollendung;\
         7.\tab Beh{\u0246}rde:auch ein Gericht;\
         8.\tab Ma{\u0223}nahme:jede Ma{\u0223}regel der Besserung und Sicherung, die Einziehung und die Unbrauchbarmachung;\
         9.\tab Entgelt:jede in einem Verm{\u0246}gensvorteil bestehende Gegenleistung.(2) Vors{\u0228}tzlich im Sinne dieses Gesetzes ist eine Tat auch dann, wenn sie einen gesetzlichen Tatbestand verwirklicht, der hinsichtlich der Handlung Vorsatz voraussetzt, hinsichtlich einer dadurch verursachten besonderen Folge jedoch Fahrl{\u0228}ssigkeit ausreichen l{\u0228}{\u0223}t.(3) Den Schriften stehen Ton- und Bildtr{\u0228}ger, Datenspeicher, Abbildungen und andere Darstellungen in denjenigen Vorschriften gleich, die auf diesen Absatz verweisen.\
         {\b Fußnoten}}

        """#
    }
}
