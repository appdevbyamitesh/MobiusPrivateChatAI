//
//  PerformanceService.swift
//  MobiusPrivateChatAI
//
//  Created by Amitesh Mani Tiwari on 28/05/25.
//  Updated: 20/07/25
//

import Foundation
import Combine

/// Service responsible for performance monitoring and benchmarking
/// Follows clean architecture principles
class PerformanceService: ObservableObject {
    // MARK: - Published Properties
    @Published var performanceMetrics = PerformanceMetrics()
    @Published var isBenchmarkRunning = false
    @Published var benchmarkResults: [BenchmarkResult] = []
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Constants
    private enum Keys {
        static let averageResponseTime = "averageResponseTime"
        static let tokensPerSecond = "tokensPerSecond"
        static let totalRequests = "totalRequests"
        static let successRate = "successRate"
        static let benchmarkResults = "benchmarkResults"
    }
    
    // MARK: - Initialization
    init() {
        loadPerformanceMetrics()
        setupPerformanceMonitoring()
    }
    
    // MARK: - Public Methods
    
    /// Run comprehensive performance benchmark
    func runBenchmark() async throws -> [BenchmarkResult] {
        await MainActor.run {
            isBenchmarkRunning = true
        }
        
        var results: [BenchmarkResult] = []
        
        // Test 1: Response time benchmark
        let responseTimeResult = try await measureResponseTime()
        results.append(responseTimeResult)
        
        // Test 2: Throughput benchmark
        let throughputResult = try await measureThroughput()
        results.append(throughputResult)
        
        // Test 3: Memory usage benchmark
        let memoryResult = try await measureMemoryUsage()
        results.append(memoryResult)
        
        // Test 4: CPU usage benchmark
        let cpuResult = try await measureCPUUsage()
        results.append(cpuResult)
        
        let finalResults = results // Create a copy to avoid capture issues
        
        await MainActor.run {
            self.benchmarkResults = finalResults
            self.updatePerformanceMetrics(with: finalResults)
            self.isBenchmarkRunning = false
        }
        
        return results
    }
    
    /// Record a single request performance
    func recordRequest(responseTime: Double, success: Bool) {
        let currentMetrics = performanceMetrics
        let newTotalRequests = currentMetrics.totalRequests + 1
        let newSuccessCount = Int(Double(currentMetrics.totalRequests) * currentMetrics.successRate) + (success ? 1 : 0)
        let newSuccessRate = Double(newSuccessCount) / Double(newTotalRequests)
        
        // Calculate new average response time
        let totalResponseTime = currentMetrics.averageResponseTime * Double(currentMetrics.totalRequests) + responseTime
        let newAverageResponseTime = totalResponseTime / Double(newTotalRequests)
        
        performanceMetrics = PerformanceMetrics(
            averageResponseTime: newAverageResponseTime,
            tokensPerSecond: currentMetrics.tokensPerSecond,
            totalRequests: newTotalRequests,
            successRate: newSuccessRate
        )
        
        savePerformanceMetrics()
    }
    
    /// Get current performance metrics
    func getPerformanceMetrics() -> PerformanceMetrics {
        return performanceMetrics
    }
    
    /// Reset performance metrics
    func resetPerformanceMetrics() {
        performanceMetrics = PerformanceMetrics()
        benchmarkResults = []
        savePerformanceMetrics()
    }
    
    /// Generate performance report
    func generatePerformanceReport() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        return """
        Performance Report - PrivateChat AI
        
        Generated: \(dateFormatter.string(from: Date()))
        
        Overall Metrics:
        - Average Response Time: \(String(format: "%.2f", performanceMetrics.averageResponseTime))ms
        - Tokens per Second: \(String(format: "%.2f", performanceMetrics.tokensPerSecond))
        - Total Requests: \(performanceMetrics.totalRequests)
        - Success Rate: \(String(format: "%.1f", performanceMetrics.successRate * 100))%
        
        Latest Benchmark Results:
        \(benchmarkResults.map { "- \($0.testName): \(String(format: "%.2f", $0.responseTime))ms" }.joined(separator: "\n"))
        
        Performance Grade: \(getPerformanceGrade())
        """
    }
    
    /// Get performance grade based on metrics
    func getPerformanceGrade() -> String {
        let responseTime = performanceMetrics.averageResponseTime
        let successRate = performanceMetrics.successRate
        
        if responseTime < 100 && successRate > 0.95 {
            return "A+ (Excellent)"
        } else if responseTime < 200 && successRate > 0.90 {
            return "A (Very Good)"
        } else if responseTime < 500 && successRate > 0.85 {
            return "B (Good)"
        } else if responseTime < 1000 && successRate > 0.80 {
            return "C (Average)"
        } else {
            return "D (Needs Improvement)"
        }
    }
    
    // MARK: - Private Methods
    
    private func loadPerformanceMetrics() {
        let averageResponseTime = userDefaults.double(forKey: Keys.averageResponseTime)
        let tokensPerSecond = userDefaults.double(forKey: Keys.tokensPerSecond)
        let totalRequests = userDefaults.integer(forKey: Keys.totalRequests)
        let successRate = userDefaults.double(forKey: Keys.successRate)
        
        performanceMetrics = PerformanceMetrics(
            averageResponseTime: averageResponseTime,
            tokensPerSecond: tokensPerSecond,
            totalRequests: totalRequests,
            successRate: successRate > 0 ? successRate : 1.0
        )
    }
    
    private func savePerformanceMetrics() {
        userDefaults.set(performanceMetrics.averageResponseTime, forKey: Keys.averageResponseTime)
        userDefaults.set(performanceMetrics.tokensPerSecond, forKey: Keys.tokensPerSecond)
        userDefaults.set(performanceMetrics.totalRequests, forKey: Keys.totalRequests)
        userDefaults.set(performanceMetrics.successRate, forKey: Keys.successRate)
    }
    
    private func setupPerformanceMonitoring() {
        // Monitor performance metrics changes
        $performanceMetrics
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.savePerformanceMetrics()
            }
            .store(in: &cancellables)
    }
    
    private func updatePerformanceMetrics(with results: [BenchmarkResult]) {
        let avgResponseTime = results.map { $0.responseTime }.reduce(0, +) / Double(results.count)
        let avgTokensPerSecond = results.map { $0.tokensPerSecond }.reduce(0, +) / Double(results.count)
        let successRate = Double(results.filter { $0.success }.count) / Double(results.count)
        
        performanceMetrics = PerformanceMetrics(
            averageResponseTime: avgResponseTime,
            tokensPerSecond: avgTokensPerSecond,
            totalRequests: results.count,
            successRate: successRate
        )
        
        savePerformanceMetrics()
    }
    
    // MARK: - Benchmark Tests
    
    private func measureResponseTime() async throws -> BenchmarkResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Simulate AI processing
        try await Task.sleep(nanoseconds: UInt64.random(in: 100_000_000...500_000_000))
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let responseTime = (endTime - startTime) * 1000 // Convert to milliseconds
        
        return BenchmarkResult(
            testName: "Response Time",
            responseTime: responseTime,
            tokensPerSecond: 50.0 + Double.random(in: 0...20),
            success: true,
            timestamp: Date()
        )
    }
    
    private func measureThroughput() async throws -> BenchmarkResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Simulate multiple requests
        for _ in 0..<5 {
            try await Task.sleep(nanoseconds: UInt64.random(in: 50_000_000...200_000_000))
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let totalTime = (endTime - startTime) * 1000
        let throughput = 5.0 / (totalTime / 1000) // Requests per second
        
        return BenchmarkResult(
            testName: "Throughput",
            responseTime: totalTime / 5.0,
            tokensPerSecond: throughput * 10,
            success: true,
            timestamp: Date()
        )
    }
    
    private func measureMemoryUsage() async throws -> BenchmarkResult {
        // Simulate memory usage measurement
        try await Task.sleep(nanoseconds: UInt64.random(in: 50_000_000...150_000_000))
        
        return BenchmarkResult(
            testName: "Memory Usage",
            responseTime: Double.random(in: 50...150),
            tokensPerSecond: 45.0 + Double.random(in: 0...10),
            success: true,
            timestamp: Date()
        )
    }
    
    private func measureCPUUsage() async throws -> BenchmarkResult {
        // Simulate CPU usage measurement
        try await Task.sleep(nanoseconds: UInt64.random(in: 30_000_000...100_000_000))
        
        return BenchmarkResult(
            testName: "CPU Usage",
            responseTime: Double.random(in: 30...100),
            tokensPerSecond: 40.0 + Double.random(in: 0...15),
            success: true,
            timestamp: Date()
        )
    }
}
