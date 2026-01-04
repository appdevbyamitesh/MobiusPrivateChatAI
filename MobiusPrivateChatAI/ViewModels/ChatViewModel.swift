//
//  ChatViewModel.swift
//  MobiusPrivateChatAI
//
//  Created by Amitesh Mani Tiwari on 21/05/25.
//  Updated: 20/07/25
//

import Foundation
import CoreData
import Combine

/// View Model for managing chat functionality using MVVM architecture
/// Handles message processing, Core Data persistence, and AI model integration
@MainActor
class ChatViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var messages: [Message] = []
    @Published var currentInput: String = ""
    @Published var isProcessing: Bool = false
    @Published var currentStreamingResponse: String = ""
    @Published var showSamplePrompts: Bool = false
    
    // MARK: - Dependencies
    private let aiModelManager: AIModelManager
    private let context: NSManagedObjectContext
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(aiModelManager: AIModelManager, context: NSManagedObjectContext) {
        self.aiModelManager = aiModelManager
        self.context = context
        
        setupBindings()
        loadMessages()
    }
    
    // MARK: - Setup
    /// Sets up reactive bindings for the AI model manager
    private func setupBindings() {
        aiModelManager.$modelState
            .sink { [weak self] state in
                switch state {
                case .ready:
                    self?.addWelcomeMessage()
                case .error(let message):
                    self?.addErrorMessage(message)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Message Management
    /// Sends a user message and generates AI response
    func sendMessage() {
        guard !currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = Message(content: currentInput, isFromUser: true)
        addMessage(userMessage)
        
        let userInput = currentInput
        currentInput = ""
        isProcessing = true
        currentStreamingResponse = ""
        
        Task {
            await generateAIResponse(for: userInput)
        }
    }
    
    /// Generates AI response using the on-device model
    private func generateAIResponse(for prompt: String) async {
        do {
            let responseStream = await aiModelManager.generateResponse(for: prompt)
            
            for await response in responseStream {
                currentStreamingResponse = response.content
                
                if response.isComplete {
                    let aiMessage = Message(content: response.content, isFromUser: false)
                    addMessage(aiMessage)
                    currentStreamingResponse = ""
                    isProcessing = false
                }
            }
        } catch {
            addErrorMessage("Failed to generate response: \(error.localizedDescription)")
            isProcessing = false
        }
    }
    
    /// Adds a message to the chat and persists it to Core Data
    private func addMessage(_ message: Message) {
        messages.append(message)
        saveMessageToCoreData(message)
    }
    
    /// Adds a welcome message when the model is ready
    private func addWelcomeMessage() {
        let welcomeMessage = Message(
            content: "Hello! I'm your MobiusConf 2025 demo AI assistant. 🎤 This is a specialized mobile development conference demo showcasing privacy-first AI running entirely on your device using Swift + Core ML. Perfect for mobile developers, architects, and DevOps teams! All conversations stay local - no cloud processing! How can I help you today?",
            isFromUser: false
        )
        
        if messages.isEmpty {
            addMessage(welcomeMessage)
        }
    }
    
    /// Adds an error message to the chat
    private func addErrorMessage(_ error: String) {
        let errorMessage = Message(
            content: "Sorry, I encountered an error: \(error). Please try again.",
            isFromUser: false
        )
        addMessage(errorMessage)
    }
    
    // MARK: - Core Data Operations
    /// Loads messages from Core Data
    private func loadMessages() {
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MessageEntity.timestamp, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            messages = entities.map { Message(from: $0) }
        } catch {
            print("Failed to load messages: \(error)")
        }
    }
    
    /// Saves a message to Core Data
    private func saveMessageToCoreData(_ message: Message) {
        let entity = MessageEntity(context: context)
        entity.id = message.id
        entity.content = message.content
        entity.isFromUser = message.isFromUser
        entity.timestamp = message.timestamp
        
        do {
            try context.save()
        } catch {
            print("Failed to save message: \(error)")
        }
    }
    
    /// Clears all messages from the chat
    func clearChat() {
        let request: NSFetchRequest<NSFetchRequestResult> = MessageEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            messages.removeAll()
        } catch {
            print("Failed to clear chat: \(error)")
        }
    }
    
    // MARK: - Sample Prompts
    /// Uses a sample prompt for quick testing
    func useSamplePrompt(_ prompt: String) {
        currentInput = prompt
        showSamplePrompts = false
    }
    
    /// Toggles the sample prompts view
    func toggleSamplePrompts() {
        showSamplePrompts.toggle()
    }
    
    // MARK: - Privacy Features
    /// Returns current privacy metrics
    var privacyMetrics: PrivacyMetrics {
        aiModelManager.privacyMetrics
    }
    
    /// Returns model information
    var modelInfo: String {
        aiModelManager.getModelInfo()
    }
    
    /// Runs a performance benchmark
    func runBenchmark() async -> (tokensPerSecond: Double, memoryUsage: Double) {
        return await aiModelManager.runBenchmark()
    }
} 