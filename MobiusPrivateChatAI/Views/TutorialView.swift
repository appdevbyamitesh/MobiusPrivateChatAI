//
//  TutorialView.swift
//  MobiusPrivateChatAI
//
//  Created by Amitesh Mani Tiwari on 20/05/25.
//  Updated: 20/07/25
//

import SwiftUI

/// Simple tutorial view for additional guidance
struct TutorialView: View {
    @Binding var tutorialStep: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()
                
                // Tutorial content
                VStack(spacing: 24) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Tutorial")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Additional guidance will be available here")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
            }
            .navigationTitle("Tutorial")
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
    TutorialView(tutorialStep: .constant(0))
} 