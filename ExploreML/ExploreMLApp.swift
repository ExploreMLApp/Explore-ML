//
//  ExploreMLApp.swift
//  Explore ML
//
//  Created by Axel Martinez. 
//

import SwiftUI

@main
struct ExploreMLApp: App {
    @State private var clearTriggered = false

    var body: some Scene {
        WindowGroup {
            ContentView(clearTriggered: $clearTriggered)
        }
        .commands {
            CommandGroup(after: .pasteboard) {
                Button(action: {
                    print("clear")
                    self.clearTriggered.toggle()
                }) {
                    Text("Clear Output")
                }
                .keyboardShortcut(.delete, modifiers: [.command])
            }
        }
    }
}
