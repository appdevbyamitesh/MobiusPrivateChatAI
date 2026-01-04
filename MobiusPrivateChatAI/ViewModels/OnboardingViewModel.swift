//
//  OnboardingViewModel.swift
//  MobiusPrivateChatAI
//
//  Created by Amitesh Mani Tiwari on 21/05/25.
//  Updated: 20/07/25
//

import SwiftUI
import Combine

/// ViewModel for managing onboarding flow state and logic
/// Follows MVVM architecture pattern
@MainActor
class OnboardingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentPage = 0
    @Published var demoMessage = ""
    @Published var isDemoProcessing = false
    @Published var demoResponse = ""
    @Published var showingAirplaneModeDemo = false
    @Published var tutorialStep = 0
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constants
    let totalPages = 4
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    /// Navigate to next page in onboarding
    func nextPage() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPage = min(currentPage + 1, totalPages - 1)
        }
    }
    
    /// Navigate to previous page in onboarding
    func previousPage() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPage = max(currentPage - 1, 0)
        }
    }
    
    /// Run interactive demo with AI response simulation
    func runDemo() {
        guard !demoMessage.isEmpty else { return }
        
        isDemoProcessing = true
        demoResponse = ""
        
        // Simulate AI processing delay
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            await MainActor.run {
                demoResponse = generateDemoResponse()
                isDemoProcessing = false
            }
        }
    }
    
    /// Show airplane mode demo
    func showAirplaneModeDemo() {
        showingAirplaneModeDemo = true
    }
    
    /// Reset demo state
    func resetDemo() {
        demoMessage = ""
        demoResponse = ""
        isDemoProcessing = false
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Reset demo when page changes to demo page
        $currentPage
            .filter { $0 == 3 } // Demo page
            .sink { [weak self] _ in
                self?.resetDemo()
            }
            .store(in: &cancellables)
    }
    
    private func generateDemoResponse() -> String {
        let responses = [
            "This is a demonstration of on-device AI processing. Your message '\(demoMessage)' was processed locally without sending any data to external servers. The AI model runs entirely on your device using Core ML technology.",
            
            "Here's how on-device AI works: Your message '\(demoMessage)' is processed by a local language model stored on your device. No internet connection is required, and your data never leaves your device.",
            
            "Privacy-first AI response: '\(demoMessage)' was analyzed locally using Core ML. This demonstrates the power of on-device processing while maintaining complete privacy protection."
        ]
        
        return responses.randomElement() ?? responses[0]
    }
}

// MARK: - Onboarding Data Models
struct OnboardingPage {
    let id: Int
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

struct PrivacyBenefit {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct ProcessStep {
    let number: String
    let title: String
    let description: String
    let icon: String
    let color: Color
}

// MARK: - Onboarding Data
extension OnboardingViewModel {
    static let privacyBenefits = [
        PrivacyBenefit(
            icon: "wifi.slash",
            title: "No Internet Required",
            description: "All processing happens on your device, even in airplane mode",
            color: .green
        ),
        PrivacyBenefit(
            icon: "lock.shield",
            title: "Zero Data Transmission",
            description: "Your messages never leave your device or reach external servers",
            color: .blue
        ),
        PrivacyBenefit(
            icon: "eye.slash",
            title: "No Tracking",
            description: "No analytics, profiling, or surveillance of your conversations",
            color: .red
        ),
        PrivacyBenefit(
            icon: "brain.head.profile",
            title: "Local AI Processing",
            description: "Powerful AI capabilities running entirely on your device",
            color: .purple
        )
    ]
    
    static let processSteps = [
        ProcessStep(
            number: "1",
            title: "Type Your Message",
            description: "Enter your question or prompt in the chat interface",
            icon: "keyboard",
            color: .blue
        ),
        ProcessStep(
            number: "2",
            title: "Local Processing",
            description: "Your device processes the request using Core ML",
            icon: "brain.head.profile",
            color: .purple
        ),
        ProcessStep(
            number: "3",
            title: "Instant Response",
            description: "Get AI responses without any network delay",
            icon: "bolt.fill",
            color: .orange
        ),
        ProcessStep(
            number: "4",
            title: "Secure Storage",
            description: "Conversations are stored locally and encrypted",
            icon: "lock.fill",
            color: .green
        )
    ]
} 