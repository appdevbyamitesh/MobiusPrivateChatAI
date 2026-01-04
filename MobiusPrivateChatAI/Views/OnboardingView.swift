//
//  OnboardingView.swift
//  MobiusPrivateChatAI
//
//  Created by Amitesh Mani Tiwari on 20/05/25.
//  Updated: 20/07/25
//

import SwiftUI

/// Onboarding flow that explains privacy benefits and demonstrates on-device AI functionality
struct OnboardingView: View {
    // MARK: - State
    @State private var currentPage = 0
    @State private var showingTutorial = false
    @State private var tutorialStep = 0
    @State private var demoMessage = ""
    @State private var isDemoProcessing = false
    @State private var demoResponse = ""
    @State private var showingAirplaneModeDemo = false
    
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Constants
    private let totalPages = 4
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.05),
                        Color(.systemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - Page Content
                    TabView(selection: $currentPage) {
                        // Page 1: Welcome
                        WelcomePage()
                            .tag(0)
                        
                        // Page 2: Privacy Benefits
                        PrivacyBenefitsPage()
                            .tag(1)
                        
                        // Page 3: How It Works
                        HowItWorksPage()
                            .tag(2)
                        
                        // Page 4: Interactive Demo
                        InteractiveDemoPage(
                            demoMessage: $demoMessage,
                            isDemoProcessing: $isDemoProcessing,
                            demoResponse: $demoResponse,
                            showingAirplaneModeDemo: $showingAirplaneModeDemo
                        )
                        .tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
                    
                    // MARK: - Bottom Controls
                    VStack(spacing: 20) {
                        // Page indicators
                        HStack(spacing: 8) {
                            ForEach(0..<totalPages, id: \.self) { index in
                                Circle()
                                    .fill(index == currentPage ? Color.blue : Color(.systemGray4))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: currentPage)
                            }
                        }
                        
                        // Navigation buttons
                        HStack(spacing: 16) {
                            if currentPage > 0 {
                                Button("Back") {
                                    withAnimation {
                                        currentPage -= 1
                                    }
                                }
                                .buttonStyle(SecondaryButtonStyle())
                            }
                            
                            Spacer()
                            
                            if currentPage < totalPages - 1 {
                                Button("Next") {
                                    withAnimation {
                                        currentPage += 1
                                    }
                                }
                                .buttonStyle(PrimaryButtonStyle())
                            } else {
                                Button("Get Started") {
                                    dismiss()
                                }
                                .buttonStyle(PrimaryButtonStyle())
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .sheet(isPresented: $showingTutorial) {
            TutorialView(tutorialStep: $tutorialStep)
        }
    }
}

// MARK: - Welcome Page
struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
            }
            .shadow(color: Color.blue.opacity(0.2), radius: 20, x: 0, y: 10)
            
            // Title and subtitle
            VStack(spacing: 16) {
                Text("Welcome to PrivateChat AI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Experience the future of AI conversations with complete privacy protection")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Privacy badge
            HStack(spacing: 12) {
                Image(systemName: "shield.checkered")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("100% On-Device Processing")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.green.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
            )
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Privacy Benefits Page
struct PrivacyBenefitsPage: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Title
            VStack(spacing: 16) {
                Text("Your Privacy Matters")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Discover why on-device AI is the future of private conversations")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Benefits list
            VStack(spacing: 20) {
                PrivacyBenefitRow(
                    icon: "wifi.slash",
                    title: "No Internet Required",
                    description: "All processing happens on your device, even in airplane mode",
                    color: .green
                )
                
                PrivacyBenefitRow(
                    icon: "lock.shield",
                    title: "Zero Data Transmission",
                    description: "Your messages never leave your device or reach external servers",
                    color: .blue
                )
                
                PrivacyBenefitRow(
                    icon: "eye.slash",
                    title: "No Tracking",
                    description: "No analytics, profiling, or surveillance of your conversations",
                    color: .red
                )
                
                PrivacyBenefitRow(
                    icon: "brain.head.profile",
                    title: "Local AI Processing",
                    description: "Powerful AI capabilities running entirely on your device",
                    color: .purple
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}

// MARK: - How It Works Page
struct HowItWorksPage: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Title
            VStack(spacing: 16) {
                Text("How It Works")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("See the magic behind on-device AI processing")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Process steps
            VStack(spacing: 24) {
                ProcessStepRow(
                    number: "1",
                    title: "Type Your Message",
                    description: "Enter your question or prompt in the chat interface",
                    icon: "keyboard",
                    color: .blue
                )
                
                ProcessStepRow(
                    number: "2",
                    title: "Local Processing",
                    description: "Your device processes the request using Core ML",
                    icon: "brain.head.profile",
                    color: .purple
                )
                
                ProcessStepRow(
                    number: "3",
                    title: "Instant Response",
                    description: "Get AI responses without any network delay",
                    icon: "bolt.fill",
                    color: .orange
                )
                
                ProcessStepRow(
                    number: "4",
                    title: "Secure Storage",
                    description: "Conversations are stored locally and encrypted",
                    icon: "lock.fill",
                    color: .green
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}

// MARK: - Interactive Demo Page
struct InteractiveDemoPage: View {
    @Binding var demoMessage: String
    @Binding var isDemoProcessing: Bool
    @Binding var demoResponse: String
    @Binding var showingAirplaneModeDemo: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Title
            VStack(spacing: 16) {
                Text("Try It Yourself")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Experience on-device AI processing in action")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Demo chat interface
            VStack(spacing: 16) {
                // Demo message input
                HStack {
                    TextField("Try: 'Explain quantum computing'", text: $demoMessage)
                        .textFieldStyle(.roundedBorder)
                        .disabled(isDemoProcessing)
                    
                    Button(action: runDemo) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(demoMessage.isEmpty ? .gray : .blue)
                    }
                    .disabled(demoMessage.isEmpty || isDemoProcessing)
                }
                .padding(.horizontal, 24)
                
                // Demo response area
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.green)
                            .font(.title3)
                        
                        Text("AI Assistant")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    
                    if isDemoProcessing {
                        HStack(spacing: 8) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(Color.green.opacity(0.6))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(1.0)
                                    .animation(
                                        Animation.easeInOut(duration: 0.6)
                                            .repeatForever()
                                            .delay(Double(index) * 0.2),
                                        value: isDemoProcessing
                                    )
                            }
                        }
                    } else if !demoResponse.isEmpty {
                        Text(demoResponse)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 24)
                .frame(minHeight: 100)
            }
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 24)
            
            // Airplane mode demo
            Button(action: { showingAirplaneModeDemo = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "airplane")
                        .font(.title3)
                    
                    Text("Test Airplane Mode")
                        .font(.headline)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                )
                .foregroundColor(.orange)
            }
            
            Spacer()
        }
        .sheet(isPresented: $showingAirplaneModeDemo) {
            AirplaneModeDemoView()
        }
    }
    
    private func runDemo() {
        guard !demoMessage.isEmpty else { return }
        
        isDemoProcessing = true
        demoResponse = ""
        
        // Simulate AI processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            demoResponse = "This is a demonstration of on-device AI processing. Your message '\(demoMessage)' was processed locally without sending any data to external servers. The AI model runs entirely on your device using Core ML technology."
            isDemoProcessing = false
        }
    }
}

// MARK: - Supporting Views
struct PrivacyBenefitRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

struct ProcessStepRow: View {
    let number: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text(number)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.title3)
                    
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.blue.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.blue)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Airplane Mode Demo
struct AirplaneModeDemoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var demoStep = 0
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()
                
                // Demo icon
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "airplane")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                }
                
                // Demo content
                VStack(spacing: 16) {
                    Text("Airplane Mode Test")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("This demonstrates that the app works completely offline")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                // Demo steps
                VStack(spacing: 16) {
                    DemoStepRow(
                        step: 1,
                        title: "Enable Airplane Mode",
                        description: "Turn on airplane mode in Settings",
                        isCompleted: demoStep >= 1
                    )
                    
                    DemoStepRow(
                        step: 2,
                        title: "Try the Chat",
                        description: "Send a message and see it work offline",
                        isCompleted: demoStep >= 2
                    )
                    
                    DemoStepRow(
                        step: 3,
                        title: "Verify Privacy",
                        description: "No data leaves your device",
                        isCompleted: demoStep >= 3
                    )
                }
                .padding(.horizontal, 24)
                
                if showingSuccess {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Success!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("The app works perfectly in airplane mode")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                // Demo button
                Button(action: runAirplaneModeDemo) {
                    Text(demoStep == 0 ? "Start Demo" : "Next Step")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.orange, Color.orange.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(demoStep >= 3)
            }
            .padding()
            .navigationTitle("Airplane Mode Demo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: demoStep)
        .animation(.easeInOut(duration: 0.3), value: showingSuccess)
    }
    
    private func runAirplaneModeDemo() {
        withAnimation {
            demoStep += 1
            
            if demoStep >= 3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        showingSuccess = true
                    }
                }
            }
        }
    }
}

struct DemoStepRow: View {
    let step: Int
    let title: String
    let description: String
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.green : Color(.systemGray4))
                    .frame(width: 32, height: 32)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    Text("\(step)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isCompleted ? .green : .primary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isCompleted ? Color.green.opacity(0.3) : Color(.systemGray4), lineWidth: 1)
                )
        )
    }
}

#Preview {
    OnboardingView()
} 