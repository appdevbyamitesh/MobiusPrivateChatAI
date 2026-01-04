//
//  Models.swift
//  MobiusPrivateChatAI
//
//  Created by Amitesh Mani Tiwari on 22/05/25.
//  Updated: 20/07/25
//

import Foundation
import CoreData

// MARK: - Message Model
/// Represents a chat message in the conversation
/// All messages are stored locally and never transmitted to external servers
struct Message: Identifiable, Equatable {
    let id: UUID
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    
    init(id: UUID = UUID(), content: String, isFromUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
    }
    
    /// Converts Core Data entity to Message model
    init(from entity: MessageEntity) {
        self.id = entity.id ?? UUID()
        self.content = entity.content ?? ""
        self.isFromUser = entity.isFromUser
        self.timestamp = entity.timestamp ?? Date()
    }
}

// MARK: - AI Response Model
/// Represents an AI-generated response with streaming capabilities
/// This simulates the response structure that would come from a Core ML model
struct AIResponse: Identifiable {
    let id: UUID
    let content: String
    let isComplete: Bool
    let tokensGenerated: Int
    let processingTime: TimeInterval
    
    init(id: UUID = UUID(), content: String, isComplete: Bool = false, tokensGenerated: Int = 0, processingTime: TimeInterval = 0) {
        self.id = id
        self.content = content
        self.isComplete = isComplete
        self.tokensGenerated = tokensGenerated
        self.processingTime = processingTime
    }
}

// MARK: - Privacy Metrics Model
/// Tracks privacy-related metrics to demonstrate the app's privacy-first approach
struct PrivacyMetrics: Equatable {
    let messagesProcessedLocally: Int
    let messagesSentToCloud: Int
    let onDeviceProcessingPercentage: Double
    let modelSizeMB: Double
    let memoryUsageMB: Double
    let processingSpeedTokensPerSecond: Double
    let batteryUsagePercentage: Double
    
    static let `default` = PrivacyMetrics(
        messagesProcessedLocally: 0,
        messagesSentToCloud: 0,
        onDeviceProcessingPercentage: 100.0,
        modelSizeMB: 245.8,
        memoryUsageMB: 12.3,
        processingSpeedTokensPerSecond: 15.7,
        batteryUsagePercentage: 2.1
    )
}

// MARK: - Model State
/// Represents the current state of the AI model
enum ModelState {
    case notLoaded
    case loading(progress: Double)
    case ready
    case processing
    case error(String)
}

// MARK: - Sample Prompts
/// Pre-defined sample prompts to showcase the AI's capabilities across different domains
struct SamplePrompts {
    static let prompts = [
        // Mobile Development Conference Prompts
        "Tell me about MobiusConf 2025",
        "How does on-device AI benefit mobile apps?",
        "Explain Core ML for mobile development",
        "What makes this different from cloud-based mobile AI?",
        
        // Mental Health & Therapy Domain
        "I'm feeling anxious about my job interview",
        "How can I manage stress at work?",
        "I'm struggling with motivation lately",
        
        // Career & Professional Development
        "Help me prepare for a salary negotiation",
        "What should I include in my resume?",
        "How can I advance my career in tech?",
        
        // Technology & AI Domain
        "Explain how Core ML works",
        "What is the Neural Engine?",
        "How does machine learning differ from AI?",
        
        // Creative Writing & Content
        "Write a haiku about privacy",
        "Create a short story about a robot learning to paint",
        "Help me brainstorm blog post ideas",
        
        // Education & Learning
        "Explain quantum computing in simple terms",
        "How can I learn Swift programming?",
        "What are the fundamentals of machine learning?",
        
        // Personal Development & Productivity
        "How can I build better habits?",
        "What are effective goal-setting strategies?",
        "How can I improve my productivity?",
        
        // Health & Wellness
        "What are some healthy morning routines?",
        "How can I improve my sleep quality?",
        "What exercises are good for stress relief?",
        
        // Relationship & Social
        "How can I improve communication with my partner?",
        "What are signs of a healthy relationship?",
        "How can I resolve conflicts better?",
        
        // Business & Entrepreneurship
        "How can I validate a startup idea?",
        "What are effective marketing strategies?",
        "How should I approach investors?",
        
        // General & Greetings
        "Hello, how are you today?",
        "What can you help me with?",
        "Tell me about your capabilities"
    ]
    
    // MARK: - Domain-Specific Prompt Categories
    static let privacyPrompts = [
        "How does on-device AI protect my privacy?",
        "What data is stored on my device?",
        "Can you explain the privacy guarantees?",
        "How is this different from ChatGPT?",
        "What happens to my conversations?"
    ]
    
    static let mentalHealthPrompts = [
        "I'm feeling anxious about my job interview",
        "How can I manage stress at work?",
        "I'm struggling with motivation lately",
        "What are some coping strategies for anxiety?",
        "How can I improve my mental health?"
    ]
    
    static let careerPrompts = [
        "Help me prepare for a salary negotiation",
        "What should I include in my resume?",
        "How can I advance my career in tech?",
        "How should I handle a difficult boss?",
        "What are good interview questions to ask?"
    ]
    
    static let technologyPrompts = [
        "Explain how Core ML works",
        "What is the Neural Engine?",
        "How does machine learning differ from AI?",
        "What are the benefits of on-device processing?",
        "How does quantization work?"
    ]
    
    static let creativePrompts = [
        "Write a haiku about privacy",
        "Create a short story about a robot learning to paint",
        "Help me brainstorm blog post ideas",
        "Write a poem about the future of technology",
        "Create a character for my novel"
    ]
} 

// MARK: - Performance Models
/// Performance metrics for tracking AI model performance
struct PerformanceMetrics {
    let averageResponseTime: Double
    let tokensPerSecond: Double
    let totalRequests: Int
    let successRate: Double
    
    init(
        averageResponseTime: Double = 0.0,
        tokensPerSecond: Double = 0.0,
        totalRequests: Int = 0,
        successRate: Double = 1.0
    ) {
        self.averageResponseTime = averageResponseTime
        self.tokensPerSecond = tokensPerSecond
        self.totalRequests = totalRequests
        self.successRate = successRate
    }
}

/// Benchmark result for performance testing
struct BenchmarkResult {
    let testName: String
    let responseTime: Double
    let tokensPerSecond: Double
    let success: Bool
    let timestamp: Date
} 
