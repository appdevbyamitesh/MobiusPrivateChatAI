//
//  PersistenceController.swift
//  MobiusPrivateChatAI
//
//  Created by Amitesh Mani Tiwari on 20/07/25.
//

import CoreData
import Foundation

/// Core Data persistence controller for storing chat messages locally
/// This ensures complete privacy by keeping all data on-device
struct PersistenceController {
    // MARK: - Singleton
    static let shared = PersistenceController()
    
    // MARK: - Core Data Stack
    /// Persistent container that manages the Core Data stack
    /// All data is stored locally on the device, never transmitted to external servers
    let container: NSPersistentContainer
    
    // MARK: - Initialization
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PrivateChatAIModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                // In a production app, you would want to handle this error more gracefully
                // For demo purposes, we'll print the error
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        // Enable automatic merging of changes from parent contexts
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Preview Helper
    /// Creates a preview container for SwiftUI previews
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample data for previews
        let sampleMessage = MessageEntity(context: viewContext)
        sampleMessage.id = UUID()
        sampleMessage.content = "Hello! I'm your private AI assistant. All our conversations stay on your device."
        sampleMessage.isFromUser = false
        sampleMessage.timestamp = Date()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Preview save error: \(nsError)")
        }
        
        return result
    }()
} 