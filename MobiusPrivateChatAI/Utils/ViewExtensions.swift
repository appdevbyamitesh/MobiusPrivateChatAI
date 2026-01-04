//
//  ViewExtensions.swift
//  MobiusPrivateChatAI
//
//  Created by Amitesh Mani Tiwari on 01/06/25.
//  Updated: 20/07/25
//

import SwiftUI

// MARK: - View Extensions
extension View {
    /// Apply a gradient background to the view
    func gradientBackground(colors: [Color], startPoint: UnitPoint = .topLeading, endPoint: UnitPoint = .bottomTrailing) -> some View {
        self.background(
            LinearGradient(
                colors: colors,
                startPoint: startPoint,
                endPoint: endPoint
            )
        )
    }
    
    /// Apply a subtle shadow to the view
    func subtleShadow(color: Color = .black, radius: CGFloat = 4, x: CGFloat = 0, y: CGFloat = 2) -> some View {
        self.shadow(color: color.opacity(0.1), radius: radius, x: x, y: y)
    }
    
    /// Apply a card-style appearance
    func cardStyle(backgroundColor: Color = Color(.systemBackground), cornerRadius: CGFloat = 12) -> some View {
        self
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .subtleShadow()
    }
    
    /// Apply a button-style appearance
    func buttonStyle(backgroundColor: Color, foregroundColor: Color = .white, cornerRadius: CGFloat = 12) -> some View {
        self
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    /// Apply a primary button style
    func primaryButtonStyle() -> some View {
        self.buttonStyle(
            backgroundColor: Color.blue,
            foregroundColor: .white
        )
    }
    
    /// Apply a secondary button style
    func secondaryButtonStyle() -> some View {
        self.buttonStyle(
            backgroundColor: Color.clear,
            foregroundColor: .blue
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue, lineWidth: 2)
        )
    }
    
    /// Apply a success button style
    func successButtonStyle() -> some View {
        self.buttonStyle(
            backgroundColor: Color.green,
            foregroundColor: .white
        )
    }
    
    /// Apply a warning button style
    func warningButtonStyle() -> some View {
        self.buttonStyle(
            backgroundColor: Color.orange,
            foregroundColor: .white
        )
    }
    
    /// Apply a danger button style
    func dangerButtonStyle() -> some View {
        self.buttonStyle(
            backgroundColor: Color.red,
            foregroundColor: .white
        )
    }
    
    /// Hide the view conditionally
    @ViewBuilder
    func hidden(_ shouldHide: Bool) -> some View {
        if shouldHide {
            self.hidden()
        } else {
            self
        }
    }
    
    /// Apply a loading overlay
    func loadingOverlay(_ isLoading: Bool, text: String = "Loading...") -> some View {
        self.overlay(
            Group {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            
                            Text(text)
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                                .opacity(0.9)
                        )
                    }
                }
            }
        )
    }
    
    /// Apply a toast message overlay
    func toastOverlay(_ message: String?, isSuccess: Bool = true) -> some View {
        self.overlay(
            Group {
                if let message = message {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .foregroundColor(isSuccess ? .green : .red)
                            
                            Text(message)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .subtleShadow()
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        )
    }
    
    /// Apply a badge overlay
    func badgeOverlay(_ text: String, color: Color = .red) -> some View {
        self.overlay(
            VStack {
                HStack {
                    Spacer()
                    
                    Text(text)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(color)
                        )
                }
                
                Spacer()
            }
            .padding(.top, 8)
            .padding(.trailing, 8)
        )
    }
    
    /// Apply a pulsing animation
    func pulsingAnimation(isActive: Bool = true) -> some View {
        self.scaleEffect(isActive ? 1.0 : 0.95)
            .animation(
                isActive ? 
                    Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true) : 
                    .default,
                value: isActive
            )
    }
    
    /// Apply a typing indicator animation
    func typingIndicator(isActive: Bool = true) -> some View {
        self.overlay(
            Group {
                if isActive {
                    HStack(spacing: 4) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color.gray.opacity(0.6))
                                .frame(width: 6, height: 6)
                                .scaleEffect(1.0)
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                    value: isActive
                                )
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
                }
            }
        )
    }
}

// MARK: - Color Extensions
extension Color {
    /// Create a color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Get a lighter version of the color
    func lighter(by percentage: CGFloat = 0.2) -> Color {
        return self.opacity(1.0 - percentage)
    }
    
    /// Get a darker version of the color
    func darker(by percentage: CGFloat = 0.2) -> Color {
        return self.opacity(1.0 + percentage)
    }
}

// MARK: - Date Extensions
extension Date {
    /// Format date as relative time string
    func relativeTimeString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    /// Format date as time string
    func timeString() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    /// Format date as date string
    func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}

// MARK: - String Extensions
extension String {
    /// Truncate string to specified length
    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        }
        return self
    }
    
    /// Check if string is valid email
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    /// Capitalize first letter of each word
    var capitalizedWords: String {
        return self.capitalized(with: nil)
    }
} 