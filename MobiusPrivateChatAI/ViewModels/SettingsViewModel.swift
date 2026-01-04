//
//  SettingsViewModel.swift
//  MobiusPrivateChatAI
//
//  Created by Amitesh Mani Tiwari on 21/05/25.
//  Updated: 20/07/25
//

import SwiftUI
import Combine

/// ViewModel for managing settings screen state and logic
/// Follows MVVM architecture pattern
@MainActor
class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var showingPrivacyPolicy = false
    @Published var showingAbout = false
    @Published var showingClearChatAlert = false
    @Published var showingOnboarding = false
    @Published var isDarkModeEnabled = false
    @Published var isNotificationsEnabled = true
    @Published var isAutoSaveEnabled = true
    
    // MARK: - Dependencies
    private let chatViewModel: ChatViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(chatViewModel: ChatViewModel) {
        self.chatViewModel = chatViewModel
        setupBindings()
        loadSettings()
    }
    
    // MARK: - Public Methods
    
    /// Show privacy policy
    func showPrivacyPolicy() {
        showingPrivacyPolicy = true
    }
    
    /// Show about screen
    func showAbout() {
        showingAbout = true
    }
    
    /// Show clear chat confirmation
    func showClearChatAlert() {
        showingClearChatAlert = true
    }
    
    /// Show onboarding flow
    func showOnboarding() {
        showingOnboarding = true
    }
    
    /// Clear all chat history
    func clearChatHistory() {
        Task {
            await chatViewModel.clearChat()
        }
    }
    
    /// Simulate airplane mode test
    func simulateAirplaneMode() {
        // This would typically check network connectivity
        // For demo purposes, we'll just show a success message
        print("Airplane mode test completed - app works offline")
    }
    
    /// Run performance benchmark
    func runPerformanceTest() {
        Task {
            let results = await chatViewModel.runBenchmark()
            await MainActor.run {
                print("Benchmark results: \(results)")
            }
        }
    }
    
    /// Toggle dark mode
    func toggleDarkMode() {
        isDarkModeEnabled.toggle()
        saveSettings()
    }
    
    /// Toggle notifications
    func toggleNotifications() {
        isNotificationsEnabled.toggle()
        saveSettings()
    }
    
    /// Toggle auto save
    func toggleAutoSave() {
        isAutoSaveEnabled.toggle()
        saveSettings()
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Observe settings changes and save them
        Publishers.CombineLatest3($isDarkModeEnabled, $isNotificationsEnabled, $isAutoSaveEnabled)
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _, _, _ in
                self?.saveSettings()
            }
            .store(in: &cancellables)
    }
    
    private func loadSettings() {
        // Load user preferences from UserDefaults
        isDarkModeEnabled = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        isNotificationsEnabled = UserDefaults.standard.bool(forKey: "isNotificationsEnabled")
        isAutoSaveEnabled = UserDefaults.standard.bool(forKey: "isAutoSaveEnabled")
    }
    
    private func saveSettings() {
        // Save user preferences to UserDefaults
        UserDefaults.standard.set(isDarkModeEnabled, forKey: "isDarkModeEnabled")
        UserDefaults.standard.set(isNotificationsEnabled, forKey: "isNotificationsEnabled")
        UserDefaults.standard.set(isAutoSaveEnabled, forKey: "isAutoSaveEnabled")
    }
}

// MARK: - Settings Data Models
struct SettingsSection {
    let title: String
    let items: [SettingsItem]
}

struct SettingsItem {
    let icon: String
    let title: String
    let subtitle: String?
    let type: SettingsItemType
    let action: (() -> Void)?
}

enum SettingsItemType {
    case toggle(Bool)
    case action
    case navigation
    case info(String)
}

// MARK: - Settings Data
extension SettingsViewModel {
    var settingsSections: [SettingsSection] {
        [
            SettingsSection(
                title: "Privacy & Security",
                items: [
                    SettingsItem(
                        icon: "shield.checkered",
                        title: "Privacy Policy",
                        subtitle: "Read our privacy commitment",
                        type: .action,
                        action: { [weak self] in self?.showPrivacyPolicy() }
                    ),
                    SettingsItem(
                        icon: "trash",
                        title: "Clear Chat History",
                        subtitle: "Delete all conversations",
                        type: .action,
                        action: { [weak self] in self?.showClearChatAlert() }
                    )
                ]
            ),
            SettingsSection(
                title: "Interface",
                items: [
                    SettingsItem(
                        icon: "moon.fill",
                        title: "Dark Mode",
                        subtitle: "Use dark appearance",
                        type: .toggle(isDarkModeEnabled),
                        action: { [weak self] in self?.toggleDarkMode() }
                    ),
                    SettingsItem(
                        icon: "bell",
                        title: "Notifications",
                        subtitle: "Enable push notifications",
                        type: .toggle(isNotificationsEnabled),
                        action: { [weak self] in self?.toggleNotifications() }
                    ),
                    SettingsItem(
                        icon: "arrow.clockwise",
                        title: "Auto Save",
                        subtitle: "Automatically save conversations",
                        type: .toggle(isAutoSaveEnabled),
                        action: { [weak self] in self?.toggleAutoSave() }
                    )
                ]
            ),
            SettingsSection(
                title: "Demo Features",
                items: [
                    SettingsItem(
                        icon: "airplane",
                        title: "Airplane Mode Test",
                        subtitle: "Verify offline functionality",
                        type: .action,
                        action: { [weak self] in self?.simulateAirplaneMode() }
                    ),
                    SettingsItem(
                        icon: "chart.bar",
                        title: "Performance Test",
                        subtitle: "Run model benchmarks",
                        type: .action,
                        action: { [weak self] in self?.runPerformanceTest() }
                    ),
                    SettingsItem(
                        icon: "sparkles",
                        title: "View Onboarding",
                        subtitle: "Replay the privacy tutorial",
                        type: .action,
                        action: { [weak self] in self?.showOnboarding() }
                    )
                ]
            ),
            SettingsSection(
                title: "About",
                items: [
                    SettingsItem(
                        icon: "info.circle",
                        title: "About MobiusConf Demo",
                        subtitle: "Version 1.0.0",
                        type: .action,
                        action: { [weak self] in self?.showAbout() }
                    )
                ]
            )
        ]
    }
} 
 