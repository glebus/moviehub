//
//  moviehubApp.swift
//  moviehub
//
//  Created by GlebUs on 24/01/2026.
//

import SwiftUI

@main
struct moviehubApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootTabView(container: container)
        }
    }
}
