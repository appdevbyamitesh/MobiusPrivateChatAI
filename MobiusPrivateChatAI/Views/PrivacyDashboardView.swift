//
//  PrivacyDashboardView.swift
//  MobiusPrivateChatAI
//
//  Created by Amitesh Mani Tiwari on 20/05/25.
//  Updated: 20/07/25
//

import SwiftUI

/// Privacy Dashboard showing privacy guarantees and performance metrics
/// Demonstrates the app's commitment to privacy-first AI processing
struct PrivacyDashboardView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingBenchmark = false
    @State private var benchmarkResults: (tokensPerSecond: Double, memoryUsage: Double)?
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Privacy Guarantees
                    PrivacyGuaranteesSection()
                    
                    // MARK: - Performance Metrics
                    PerformanceMetricsSection(
                        metrics: viewModel.privacyMetrics,
                        benchmarkResults: benchmarkResults
                    )
                    
                    // MARK: - Model Information
                    ModelInformationSection(modelInfo: viewModel.modelInfo)
                    
                    // MARK: - Privacy Benefits
                    PrivacyBenefitsSection()
                    
                    // MARK: - Benchmark Button
                    BenchmarkButton(
                        showingBenchmark: $showingBenchmark,
                        onBenchmark: runBenchmark
                    )
                }
                .padding()
            }
            .navigationTitle("MobiusConf Privacy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .overlay {
            if showingBenchmark {
                BenchmarkOverlay()
            }
        }
    }
    
    // MARK: - Helper Methods
    private func runBenchmark() {
        showingBenchmark = true
        
        Task {
            let results = await viewModel.runBenchmark()
            await MainActor.run {
                benchmarkResults = results
                showingBenchmark = false
            }
        }
    }
}

// MARK: - Privacy Guarantees Section
struct PrivacyGuaranteesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "shield.checkered")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("MobiusConf 2025 Privacy")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            VStack(spacing: 12) {
                PrivacyGuaranteeRow(
                    icon: "wifi.slash",
                    title: "No Internet Required",
                    description: "All processing happens on your device",
                    color: .green
                )
                
                PrivacyGuaranteeRow(
                    icon: "lock.shield",
                    title: "Zero Data Transmission",
                    description: "Your messages never leave your device",
                    color: .blue
                )
                
                PrivacyGuaranteeRow(
                    icon: "brain.head.profile",
                    title: "On-Device AI",
                    description: "Local Core ML model processing",
                    color: .purple
                )
                
                PrivacyGuaranteeRow(
                    icon: "eye.slash",
                    title: "No Tracking",
                    description: "No analytics or user profiling",
                    color: .red
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Privacy Guarantee Row
struct PrivacyGuaranteeRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title3)
        }
    }
}

// MARK: - Performance Metrics Section
struct PerformanceMetricsSection: View {
    let metrics: PrivacyMetrics
    let benchmarkResults: (tokensPerSecond: Double, memoryUsage: Double)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("Performance Metrics")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                MetricCard(
                    title: "Messages Processed",
                    value: "\(metrics.messagesProcessedLocally)",
                    icon: "message",
                    color: .blue
                )
                
                MetricCard(
                    title: "Messages to Cloud",
                    value: "\(metrics.messagesSentToCloud)",
                    icon: "cloud.slash",
                    color: .green
                )
                
                MetricCard(
                    title: "Model Size",
                    value: String(format: "%.1f MB", metrics.modelSizeMB),
                    icon: "externaldrive",
                    color: .purple
                )
                
                MetricCard(
                    title: "Memory Usage",
                    value: String(format: "%.1f MB", metrics.memoryUsageMB),
                    icon: "memorychip",
                    color: .orange
                )
                
                if let results = benchmarkResults {
                    MetricCard(
                        title: "Processing Speed",
                        value: String(format: "%.1f t/s", results.tokensPerSecond),
                        icon: "speedometer",
                        color: .green
                    )
                } else {
                    MetricCard(
                        title: "Processing Speed",
                        value: String(format: "%.1f t/s", metrics.processingSpeedTokensPerSecond),
                        icon: "speedometer",
                        color: .green
                    )
                }
                
                MetricCard(
                    title: "Battery Usage",
                    value: String(format: "%.1f%%", metrics.batteryUsagePercentage),
                    icon: "battery.100",
                    color: .red
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Metric Card
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Model Information Section
struct ModelInformationSection: View {
    let modelInfo: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.purple)
                    .font(.title2)
                
                Text("Model Information")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(modelInfo.components(separatedBy: "\n"), id: \.self) { line in
                    if !line.isEmpty {
                        HStack {
                            Text("•")
                                .foregroundColor(.purple)
                            Text(line)
                                .font(.body)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Privacy Benefits Section
struct PrivacyBenefitsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart")
                    .foregroundColor(.red)
                    .font(.title2)
                
                Text("Why Privacy Matters")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                BenefitRow(
                    title: "Data Sovereignty",
                    description: "Your data stays under your control"
                )
                
                BenefitRow(
                    title: "No Surveillance",
                    description: "No corporate tracking or profiling"
                )
                
                BenefitRow(
                    title: "Faster Responses",
                    description: "No network latency, instant processing"
                )
                
                BenefitRow(
                    title: "Works Offline",
                    description: "Full functionality without internet"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Benefit Row
struct BenefitRow: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title3)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Benchmark Button
struct BenchmarkButton: View {
    @Binding var showingBenchmark: Bool
    let onBenchmark: () -> Void
    
    var body: some View {
        Button(action: onBenchmark) {
            HStack {
                Image(systemName: "speedometer")
                Text("Run Performance Benchmark")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(showingBenchmark)
    }
}

// MARK: - Benchmark Overlay
struct BenchmarkOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text("Running Benchmark...")
                    .font(.headline)
                
                Text("Testing model performance and memory usage")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(32)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    PrivacyDashboardView(viewModel: ChatViewModel(
        aiModelManager: AIModelManager(),
        context: PersistenceController.preview.container.viewContext
    ))
} 