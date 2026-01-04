//
//  ChatView.swift
//  MobiusPrivateChatAI
//
//  Created by Amitesh Mani Tiwari on 20/05/25.
//  Updated: 20/07/25
//

import SwiftUI

/// Main chat interface for the PrivateChat AI app
/// Features a modern messaging app design with privacy-first indicators
struct ChatView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - State Objects
    @StateObject private var aiModelManager = AIModelManager()
    @StateObject private var viewModel: ChatViewModel
    
    // MARK: - State
    @State private var showingPrivacyDashboard = false
    @State private var showingSettings = false
    
    // MARK: - Initialization
    init() {
        let aiManager = AIModelManager()
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: ChatViewModel(aiModelManager: aiManager, context: context))
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Chat Messages
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, message in
                            MessageBubble(message: message)
                                .id("message-\(index)")
                        }
                        
                        // MARK: - Streaming Response
                        if viewModel.isProcessing && !viewModel.currentStreamingResponse.isEmpty {
                            MessageBubble(
                                message: Message(
                                    content: viewModel.currentStreamingResponse,
                                    isFromUser: false
                                ),
                                isStreaming: true
                            )
                            .id("streaming")
                        }
                        
                        // MARK: - Typing Indicator
                        if viewModel.isProcessing && viewModel.currentStreamingResponse.isEmpty {
                            TypingIndicator()
                                .id("typing")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    scrollToBottom()
                }
                .onChange(of: viewModel.currentStreamingResponse) { _ in
                    scrollToBottom()
                }
                
                // MARK: - Sample Prompts
                if viewModel.showSamplePrompts {
                    SamplePromptsView(viewModel: viewModel)
                }
                
                // MARK: - Input Area
                MessageInputView(
                    text: $viewModel.currentInput,
                    isProcessing: viewModel.isProcessing,
                    onSend: viewModel.sendMessage,
                    onSamplePrompts: viewModel.toggleSamplePrompts
                )
            }
            .navigationTitle("MobiusConf Demo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    PrivacyStatusBadge()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button(action: { showingPrivacyDashboard = true }) {
                            Image(systemName: "shield.checkered")
                                .foregroundColor(.green)
                        }
                        
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingPrivacyDashboard) {
            PrivacyDashboardView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: viewModel)
        }
    }
    
    // MARK: - Helper Methods
    private func scrollToBottom() {
        // Simple scroll to bottom - in a real app, you might use a different approach
        // For now, we'll just trigger a layout update to ensure the latest content is visible
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // This ensures the UI updates and shows the latest content
        }
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: Message
    let isStreaming: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    init(message: Message, isStreaming: Bool = false) {
        self.message = message
        self.isStreaming = isStreaming
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isFromUser {
                Spacer(minLength: 80)
                
                VStack(alignment: .trailing, spacing: 6) {
                    Text(message.content)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        .scaleEffect(isStreaming ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isStreaming)
                    
                    Text(formatTimestamp(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 4)
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top, spacing: 12) {
                        // AI Avatar
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.green.opacity(0.2), Color.green.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.green)
                                .font(.system(size: 18, weight: .medium))
                        }
                        .shadow(color: Color.green.opacity(0.2), radius: 4, x: 0, y: 2)
                        
                        Text(message.content)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(.systemGray5), lineWidth: 0.5)
                            )
                            .foregroundColor(.primary)
                            .scaleEffect(isStreaming ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isStreaming)
                    }
                    
                    Text(formatTimestamp(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.leading, 48)
                }
                
                Spacer(minLength: 80)
            }
        }
        .opacity(isStreaming ? 0.9 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isStreaming)
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 12) {
                    // AI Avatar
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.green.opacity(0.2), Color.green.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.green)
                            .font(.system(size: 18, weight: .medium))
                    }
                    .shadow(color: Color.green.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    // Typing dots
                    HStack(spacing: 6) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color.green.opacity(0.6))
                                .frame(width: 10, height: 10)
                                .scaleEffect(animationOffset == CGFloat(index) ? 1.3 : 0.7)
                                .animation(
                                    Animation.easeInOut(duration: 0.8)
                                        .repeatForever()
                                        .delay(Double(index) * 0.15),
                                    value: animationOffset
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(.systemGray5), lineWidth: 0.5)
                    )
                }
            }
            
            Spacer(minLength: 80)
        }
        .onAppear {
            animationOffset = 1
        }
    }
}

// MARK: - Message Input View
struct MessageInputView: View {
    @Binding var text: String
    let isProcessing: Bool
    let onSend: () -> Void
    let onSamplePrompts: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Subtle divider
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 0.5)
                .opacity(0.6)
            
            HStack(spacing: 16) {
                // Sample prompts button
                Button(action: onSamplePrompts) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.2), Color.orange.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "lightbulb")
                            .foregroundColor(.orange)
                            .font(.system(size: 20, weight: .medium))
                    }
                }
                .disabled(isProcessing)
                .scaleEffect(isProcessing ? 0.8 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isProcessing)
                
                // Text input field
                HStack {
                    TextField("Type a message...", text: $text, axis: .vertical)
                        .textFieldStyle(.plain)
                        .focused($isTextFieldFocused)
                        .disabled(isProcessing)
                        .onSubmit {
                            if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                onSend()
                            }
                        }
                    
                    // Send button
                    Button(action: onSend) {
                        ZStack {
                            Circle()
                                .fill(
                                    text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing
                                    ? LinearGradient(
                                        colors: [Color(.systemGray4), Color(.systemGray4)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [Color.blue, Color.blue.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "arrow.up")
                                .foregroundColor(
                                    text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing
                                    ? Color(.systemGray2)
                                    : .white
                                )
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing)
                    .scaleEffect(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing ? 0.9 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .animation(.easeInOut(duration: 0.2), value: isProcessing)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            isTextFieldFocused ? Color.blue.opacity(0.3) : Color(.systemGray4),
                            lineWidth: isTextFieldFocused ? 2 : 1
                        )
                )
                .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(
            Color(.systemBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -2)
        )
    }
}

// MARK: - Sample Prompts View
struct SamplePromptsView: View {
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.orange)
                    .font(.system(size: 14, weight: .medium))
                
                Text("Try these prompts:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(SamplePrompts.prompts, id: \.self) { prompt in
                        Button(action: { 
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.useSamplePrompt(prompt)
                            }
                        }) {
                            Text(prompt)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6),
                                                    colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(.systemGray4), lineWidth: 0.5)
                                )
                                .foregroundColor(.primary)
                        }
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.currentInput)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
        }
        .padding(.top, 8)
        .background(
            Color(.systemBackground)
                .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: -1)
        )
    }
}

// MARK: - Privacy Status Badge
struct PrivacyStatusBadge: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 20, height: 20)
                
                Image(systemName: "wifi.slash")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.green)
            }
            
            Text("Offline")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.green.opacity(0.15), Color.green.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.green.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ChatView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 
