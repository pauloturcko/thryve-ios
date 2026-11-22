//
//  thryve_appApp.swift
//  thryve-app
//
//  Created by Paulo Turco on 21/11/26.
//

import SwiftUI

@main
struct thryve_appApp: App {
    @State private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
        }
    }
}
