//
//  SettingsView.swift
//  MobiusPrivateChatAI
//
//  Created by Amitesh Mani Tiwari on 20/05/25.
//  Updated: 20/07/25
//

import SwiftUI

/// Settings view for app configuration and privacy features
/// Provides options for customizing the AI experience while maintaining privacy
struct SettingsView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingPrivacyPolicy = false
    @State private var showingAbout = false
    @State private var showingClearChatAlert = false
    @State private var showingOnboarding = false
    
    // MARK: - App Settings
    @AppStorage("enableHapticFeedback") private var enableHapticFeedback = true
    @AppStorage("enableSoundEffects") private var enableSoundEffects = false
    @AppStorage("autoScrollToBottom") private var autoScrollToBottom = true
    @AppStorage("showTypingIndicator") private var showTypingIndicator = true
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            List {
                // MARK: - Privacy Section
                Section("Privacy & Security") {
                    PrivacySettingsRow(
                        icon: "shield.checkered",
                        title: "Privacy Policy",
                        subtitle: "Learn about our privacy-first approach",
                        action: { showingPrivacyPolicy = true }
                    )
                    
                    PrivacySettingsRow(
                        icon: "lock.shield",
                        title: "Data Management",
                        subtitle: "Manage your local data",
                        action: { showingClearChatAlert = true }
                    )
                    
                    PrivacySettingsRow(
                        icon: "wifi.slash",
                        title: "Offline Mode",
                        subtitle: "Always enabled - no internet required",
                        isEnabled: true
                    )
                }
                
                // MARK: - AI Model Section
                Section("AI Model") {
                    ModelSettingsRow(
                        icon: "brain.head.profile",
                        title: "Model Information",
                        subtitle: viewModel.modelInfo.components(separatedBy: "\n").first ?? "Quantized Language Model",
                        action: { showingAbout = true }
                    )
                    
                    ModelSettingsRow(
                        icon: "memorychip",
                        title: "Memory Usage",
                        subtitle: String(format: "%.1f MB", viewModel.privacyMetrics.memoryUsageMB),
                        isEnabled: true
                    )
                    
                    ModelSettingsRow(
                        icon: "speedometer",
                        title: "Processing Speed",
                        subtitle: String(format: "%.1f tokens/second", viewModel.privacyMetrics.processingSpeedTokensPerSecond),
                        isEnabled: true
                    )
                }
                
                // MARK: - Interface Section
                Section("Interface") {
                    Toggle(isOn: $enableHapticFeedback) {
                        SettingsRow(
                            icon: "hand.tap",
                            title: "Haptic Feedback",
                            subtitle: "Vibrate on interactions"
                        )
                    }
                    
                    Toggle(isOn: $enableSoundEffects) {
                        SettingsRow(
                            icon: "speaker.wave.2",
                            title: "Sound Effects",
                            subtitle: "Play sounds for notifications"
                        )
                    }
                    
                    Toggle(isOn: $autoScrollToBottom) {
                        SettingsRow(
                            icon: "arrow.down",
                            title: "Auto-scroll",
                            subtitle: "Scroll to new messages"
                        )
                    }
                    
                    Toggle(isOn: $showTypingIndicator) {
                        SettingsRow(
                            icon: "ellipsis.bubble",
                            title: "Typing Indicator",
                            subtitle: "Show when AI is thinking"
                        )
                    }
                }
                
                // MARK: - Demo Features Section
                Section("Demo Features") {
                    DemoFeatureRow(
                        icon: "airplane",
                        title: "Airplane Mode Test",
                        subtitle: "Verify offline functionality",
                        action: simulateAirplaneMode
                    )
                    
                    DemoFeatureRow(
                        icon: "chart.bar",
                        title: "Performance Test",
                        subtitle: "Run model benchmarks",
                        action: runPerformanceTest
                    )
                    
                    DemoFeatureRow(
                        icon: "sparkles",
                        title: "View Onboarding",
                        subtitle: "Replay the privacy tutorial",
                        action: showOnboarding
                    )
                }
                
                // MARK: - About Section
                Section("About") {
                    AboutRow(
                        icon: "info.circle",
                        title: "About MobiusConf Demo",
                        subtitle: "Version 1.0.0",
                        action: { showingAbout = true }
                    )
                    
                    AboutRow(
                        icon: "heart",
                        title: "Made with ❤️",
                        subtitle: "Privacy-first AI for everyone",
                        isEnabled: true
                    )
                }
            }
            .navigationTitle("MobiusConf Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingOnboarding) {
            OnboardingView()
        }
        .alert("Clear Chat History", isPresented: $showingClearChatAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                viewModel.clearChat()
            }
        } message: {
            Text("This will permanently delete all your chat messages. This action cannot be undone.")
        }
    }
    
    // MARK: - Helper Methods
    private func simulateAirplaneMode() {
        // Simulate airplane mode test
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Show a temporary notification
        // In a real app, you might show a toast or alert
    }
    
    private func runPerformanceTest() {
        Task {
            let results = await viewModel.runBenchmark()
            await MainActor.run {
                // Show results in a toast or alert
                print("Benchmark results: \(results)")
            }
        }
    }
    
    private func showOnboarding() {
        showingOnboarding = true
    }
}

// MARK: - Settings Row Components
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct PrivacySettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: (() -> Void)?
    let isEnabled: Bool
    
    init(icon: String, title: String, subtitle: String, action: (() -> Void)? = nil, isEnabled: Bool = false) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.isEnabled = isEnabled
    }
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(isEnabled ? .green : .blue)
                    .font(.title3)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isEnabled {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                } else if action != nil {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
        .disabled(action == nil)
    }
}

struct ModelSettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: (() -> Void)?
    let isEnabled: Bool
    
    init(icon: String, title: String, subtitle: String, action: (() -> Void)? = nil, isEnabled: Bool = false) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.isEnabled = isEnabled
    }
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.purple)
                    .font(.title3)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isEnabled {
                    Image(systemName: "info.circle")
                        .foregroundColor(.purple)
                        .font(.title3)
                } else if action != nil {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
        .disabled(action == nil)
    }
}

struct DemoFeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.orange)
                    .font(.title3)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "play.circle")
                    .foregroundColor(.orange)
                    .font(.title3)
            }
        }
    }
}

struct AboutRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: (() -> Void)?
    let isEnabled: Bool
    
    init(icon: String, title: String, subtitle: String, action: (() -> Void)? = nil, isEnabled: Bool = false) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.isEnabled = isEnabled
    }
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.red)
                    .font(.title3)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !isEnabled && action != nil {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
        .disabled(action == nil)
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Policy")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Last updated: January 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Group {
                        Text("Your Privacy is Our Priority")
                            .font(.headline)
                        
                        Text("PrivateChat AI is built with privacy-first principles. We believe that your conversations should remain private and under your control.")
                        
                        Text("Key Privacy Features:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• All processing happens on your device")
                            Text("• No data is sent to external servers")
                            Text("• No user tracking or analytics")
                            Text("• No cloud storage of conversations")
                            Text("• Works completely offline")
                        }
                        
                        Text("Data Storage")
                            .font(.headline)
                        
                        Text("Your chat messages are stored locally on your device using Core Data. This data is encrypted and never transmitted to any external servers.")
                        
                        Text("Model Processing")
                            .font(.headline)
                        
                        Text("The AI model runs entirely on your device using Apple's Core ML framework. All text generation happens locally, ensuring complete privacy.")
                        
                        Text("No Third-Party Services")
                            .font(.headline)
                        
                        Text("We do not use any third-party services, analytics, or tracking tools. Your data never leaves your device.")
                    }
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - About View
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App Icon
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    // App Name and Version
                    VStack(spacing: 8) {
                        Text("PrivateChat AI")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About")
                            .font(.headline)
                        
                        Text("PrivateChat AI is a demonstration of privacy-first artificial intelligence. Built with SwiftUI and Core ML, this app showcases how AI can be powerful while respecting user privacy.")
                        
                        Text("Features")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• On-device AI processing")
                            Text("• Complete privacy protection")
                            Text("• Modern SwiftUI interface")
                            Text("• Core ML integration")
                            Text("• Local data storage")
                            Text("• Offline functionality")
                        }
                        
                        Text("Technology")
                            .font(.headline)
                        
                        Text("Built with Swift 5.9+, iOS 17+, SwiftUI, Core ML, and Core Data. Optimized for Apple Silicon devices.")
                        
                        Text("Privacy Commitment")
                            .font(.headline)
                        
                        Text("This app demonstrates that AI can be both powerful and private. No data leaves your device, no tracking, no surveillance.")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView(viewModel: ChatViewModel(
        aiModelManager: AIModelManager(),
        context: PersistenceController.preview.container.viewContext
    ))
} 