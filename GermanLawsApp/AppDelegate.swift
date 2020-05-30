//
//  AppDelegate.swift
//  GermanLawsApp
//
//  Created by Noah Peeters on 30.05.20.
//  Copyright © 2020 Noah Peeters. All rights reserved.
//

import UIKit
import GermanLaws
import GermanLawsApi
import Combine

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var cancellables: [AnyCancellable] = []

    let api = APIClient()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        api.lawList()
            .flatMap {
                self.api.lawBook(for: $0.first!)
            }
            .sink(receiveCompletion: {
                print($0)
            }, receiveValue: {
                print($0)
            })
            .store(in: &cancellables)

//        Just(exampleLaws)
//            .compactMap { $0.data(using: .utf8) }
//            .decode(type: LawBook.self, decoder: parser)
//            .sink(receiveCompletion: {
//                print($0)
//            }, receiveValue: {
//                print($0)
//            })
//            .store(in: &cancellables)

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

