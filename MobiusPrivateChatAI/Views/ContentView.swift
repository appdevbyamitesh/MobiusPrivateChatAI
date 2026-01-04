//
//  ContentView.swift
//  MobiusPrivateChatAI
//
//  Created by Amitesh Mani Tiwari on 20/07/25.
//

import SwiftUI

/// Main content view for the PrivateChat AI app
/// Serves as the entry point and container for the chat interface
struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showingOnboarding = false
    
    var body: some View {
        ChatView()
            .sheet(isPresented: $showingOnboarding) {
                OnboardingView()
            }
            .onAppear {
                if !hasSeenOnboarding {
                    showingOnboarding = true
                    hasSeenOnboarding = true
                }
            }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
