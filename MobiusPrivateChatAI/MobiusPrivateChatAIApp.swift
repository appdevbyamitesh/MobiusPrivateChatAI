//
//  MobiusPrivateChatAIApp.swift
//  MobiusConf Demo App
//
//  Created by Amitesh Mani Tiwari on 20/05/25.
//  Updated: 20/07/25
//  Conference: MobiusConf 2025 - Privacy-First AI on iOS
//

import SwiftUI
import CoreData

@main
struct MobiusPrivateChatAIApp: App {
    // MARK: - Core Data Stack
    /// Persistent container for Core Data to store chat messages locally
    /// This ensures all data remains on-device and never leaves the user's device
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(.none) // Allow user to choose light/dark mode
        }
    }
}
